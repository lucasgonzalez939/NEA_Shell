#!/bin/bash
# ==============================================================================
# NEA Shell - MOTOR DE MISIONES v3.0
# ==============================================================================
# Sistema de misiones gamificadas para aprendizaje de comandos Linux

# Source de variables de entorno
source /usr/local/bin/nea_env 2>/dev/null || source "$(dirname "$0")/nea_env.sh"

# Colores
VERDE='\033[0;32m'
AMARILLO='\033[1;33m'
ROJO='\033[0;31m'
CIAN='\033[0;36m'
MAGENTA='\033[0;35m'
AZUL='\033[0;34m'
BOLD='\033[1m'
NC='\033[0m'

# Variables globales
STUDENT_NAME=""
PROGRESS_FILE=""
CURRENT_LEVEL=1
CURRENT_XP=0
MISSIONS_DIR=""
HINT_COUNT=0

# ==============================================================================
# FUNCIONES DE UTILIDAD
# ==============================================================================

show_banner() {
    clear
    echo -e "${CIAN}╔════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CIAN}║${NC}           ${BOLD}🎯 NEA SHELL - SISTEMA DE MISIONES${NC}          ${CIAN}║${NC}"
    echo -e "${CIAN}╚════════════════════════════════════════════════════════════╝${NC}"
    echo ""
}

load_progress() {
    if [ -f "$PROGRESS_FILE" ]; then
        STUDENT_NAME=$(jq -r '.name' "$PROGRESS_FILE")
        CURRENT_LEVEL=$(jq -r '.level' "$PROGRESS_FILE")
        CURRENT_XP=$(jq -r '.xp' "$PROGRESS_FILE")
        return 0
    else
        echo -e "${ROJO}Error: No se encontró archivo de progreso${NC}"
        return 1
    fi
}

save_progress() {
    local temp_file=$(mktemp)
    jq --arg xp "$CURRENT_XP" \
       --arg level "$CURRENT_LEVEL" \
       --arg date "$(date -Iseconds)" \
       '.xp = ($xp | tonumber) | .level = ($level | tonumber) | .last_login = $date' \
       "$PROGRESS_FILE" > "$temp_file"
    mv "$temp_file" "$PROGRESS_FILE"
}

add_badge() {
    local badge="$1"
    local temp_file=$(mktemp)
    jq --arg badge "$badge" '.badges += [$badge] | .badges |= unique' "$PROGRESS_FILE" > "$temp_file"
    mv "$temp_file" "$PROGRESS_FILE"
}

add_completed_mission() {
    local mission_id="$1"
    local temp_file=$(mktemp)
    jq --arg mission "$mission_id" '.missions_completed += [$mission] | .missions_completed |= unique' "$PROGRESS_FILE" > "$temp_file"
    mv "$temp_file" "$PROGRESS_FILE"
}

show_progress_bar() {
    local current=$1
    local total=$2
    local width=40
    local percentage=$((current * 100 / total))
    local filled=$((current * width / total))
    
    echo -n "["
    for ((i=0; i<filled; i++)); do echo -n "▓"; done
    for ((i=filled; i<width; i++)); do echo -n "░"; done
    echo -n "] ${percentage}%"
}

animate_xp_gain() {
    local gained=$1
    echo -e "\n${VERDE}${BOLD}✨ +${gained} XP ganados!${NC}"
    sleep 0.5
    echo -e "${CIAN}XP Total: ${CURRENT_XP}${NC}"
}

# ==============================================================================
# SISTEMA DE VALIDACIÓN
# ==============================================================================

validate_objective() {
    local validation_type="$1"
    local validation_value="$2"
    
    case "$validation_type" in
        "pwd_contains")
            if [[ "$(pwd)" == *"$validation_value"* ]]; then
                return 0
            fi
            ;;
        "pwd_not_contains")
            if [[ "$(pwd)" != *"$validation_value"* ]]; then
                return 0
            fi
            ;;
        "pwd_equals")
            local expected_path=$(eval echo "$validation_value")
            if [[ "$(pwd)" == "$expected_path" ]]; then
                return 0
            fi
            ;;
        "file_exists")
            if [ -f "$validation_value" ] || [ -d "$validation_value" ]; then
                return 0
            fi
            ;;
        "command_success")
            if eval "$validation_value" &>/dev/null; then
                return 0
            fi
            ;;
        "file_contains")
            local file="${validation_value%%:*}"
            local text="${validation_value#*:}"
            if [ -f "$file" ] && grep -q "$text" "$file"; then
                return 0
            fi
            ;;
        *)
            return 1
            ;;
    esac
    return 1
}

# ==============================================================================
# SISTEMA DE HINTS
# ==============================================================================

show_hint() {
    local hint="$1"
    ((HINT_COUNT++))
    
    case $HINT_COUNT in
        1)
            echo -e "\n${AMARILLO}💡 Pista 1: ${hint}${NC}"
            ;;
        2)
            echo -e "\n${AMARILLO}💡 Pista 2: Recuerda que puedes usar 'pwd' para ver dónde estás${NC}"
            ;;
        3)
            echo -e "\n${AMARILLO}💡 Pista 3: Comando exacto: ${BOLD}${hint}${NC}"
            ;;
        *)
            echo -e "\n${AMARILLO}💡 Ya usaste todas las pistas. ¡Tú puedes!${NC}"
            ;;
    esac
}

# ==============================================================================
# MOTOR PRINCIPAL DE MISIONES
# ==============================================================================

run_mission() {
    local level=$1
    local mission_file="$MISSIONS_DIR/nivel${level}/mision.json"
    
    if [ ! -f "$mission_file" ]; then
        echo -e "${ROJO}Error: Misión no encontrada${NC}"
        return 1
    fi
    
    # Cargar datos de la misión
    local title=$(jq -r '.title' "$mission_file")
    local subtitle=$(jq -r '.subtitle' "$mission_file")
    local description=$(jq -r '.description' "$mission_file")
    local xp_reward=$(jq -r '.xp_reward' "$mission_file")
    local badge=$(jq -r '.badge_reward' "$mission_file")
    local objectives_count=$(jq '.objectives | length' "$mission_file")
    
    show_banner
    echo -e "${MAGENTA}${BOLD}═══ NIVEL $level: $title ═══${NC}"
    echo -e "${CIAN}$subtitle${NC}\n"
    echo -e "$description\n"
    echo -e "${AMARILLO}Recompensa: ${xp_reward} XP + Badge: $badge${NC}"
    echo -e "\n${CIAN}────────────────────────────────────────────────────────────${NC}\n"
    
    # Procesar objetivos
    local completed=0
    HINT_COUNT=0
    
    for ((i=0; i<objectives_count; i++)); do
        local obj_desc=$(jq -r ".objectives[$i].description" "$mission_file")
        local obj_hint=$(jq -r ".objectives[$i].hint" "$mission_file")
        local obj_validation=$(jq -r ".objectives[$i].validation" "$mission_file")
        local obj_xp=$(jq -r ".objectives[$i].xp" "$mission_file")
        
        echo -e "${BOLD}Objetivo $((i+1))/$objectives_count:${NC} $obj_desc"
        
        # Parsear validación
        local val_type="${obj_validation%%:*}"
        local val_value="${obj_validation#*:}"
        
        local attempts=0
        local max_attempts=10
        
        while true; do
            echo -e "\n${CIAN}→${NC} Ejecuta el comando (o 'hint' para pista, 'skip' para saltar):"
            read -p "> " user_input
            
            case "$user_input" in
                "hint")
                    show_hint "$obj_hint"
                    continue
                    ;;
                "skip")
                    echo -e "${AMARILLO}⏭ Objetivo saltado${NC}\n"
                    break
                    ;;
                "quit"|"exit"|"salir")
                    echo -e "\n${AMARILLO}Misión interrumpida. Progreso guardado.${NC}"
                    return 2
                    ;;
                "")
                    echo -e "${ROJO}Debes escribir un comando${NC}"
                    continue
                    ;;
            esac
            
            # Ejecutar comando del usuario
            eval "$user_input" 2>&1
            local cmd_exit=$?
            
            # Validar objetivo
            if validate_objective "$val_type" "$val_value"; then
                echo -e "\n${VERDE}${BOLD}✓ ¡Objetivo completado!${NC}"
                CURRENT_XP=$((CURRENT_XP + obj_xp))
                animate_xp_gain $obj_xp
                ((completed++))
                sleep 1
                echo ""
                break
            else
                ((attempts++))
                if [ $attempts -ge $max_attempts ]; then
                    echo -e "${ROJO}Has alcanzado el máximo de intentos.${NC}"
                    break
                fi
                echo -e "${AMARILLO}⚠ No completado aún. Intenta de nuevo.${NC}"
            fi
        done
    done
    
    # Mostrar resultado final
    echo -e "${CIAN}────────────────────────────────────────────────────────────${NC}"
    echo -e "\n${BOLD}Resultado de la Misión:${NC}"
    show_progress_bar $completed $objectives_count
    echo ""
    
    if [ $completed -eq $objectives_count ]; then
        echo -e "\n${VERDE}${BOLD}🎉 ¡MISIÓN COMPLETADA!${NC}"
        CURRENT_XP=$((CURRENT_XP + xp_reward))
        animate_xp_gain $xp_reward
        
        if [ "$badge" != "null" ]; then
            echo -e "${MAGENTA}🏆 Badge desbloqueado: $badge${NC}"
            add_badge "$badge"
        fi
        
        add_completed_mission "nivel${level}"
        
        # Subir de nivel si es necesario
        local xp_needed=$((CURRENT_LEVEL * 100))
        if [ $CURRENT_XP -ge $xp_needed ]; then
            CURRENT_LEVEL=$((CURRENT_LEVEL + 1))
            echo -e "\n${CIAN}${BOLD}⬆️  ¡SUBISTE DE NIVEL! Ahora eres Nivel $CURRENT_LEVEL${NC}"
        fi
        
        save_progress
        return 0
    else
        echo -e "\n${AMARILLO}Misión incompleta. Puedes intentarlo de nuevo.${NC}"
        save_progress
        return 1
    fi
}

# ==============================================================================
# MENÚ PRINCIPAL
# ==============================================================================

show_mission_menu() {
    show_banner
    echo -e "${BOLD}Agente: ${VERDE}$STUDENT_NAME${NC}"
    echo -e "${BOLD}Nivel:${NC} $CURRENT_LEVEL | ${BOLD}XP:${NC} $CURRENT_XP"
    echo -e "${CIAN}────────────────────────────────────────────────────────────${NC}\n"
    
    echo -e "${BOLD}Misiones Disponibles:${NC}\n"
    
    for level in {1..7}; do
        local mission_file="$MISSIONS_DIR/nivel${level}/mision.json"
        if [ -f "$mission_file" ]; then
            local title=$(jq -r '.title' "$mission_file")
            local difficulty=$(jq -r '.difficulty' "$mission_file")
            local completed=$(jq -r ".missions_completed[] | select(. == \"nivel${level}\")" "$PROGRESS_FILE" 2>/dev/null)
            
            if [ "$completed" == "nivel${level}" ]; then
                echo -e "  ${VERDE}✓${NC} [$level] $title ${VERDE}(Completada)${NC}"
            elif [ $level -le $CURRENT_LEVEL ]; then
                echo -e "  ${CIAN}→${NC} [$level] $title ${AMARILLO}($difficulty)${NC}"
            else
                echo -e "  ${NC}🔒${NC} [$level] $title ${NC}(Bloqueada)${NC}"
            fi
        fi
    done
    
    echo -e "\n${CIAN}────────────────────────────────────────────────────────────${NC}"
    echo -e "\nElige una misión (1-7) o 'q' para salir:"
    read -p "> " choice
    
    case "$choice" in
        [1-7])
            if [ $choice -le $CURRENT_LEVEL ]; then
                run_mission $choice
                read -p "Presiona ENTER para continuar..."
                show_mission_menu
            else
                echo -e "${ROJO}Esta misión está bloqueada. Completa las anteriores primero.${NC}"
                sleep 2
                show_mission_menu
            fi
            ;;
        "q"|"quit"|"salir")
            echo -e "\n${CIAN}¡Hasta luego, Agente $STUDENT_NAME!${NC}"
            exit 0
            ;;
        *)
            echo -e "${ROJO}Opción inválida${NC}"
            sleep 1
            show_mission_menu
            ;;
    esac
}

# ==============================================================================
# MAIN
# ==============================================================================

main() {
    # Verificar dependencias
    if ! command -v jq &> /dev/null; then
        echo -e "${ROJO}Error: 'jq' no está instalado${NC}"
        exit 1
    fi
    
    # Detectar usuario y configurar paths
    local current_user=$(whoami)
    PROGRESS_FILE="$HOME/.progress.json"
    
    # Detectar directorio de misiones
    if [ -d "/home/$current_user/missions" ]; then
        MISSIONS_DIR="/home/$current_user/missions"
    elif [ -d "/opt/nea_shell/missions" ]; then
        MISSIONS_DIR="/opt/nea_shell/missions"
    else
        echo -e "${ROJO}Error: No se encontró el directorio de misiones${NC}"
        exit 1
    fi
    
    # Cargar progreso
    if ! load_progress; then
        exit 1
    fi
    
    # Iniciar menú
    show_mission_menu
}

# Ejecutar main si no se está sourcing
if [ "${BASH_SOURCE[0]}" == "${0}" ]; then
    main "$@"
fi

# ==============================================================================
# NEA TOUR SCRIPT
# ==============================================================================

# NEA Shell - Interactive Tutorial and Mission System
# This script provides an engaging introduction to terminal commands

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
RED='\033[0;31m'
MAGENTA='\033[0;35m'
NC='\033[0m' # No Color

# User data directory
USER_DATA="$HOME/.nea_shell"
PROGRESS_FILE="$USER_DATA/progress.json"
MISSION_DIR="$HOME/missions"

# Initialize user data
init_user_data() {
    mkdir -p "$USER_DATA"
    
    if [ ! -f "$PROGRESS_FILE" ]; then
        cat > "$PROGRESS_FILE" << 'EOF'
{
  "level": 1,
  "xp": 0,
  "missions_completed": [],
  "current_mission": "welcome",
  "badges": [],
  "last_login": ""
}
EOF
    fi
    
    # Update last login
    jq ".last_login = \"$(date '+%Y-%m-%d %H:%M:%S')\"" "$PROGRESS_FILE" > "${PROGRESS_FILE}.tmp" && mv "${PROGRESS_FILE}.tmp" "$PROGRESS_FILE"
}

# Display animated header
show_header() {
    clear
    echo -e "${CYAN}"
    cat << 'EOF'
    ███╗   ██╗███████╗ █████╗     ████████╗ ██████╗ ██╗   ██╗██████╗ 
    ████╗  ██║██╔════╝██╔══██╗    ╚══██╔══╝██╔═══██╗██║   ██║██╔══██╗
    ██╔██╗ ██║█████╗  ███████║       ██║   ██║   ██║██║   ██║██████╔╝
    ██║╚██╗██║██╔══╝  ██╔══██║       ██║   ██║   ██║██║   ██║██╔══██╗
    ██║ ╚████║███████╗██║  ██║       ██║   ╚██████╔╝╚██████╔╝██║  ██║
    ╚═╝  ╚═══╝╚══════╝╚═╝  ╚═╝       ╚═╝    ╚═════╝  ╚═════╝ ╚═╝  ╚═╝
EOF
    echo -e "${NC}"
    echo -e "${BLUE}════════════════════════════════════════════════════════════════${NC}"
    echo -e "${YELLOW}          🚀 SISTEMA DE ENTRENAMIENTO EN TERMINAL 🚀${NC}"
    echo -e "${BLUE}════════════════════════════════════════════════════════════════${NC}"
    echo ""
}

# Show user stats
show_stats() {
    local level=$(jq -r '.level' "$PROGRESS_FILE")
    local xp=$(jq -r '.xp' "$PROGRESS_FILE")
    local next_level_xp=$((level * 100))
    local missions_count=$(jq -r '.missions_completed | length' "$PROGRESS_FILE")
    
    echo -e "${CYAN}👤 AGENTE:${NC} $USER"
    echo -e "${CYAN}⚡ NIVEL:${NC} $level"
    echo -e "${CYAN}✨ XP:${NC} $xp / $next_level_xp"
    echo -e "${CYAN}🏆 MISIONES COMPLETADAS:${NC} $missions_count"
    echo ""
}

# Main menu
show_menu() {
    show_header
    show_stats
    
    echo -e "${GREEN}¿Qué deseas hacer?${NC}"
    echo ""
    echo "  1) 📖 Comenzar tutorial básico"
    echo "  2) 🎯 Ver misiones disponibles"
    echo "  3) 📊 Ver mi progreso"
    echo "  4) 🏅 Ver mis logros"
    echo "  5) ❓ Ayuda"
    echo "  6) 🚪 Salir"
    echo ""
    read -p "Selecciona una opción [1-6]: " choice
    
    case $choice in
        1) start_tutorial ;;
        2) show_missions ;;
        3) show_progress ;;
        4) show_badges ;;
        5) show_help ;;
        6) exit 0 ;;
        *) echo -e "${RED}Opción inválida${NC}"; sleep 2; show_menu ;;
    esac
}

# Tutorial básico
start_tutorial() {
    clear
    echo -e "${YELLOW}╔════════════════════════════════════════════════════════╗${NC}"
    echo -e "${YELLOW}║          📖 TUTORIAL BÁSICO - MISIÓN 1               ║${NC}"
    echo -e "${YELLOW}╚════════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${CYAN}¡Bienvenido, Agente!${NC}"
    echo ""
    echo "Este tutorial te enseñará los comandos básicos de la terminal."
    echo "Aprenderás a navegar, crear carpetas y archivos."
    echo ""
    read -p "Presiona ENTER para comenzar..."
    
    # Lección 1: pwd
    clear
    echo -e "${MAGENTA}═══ LECCIÓN 1: ¿DÓNDE ESTOY? ═══${NC}"
    echo ""
    echo "El comando 'pwd' (Print Working Directory) te muestra dónde estás."
    echo ""
    echo -e "${YELLOW}Escribe:${NC} pwd"
    echo ""
    
    # Esperar a que el usuario escriba el comando correcto
    while true; do
        read -p "$ " cmd
        if [ "$cmd" = "pwd" ]; then
            pwd
            echo ""
            echo -e "${GREEN}✓ ¡Correcto!${NC} Este es tu directorio actual."
            break
        else
            echo -e "${RED}✗ Intenta de nuevo. Escribe exactamente: pwd${NC}"
        fi
    done
    
    echo ""
    read -p "Presiona ENTER para continuar..."
    
    # Lección 2: ls
    clear
    echo -e "${MAGENTA}═══ LECCIÓN 2: ¿QUÉ HAY AQUÍ? ═══${NC}"
    echo ""
    echo "El comando 'ls' (list) muestra el contenido de una carpeta."
    echo ""
    echo -e "${YELLOW}Escribe:${NC} ls"
    echo ""
    
    while true; do
        read -p "$ " cmd
        if [ "$cmd" = "ls" ]; then
            ls --color=auto
            echo ""
            echo -e "${GREEN}✓ ¡Excelente!${NC} Estos son tus archivos y carpetas."
            break
        else
            echo -e "${RED}✗ Intenta de nuevo. Escribe: ls${NC}"
        fi
    done
    
    echo ""
    read -p "Presiona ENTER para continuar..."
    
    # Lección 3: mkdir
    clear
    echo -e "${MAGENTA}═══ LECCIÓN 3: CREAR CARPETAS ═══${NC}"
    echo ""
    echo "El comando 'mkdir' (make directory) crea una carpeta nueva."
    echo ""
    echo -e "${YELLOW}Escribe:${NC} mkdir mi_primera_carpeta"
    echo ""
    
    while true; do
        read -p "$ " cmd
        if [ "$cmd" = "mkdir mi_primera_carpeta" ]; then
            mkdir -p mi_primera_carpeta
            echo ""
            echo -e "${GREEN}✓ ¡Carpeta creada!${NC}"
            echo ""
            echo "Verifica que existe escribiendo: ls"
            ls --color=auto
            break
        else
            echo -e "${RED}✗ Intenta de nuevo. Escribe: mkdir mi_primera_carpeta${NC}"
        fi
    done
    
    echo ""
    read -p "Presiona ENTER para continuar..."
    
    # Completar misión
    add_xp 50
    complete_mission "tutorial_basic"
    
    clear
    echo -e "${GREEN}╔════════════════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║          🎉 ¡MISIÓN COMPLETADA! 🎉                   ║${NC}"
    echo -e "${GREEN}╚════════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${YELLOW}Has ganado 50 XP${NC}"
    echo ""
    echo "¡Felicitaciones! Has completado el tutorial básico."
    echo ""
    read -p "Presiona ENTER para volver al menú..."
    show_menu
}

# Mostrar misiones disponibles
show_missions() {
    clear
    echo -e "${YELLOW}╔════════════════════════════════════════════════════════╗${NC}"
    echo -e "${YELLOW}║              🎯 MISIONES DISPONIBLES                  ║${NC}"
    echo -e "${YELLOW}╚════════════════════════════════════════════════════════╝${NC}"
    echo ""
    
    echo -e "${CYAN}Misiones de Nivel 1:${NC}"
    echo "  [ ] Tutorial Básico (50 XP)"
    echo "  [ ] Navegación de Archivos (75 XP)"
    echo "  [ ] Crear tu Primera Historia (100 XP)"
    echo ""
    
    echo -e "${CYAN}Próximamente:${NC}"
    echo "  [🔒] Misiones de Nivel 2 (desbloquear en nivel 2)"
    echo ""
    
    read -p "Presiona ENTER para volver..."
    show_menu
}

# Mostrar progreso
show_progress() {
    clear
    show_header
    show_stats
    
    echo -e "${CYAN}Misiones completadas:${NC}"
    jq -r '.missions_completed[]' "$PROGRESS_FILE" 2>/dev/null || echo "  Ninguna aún"
    echo ""
    
    read -p "Presiona ENTER para volver..."
    show_menu
}

# Mostrar logros
show_badges() {
    clear
    echo -e "${YELLOW}╔════════════════════════════════════════════════════════╗${NC}"
    echo -e "${YELLOW}║                🏅 TUS LOGROS                         ║${NC}"
    echo -e "${YELLOW}╚════════════════════════════════════════════════════════╝${NC}"
    echo ""
    
    local badges=$(jq -r '.badges[]' "$PROGRESS_FILE" 2>/dev/null)
    
    if [ -z "$badges" ]; then
        echo "  Aún no has desbloqueado ningún logro."
        echo ""
        echo "  ¡Completa misiones para ganar logros!"
    else
        echo "$badges"
    fi
    
    echo ""
    read -p "Presiona ENTER para volver..."
    show_menu
}

# Ayuda
show_help() {
    clear
    echo -e "${CYAN}╔════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║                  ❓ AYUDA                            ║${NC}"
    echo -e "${CYAN}╚════════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${YELLOW}Comandos básicos de la terminal:${NC}"
    echo ""
    echo "  pwd       - Muestra dónde estás"
    echo "  ls        - Lista archivos y carpetas"
    echo "  cd        - Cambia de carpeta"
    echo "  mkdir     - Crea una carpeta"
    echo "  touch     - Crea un archivo vacío"
    echo "  cat       - Muestra el contenido de un archivo"
    echo "  clear     - Limpia la pantalla"
    echo ""
    echo -e "${YELLOW}Comandos de NEA Shell:${NC}"
    echo ""
    echo "  nea_tour  - Abre este menú"
    echo "  nea_wifi  - Configura WiFi"
    echo ""
    read -p "Presiona ENTER para volver..."
    show_menu
}

# Agregar XP
add_xp() {
    local xp_gain=$1
    local current_xp=$(jq -r '.xp' "$PROGRESS_FILE")
    local current_level=$(jq -r '.level' "$PROGRESS_FILE")
    local new_xp=$((current_xp + xp_gain))
    local next_level_xp=$((current_level * 100))
    
    # Actualizar XP
    jq ".xp = $new_xp" "$PROGRESS_FILE" > "${PROGRESS_FILE}.tmp" && mv "${PROGRESS_FILE}.tmp" "$PROGRESS_FILE"
    
    # Verificar level up
    if [ $new_xp -ge $next_level_xp ]; then
        local new_level=$((current_level + 1))
        jq ".level = $new_level | .xp = 0" "$PROGRESS_FILE" > "${PROGRESS_FILE}.tmp" && mv "${PROGRESS_FILE}.tmp" "$PROGRESS_FILE"
        
        echo -e "${YELLOW}🎊 ¡SUBISTE DE NIVEL! Ahora eres nivel $new_level${NC}"
    fi
}

# Completar misión
complete_mission() {
    local mission_id=$1
    jq ".missions_completed += [\"$mission_id\"]" "$PROGRESS_FILE" > "${PROGRESS_FILE}.tmp" && mv "${PROGRESS_FILE}.tmp" "$PROGRESS_FILE"
}

# Main
init_user_data
show_menu
