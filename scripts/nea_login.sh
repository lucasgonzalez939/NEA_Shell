#!/bin/bash
# ==============================================================================
# NEA Shell - PORTAL DE ACCESO Y MENÚ PRINCIPAL
# ==============================================================================

# Cargar variables de entorno
source /opt/nea_shell/scripts/nea_env.sh 2>/dev/null || {
    echo "Error: No se pudo cargar nea_env.sh"
    exit 1
}

# ============================================================================
# FUNCIONES PRINCIPALES
# ============================================================================

# Obtener o crear perfil de estudiante
get_or_create_profile() {
    local student_name="$1"
    local student_dir="$NEA_STUDENTS_DIR/$student_name"
    local progress_file="$student_dir/.progress.json"
    
    # Crear directorio si no existe
    if [ ! -d "$student_dir" ]; then
        mkdir -p "$student_dir"
    fi
    
    # Crear perfil si no existe
    if [ ! -f "$progress_file" ]; then
        info "Creando nuevo perfil de agente..."
        
        # Copiar plantilla base
        cp "$NEA_CORE/progress_base.json" "$progress_file"
        
        # Personalizar con datos del estudiante
        local grade=$(get_user_grade)
        local timestamp=$(date -Iseconds)
        
        # Usar jq para actualizar el JSON (si está disponible)
        if command_available jq; then
            tmp_file=$(mktemp)
            jq --arg name "$student_name" \
               --arg grade "$grade" \
               --arg timestamp "$timestamp" \
               '.name = $name | .grade = $grade | .student_id = $name | .created_at = $timestamp | .last_login = $timestamp | .stats.login_count = 1 | .achievements.first_login = true' \
               "$progress_file" > "$tmp_file"
            mv "$tmp_file" "$progress_file"
        else
            # Fallback: usar sed (menos robusto pero funcional)
            sed -i "s/\"name\": \"\"/\"name\": \"$student_name\"/" "$progress_file"
            sed -i "s/\"grade\": \"\"/\"grade\": \"$grade\"/" "$progress_file"
            sed -i "s/\"student_id\": \"\"/\"student_id\": \"$student_name\"/" "$progress_file"
            sed -i "s/\"created_at\": \"\"/\"created_at\": \"$timestamp\"/" "$progress_file"
            sed -i "s/\"last_login\": \"\"/\"last_login\": \"$timestamp\"/" "$progress_file"
        fi
        
        success "¡Perfil de agente creado!"
        sleep 1
    else
        # Actualizar última conexión
        update_last_login "$progress_file"
    fi
    
    echo "$progress_file"
}

# Actualizar último login
update_last_login() {
    local progress_file="$1"
    local timestamp=$(date -Iseconds)
    
    if command_available jq; then
        tmp_file=$(mktemp)
        jq --arg timestamp "$timestamp" \
           '.last_login = $timestamp | .stats.login_count += 1' \
           "$progress_file" > "$tmp_file"
        mv "$tmp_file" "$progress_file"
    fi
}

# Leer datos del perfil
read_profile() {
    local progress_file="$1"
    local field="$2"
    
    if command_available jq; then
        jq -r ".$field" "$progress_file" 2>/dev/null || echo "0"
    else
        # Fallback simple
        grep "\"$field\":" "$progress_file" | head -1 | sed 's/.*: *"\?\([^,"]*\)"\?.*/\1/'
    fi
}

# Mostrar información del estudiante
show_student_info() {
    local progress_file="$1"
    
    local name=$(read_profile "$progress_file" "name")
    local level=$(read_profile "$progress_file" "level")
    local xp=$(read_profile "$progress_file" "xp")
    local missions_completed=$(read_profile "$progress_file" "stats.missions_completed")
    local login_count=$(read_profile "$progress_file" "stats.login_count")
    
    reset_screen
    
    echo -e "\n${C_HEADER}╔═══════════════════════════════════════════════════════════╗${NC}"
    echo -e "${C_HEADER}║${NC}              ${C_SUCCESS}PERFIL DE AGENTE${NC}                           ${C_HEADER}║${NC}"
    echo -e "${C_HEADER}╚═══════════════════════════════════════════════════════════╝${NC}\n"
    
    echo -e "  ${C_INFO}Nombre:${NC}       $name"
    echo -e "  ${C_INFO}Nivel:${NC}        $level / $NEA_MAX_LEVEL"
    echo -e "  ${C_INFO}XP:${NC}           $xp"
    
    # Barra de progreso para nivel
    local xp_for_next=$((level * NEA_XP_PER_LEVEL))
    local xp_current=$((xp % NEA_XP_PER_LEVEL))
    echo -ne "  ${C_INFO}Progreso:${NC}     "
    progress_bar "$xp_current" "$NEA_XP_PER_LEVEL"
    echo ""
    
    echo -e "  ${C_INFO}Misiones:${NC}     $missions_completed completadas"
    echo -e "  ${C_INFO}Sesiones:${NC}     $login_count"
    
    # Mostrar badges si existen
    local badges=$(read_profile "$progress_file" "badges")
    if [ "$badges" != "[]" ] && [ -n "$badges" ]; then
        echo -e "\n  ${C_SUCCESS}Logros obtenidos:${NC}"
        # Simplificado: mostrar como está en el JSON
        echo "  $badges" | tr -d '[]"' | tr ',' '\n' | sed 's/^/    • /'
    fi
    
    separator
}

# Mostrar mensaje motivacional según nivel
show_motivational_message() {
    local level="$1"
    
    case $level in
        1)
            echo -e "\n  ${C_PROMPT}💡 Consejo:${NC} Comienza con el comando ${C_SUCCESS}cd${NC} para navegar."
            echo -e "     Cada comando te acerca más a dominar la terminal."
            ;;
        2)
            echo -e "\n  ${C_PROMPT}💡 Consejo:${NC} Usa ${C_SUCCESS}ls${NC} para ver qué hay en cada carpeta."
            echo -e "     ¡La exploración es clave para un buen agente!"
            ;;
        3)
            echo -e "\n  ${C_PROMPT}💡 Consejo:${NC} Los comodines ${C_SUCCESS}*${NC} te ayudarán a trabajar más rápido."
            echo -e "     ¡Estás avanzando muy bien!"
            ;;
        4)
            echo -e "\n  ${C_PROMPT}💡 Consejo:${NC} Lee archivos con ${C_SUCCESS}cat${NC} para encontrar pistas."
            echo -e "     ¡Ya eres un agente de nivel medio!"
            ;;
        5)
            echo -e "\n  ${C_PROMPT}💡 Consejo:${NC} Organiza con ${C_SUCCESS}cp${NC} y ${C_SUCCESS}mv${NC}."
            echo -e "     ¡La organización es poder!"
            ;;
        6)
            echo -e "\n  ${C_PROMPT}💡 Consejo:${NC} Ten cuidado con ${C_SUCCESS}rm${NC}. Es permanente."
            echo -e "     ¡Gran poder conlleva gran responsabilidad!"
            ;;
        7)
            echo -e "\n  ${C_PROMPT}💡 Consejo:${NC} Crea tus propios scripts con ${C_SUCCESS}bash${NC}."
            echo -e "     ¡Estás cerca de ser un maestro de la terminal!"
            ;;
    esac
}

# Menú principal
show_main_menu() {
    local progress_file="$1"
    local level=$(read_profile "$progress_file" "level")
    
    echo -e "\n${C_HEADER}╔═══════════════════════════════════════════════════════════╗${NC}"
    echo -e "${C_HEADER}║${NC}                    ${C_SUCCESS}MENÚ PRINCIPAL${NC}                        ${C_HEADER}║${NC}"
    echo -e "${C_HEADER}╚═══════════════════════════════════════════════════════════╝${NC}\n"
    
    echo -e "  ${C_PROMPT}[1]${NC} 🎯 Iniciar Misión (Nivel $level)"
    echo -e "  ${C_PROMPT}[2]${NC} 📊 Ver Mi Progreso Detallado"
    echo -e "  ${C_PROMPT}[3]${NC} 🏆 Ver Mis Logros"
    echo -e "  ${C_PROMPT}[4]${NC} 📖 Manual de Comandos"
    echo -e "  ${C_PROMPT}[5]${NC} 🚪 Salir al Shell Normal"
    echo -e "  ${C_PROMPT}[0]${NC} 🔴 Cerrar Sesión\n"
    
    show_motivational_message "$level"
    
    echo -e "\n${C_PROMPT}Selecciona una opción:${NC} "
}

# Ver progreso detallado
show_detailed_progress() {
    local progress_file="$1"
    
    reset_screen
    
    echo -e "\n${C_HEADER}╔═══════════════════════════════════════════════════════════╗${NC}"
    echo -e "${C_HEADER}║${NC}              ${C_SUCCESS}ESTADÍSTICAS DETALLADAS${NC}                   ${C_HEADER}║${NC}"
    echo -e "${C_HEADER}╚═══════════════════════════════════════════════════════════╝${NC}\n"
    
    # Leer todas las estadísticas
    local total_commands=$(read_profile "$progress_file" "stats.total_commands")
    local missions_attempted=$(read_profile "$progress_file" "stats.missions_attempted")
    local missions_completed=$(read_profile "$progress_file" "stats.missions_completed")
    local hints_used=$(read_profile "$progress_file" "stats.hints_used")
    local perfect_missions=$(read_profile "$progress_file" "stats.perfect_missions")
    
    echo -e "  ${C_INFO}Comandos ejecutados:${NC}        $total_commands"
    echo -e "  ${C_INFO}Misiones intentadas:${NC}        $missions_attempted"
    echo -e "  ${C_INFO}Misiones completadas:${NC}       $missions_completed"
    
    if [ "$missions_attempted" -gt 0 ]; then
        local success_rate=$((missions_completed * 100 / missions_attempted))
        echo -e "  ${C_INFO}Tasa de éxito:${NC}              ${success_rate}%"
    fi
    
    echo -e "  ${C_INFO}Pistas usadas:${NC}              $hints_used"
    echo -e "  ${C_INFO}Misiones perfectas:${NC}         $perfect_missions"
    
    separator
    
    # Mostrar comandos desbloqueados
    echo -e "\n${C_SUCCESS}Comandos Desbloqueados:${NC}"
    local commands=$(read_profile "$progress_file" "unlocked_commands")
    echo "  $commands" | tr -d '[]"' | tr ',' '\n' | sed 's/^/    ✓ /'
    
    pause
}

# Ver logros
show_achievements() {
    local progress_file="$1"
    
    reset_screen
    
    echo -e "\n${C_HEADER}╔═══════════════════════════════════════════════════════════╗${NC}"
    echo -e "${C_HEADER}║${NC}                  ${C_SUCCESS}LOGROS Y BADGES${NC}                       ${C_HEADER}║${NC}"
    echo -e "${C_HEADER}╚═══════════════════════════════════════════════════════════╝${NC}\n"
    
    # Leer badges
    if command_available jq; then
        local badges=$(jq -r '.badges[]' "$progress_file" 2>/dev/null)
        
        if [ -n "$badges" ]; then
            echo -e "${C_SUCCESS}Logros Desbloqueados:${NC}\n"
            echo "$badges" | while read -r badge; do
                echo -e "  🏆 $badge"
            done
        else
            echo -e "${C_WARNING}Aún no tienes logros desbloqueados.${NC}"
            echo -e "  ¡Completa misiones para obtener badges!"
        fi
    else
        echo -e "${C_WARNING}Se requiere 'jq' para ver los logros.${NC}"
    fi
    
    echo ""
    separator
    
    # Mostrar logros disponibles
    echo -e "\n${C_INFO}Logros Disponibles:${NC}\n"
    echo -e "  $BADGE_FIRST_STEPS - Completa tu primera misión"
    echo -e "  $BADGE_NAVIGATOR - Domina la navegación (cd)"
    echo -e "  $BADGE_EXPLORER - Explora todo con ls"
    echo -e "  $BADGE_READER - Lee 10 archivos"
    echo -e "  $BADGE_ORGANIZER - Organiza archivos perfectamente"
    echo -e "  $BADGE_CAREFUL - Usa rm sin errores"
    echo -e "  $BADGE_SCRIPTER - Crea tu primer script"
    echo -e "  $BADGE_SPEEDRUN - Completa una misión en menos de 5 min"
    echo -e "  $BADGE_PERFECTIONIST - 5 misiones sin pistas"
    echo -e "  $BADGE_PERSISTENT - Inicia sesión 20 veces"
    
    pause
}

# Manual de comandos
show_command_manual() {
    reset_screen
    
    echo -e "\n${C_HEADER}╔═══════════════════════════════════════════════════════════╗${NC}"
    echo -e "${C_HEADER}║${NC}                ${C_SUCCESS}MANUAL DE COMANDOS${NC}                      ${C_HEADER}║${NC}"
    echo -e "${C_HEADER}╚═══════════════════════════════════════════════════════════╝${NC}\n"
    
    echo -e "${C_INFO}Comandos Básicos de Navegación:${NC}"
    echo -e "  ${C_SUCCESS}cd${NC} [carpeta]    - Cambiar de directorio"
    echo -e "  ${C_SUCCESS}ls${NC}              - Listar archivos y carpetas"
    echo -e "  ${C_SUCCESS}pwd${NC}             - Mostrar directorio actual"
    echo -e ""
    echo -e "${C_INFO}Comandos de Lectura:${NC}"
    echo -e "  ${C_SUCCESS}cat${NC} [archivo]   - Mostrar contenido de archivo"
    echo -e "  ${C_SUCCESS}grep${NC} [patrón]   - Buscar texto en archivos"
    echo -e ""
    echo -e "${C_INFO}Comandos de Manipulación:${NC}"
    echo -e "  ${C_SUCCESS}cp${NC} [origen] [destino]   - Copiar archivos"
    echo -e "  ${C_SUCCESS}mv${NC} [origen] [destino]   - Mover/renombrar archivos"
    echo -e "  ${C_SUCCESS}rm${NC} [archivo]            - Eliminar archivo (¡cuidado!)"
    echo -e "  ${C_SUCCESS}mkdir${NC} [carpeta]         - Crear carpeta"
    echo -e ""
    echo -e "${C_INFO}Comandos Avanzados:${NC}"
    echo -e "  ${C_SUCCESS}chmod${NC} [permisos] [archivo] - Cambiar permisos"
    echo -e "  ${C_SUCCESS}bash${NC} [script.sh]          - Ejecutar script"
    
    separator
    echo -e "\n${C_WARNING}Tip:${NC} Usa ${C_SUCCESS}man [comando]${NC} en el shell normal para más info."
    
    pause
}

# ============================================================================
# FLUJO PRINCIPAL
# ============================================================================

main() {
    # Verificar que estamos en un usuario de grado
    local grade=$(get_user_grade)
    if [ "$grade" = "unknown" ]; then
        error "Este script debe ejecutarse desde un usuario de grado (grado_1ro a grado_6to)"
        exit 1
    fi
    
    # Mostrar banner de bienvenida
    show_banner
    sleep 1
    
    # Solicitar nombre del estudiante
    echo -e "\n${C_PROMPT}Ingresa tu nombre de agente:${NC} "
    read student_name
    
    # Validar entrada
    if [ -z "$student_name" ]; then
        error "Debes ingresar un nombre"
        exit 1
    fi
    
    # Sanitizar nombre (remover espacios y caracteres especiales)
    student_name=$(echo "$student_name" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9_-]/_/g')
    
    # Obtener o crear perfil
    local progress_file=$(get_or_create_profile "$student_name")
    
    # Log de acceso
    log_action "$student_name" "LOGIN - Grade: $grade"
    
    # Loop del menú principal
    while true; do
        show_student_info "$progress_file"
        show_main_menu "$progress_file"
        
        read -r option
        
        case $option in
            1)
                # Iniciar misión
                if command_available nea_tour; then
                    nea_tour "$progress_file"
                else
                    error "El sistema de misiones no está disponible"
                    pause
                fi
                ;;
            2)
                # Ver progreso detallado
                show_detailed_progress "$progress_file"
                ;;
            3)
                # Ver logros
                show_achievements "$progress_file"
                ;;
            4)
                # Manual de comandos
                show_command_manual
                ;;
            5)
                # Salir al shell
                clear
                info "Saliendo al shell normal. Escribe ${C_SUCCESS}exit${NC} para cerrar sesión."
                log_action "$student_name" "EXIT_TO_SHELL"
                break
                ;;
            0)
                # Cerrar sesión
                clear
                success "¡Hasta pronto, agente $student_name!"
                log_action "$student_name" "LOGOUT"
                sleep 1
                exit 0
                ;;
            *)
                error "Opción no válida"
                sleep 1
                ;;
        esac
    done
}

# Ejecutar solo si se llama directamente (no si se hace source)
if [ "${BASH_SOURCE[0]}" = "${0}" ]; then
    main "$@"
fi
