#!/bin/bash
# ==============================================================================
# NEA Shell - VARIABLES DE ENTORNO Y CONFIGURACIÓN GLOBAL
# ==============================================================================
# Este archivo debe ser "sourced" por otros scripts: source nea_env.sh

# ============================================================================
# RUTAS DEL SISTEMA
# ============================================================================
export NEA_ROOT="/opt/nea_shell"
export NEA_SCRIPTS="$NEA_ROOT/scripts"
export NEA_MISSIONS="$NEA_ROOT/missions"
export NEA_CORE="$NEA_ROOT/core"
export NEA_BACKUPS="/opt/nea_backups"

# Detectar usuario actual y su grado
export NEA_CURRENT_USER="$USER"
export NEA_HOME="$HOME"
export NEA_STUDENTS_DIR="$HOME/students"
export NEA_MISSIONS_DIR="$HOME/missions"

# ============================================================================
# COLORES Y FORMATO
# ============================================================================
# Colores básicos
export COLOR_RESET='\033[0m'
export COLOR_BLACK='\033[0;30m'
export COLOR_RED='\033[0;31m'
export COLOR_GREEN='\033[0;32m'
export COLOR_YELLOW='\033[0;33m'
export COLOR_BLUE='\033[0;34m'
export COLOR_MAGENTA='\033[0;35m'
export COLOR_CYAN='\033[0;36m'
export COLOR_WHITE='\033[0;37m'

# Colores brillantes
export COLOR_BRIGHT_RED='\033[1;31m'
export COLOR_BRIGHT_GREEN='\033[1;32m'
export COLOR_BRIGHT_YELLOW='\033[1;33m'
export COLOR_BRIGHT_BLUE='\033[1;34m'
export COLOR_BRIGHT_MAGENTA='\033[1;35m'
export COLOR_BRIGHT_CYAN='\033[1;36m'
export COLOR_BRIGHT_WHITE='\033[1;97m'

# Estilos
export STYLE_BOLD='\033[1m'
export STYLE_DIM='\033[2m'
export STYLE_UNDERLINE='\033[4m'
export STYLE_BLINK='\033[5m'
export STYLE_REVERSE='\033[7m'

# Atajos comunes
export C_SUCCESS="$COLOR_BRIGHT_GREEN"
export C_ERROR="$COLOR_BRIGHT_RED"
export C_WARNING="$COLOR_BRIGHT_YELLOW"
export C_INFO="$COLOR_BRIGHT_CYAN"
export C_PROMPT="$COLOR_BRIGHT_MAGENTA"
export C_HEADER="$COLOR_BRIGHT_BLUE"
export NC="$COLOR_RESET"

# ============================================================================
# CONFIGURACIÓN DEL SISTEMA
# ============================================================================
export NEA_VERSION="3.0"
export NEA_CODENAME="Nexus"
export NEA_MAX_LEVEL=7
export NEA_XP_PER_LEVEL=100

# Comandos por nivel (separados por coma)
export NEA_LEVEL_1_COMMANDS="cd,pwd"
export NEA_LEVEL_2_COMMANDS="ls"
export NEA_LEVEL_3_COMMANDS="file"
export NEA_LEVEL_4_COMMANDS="cat,grep"
export NEA_LEVEL_5_COMMANDS="cp,mv,mkdir"
export NEA_LEVEL_6_COMMANDS="rm,rmdir"
export NEA_LEVEL_7_COMMANDS="touch,echo,chmod,bash"

# Explicaciones de comandos en español
export CMD_EXPLAIN_CD="Change Directory - Cambiar de carpeta"
export CMD_EXPLAIN_PWD="Print Working Directory - Mostrar ubicación actual"
export CMD_EXPLAIN_LS="List - Listar archivos y carpetas"
export CMD_EXPLAIN_CAT="Concatenate - Ver/Mostrar contenido de archivos"
export CMD_EXPLAIN_GREP="Buscar texto dentro de archivos"
export CMD_EXPLAIN_CP="Copy - Copiar archivos"
export CMD_EXPLAIN_MV="Move - Mover o renombrar archivos"
export CMD_EXPLAIN_MKDIR="Make Directory - Crear carpeta nueva"
export CMD_EXPLAIN_RM="Remove - Borrar archivo (¡CUIDADO!)"
export CMD_EXPLAIN_RMDIR="Remove Directory - Borrar carpeta vacía"
export CMD_EXPLAIN_TOUCH="Crear archivo vacío"
export CMD_EXPLAIN_ECHO="Imprimir texto en pantalla"
export CMD_EXPLAIN_CHMOD="Change Mode - Cambiar permisos de archivo"
export CMD_EXPLAIN_FILE="Identificar tipo de archivo"

# ============================================================================
# MENSAJES DEL SISTEMA
# ============================================================================
export MSG_WELCOME="Bienvenido al Sistema NEA Shell"
export MSG_MISSION_START="Iniciando misión..."
export MSG_MISSION_COMPLETE="¡Misión completada!"
export MSG_LEVEL_UP="¡SUBISTE DE NIVEL!"
export MSG_XP_GAINED="XP ganado"
export MSG_ERROR_GENERIC="Ha ocurrido un error"
export MSG_CONNECTION_REQUIRED="Se requiere conexión a internet"

# ============================================================================
# ARTE ASCII - BANNERS
# ============================================================================
export NEA_BANNER='
╔═══════════════════════════════════════════════════════════════╗
║                                                               ║
║   ███╗   ██╗███████╗ █████╗     ███████╗██╗  ██╗███████╗██╗  ║
║   ████╗  ██║██╔════╝██╔══██╗    ██╔════╝██║  ██║██╔════╝██║  ║
║   ██╔██╗ ██║█████╗  ███████║    ███████╗███████║█████╗  ██║  ║
║   ██║╚██╗██║██╔══╝  ██╔══██║    ╚════██║██╔══██║██╔══╝  ██║  ║
║   ██║ ╚████║███████╗██║  ██║    ███████║██║  ██║███████╗███████╗
║   ╚═╝  ╚═══╝╚══════╝╚═╝  ╚═╝    ╚══════╝╚═╝  ╚═╝╚══════╝╚══════╝
║                                                               ║
║          Sistema de Entrenamiento en Terminal v3.0           ║
║              Nueva Escuela Argentina - Makerspace            ║
╚═══════════════════════════════════════════════════════════════╝
'

export NEA_SMALL_LOGO='
    _   _ _____   _    
   | \ | | ____| / \   
   |  \| |  _|  / _ \  
   | |\  | |___ / ___ \ 
   |_| \_|_____/_/   \_\
'

# ============================================================================
# BADGES Y LOGROS
# ============================================================================
export BADGE_FIRST_STEPS="🐣 Primeros Pasos"
export BADGE_NAVIGATOR="🧭 Navegante"
export BADGE_EXPLORER="🔍 Explorador"
export BADGE_READER="📖 Lector"
export BADGE_ORGANIZER="📁 Organizador"
export BADGE_CAREFUL="⚠️  Cuidadoso"
export BADGE_SCRIPTER="📜 Scripter"
export BADGE_SPEEDRUN="⚡ Velocista"
export BADGE_PERFECTIONIST="💎 Perfeccionista"
export BADGE_PERSISTENT="🔥 Persistente"

# ============================================================================
# FUNCIONES DE UTILIDAD
# ============================================================================

# Imprimir con color
print_color() {
    local color="$1"
    local message="$2"
    echo -e "${color}${message}${NC}"
}

# Mostrar banner principal
show_banner() {
    clear
    echo -e "${C_HEADER}${NEA_BANNER}${NC}"
}

# Mostrar logo pequeño
show_small_logo() {
    echo -e "${C_HEADER}${NEA_SMALL_LOGO}${NC}"
}

# Mostrar mensaje de éxito
success() {
    echo -e "${C_SUCCESS}✓${NC} $1"
}

# Mostrar mensaje de error
error() {
    echo -e "${C_ERROR}✗${NC} $1"
}

# Mostrar advertencia
warning() {
    echo -e "${C_WARNING}⚠${NC} $1"
}

# Mostrar información
info() {
    echo -e "${C_INFO}ℹ${NC} $1"
}

# Separador visual
separator() {
    echo -e "${COLOR_CYAN}═══════════════════════════════════════════════════════════════${NC}"
}

# Línea delgada
line() {
    echo -e "${COLOR_CYAN}───────────────────────────────────────────────────────────────${NC}"
}

# Pausar hasta que el usuario presione Enter
pause() {
    local message="${1:-Presiona ENTER para continuar...}"
    echo -e "\n${C_PROMPT}${message}${NC}"
    read
}

# Limpiar pantalla y mostrar logo
reset_screen() {
    clear
    show_small_logo
    separator
}

# Obtener grado del usuario actual
get_user_grade() {
    case "$NEA_CURRENT_USER" in
        grado_1ro) echo "1ro" ;;
        grado_2do) echo "2do" ;;
        grado_3ro) echo "3ro" ;;
        grado_4to) echo "4to" ;;
        grado_5to) echo "5to" ;;
        grado_6to) echo "6to" ;;
        *) echo "unknown" ;;
    esac
}

# Calcular nivel basado en XP
calculate_level() {
    local xp="$1"
    local level=$((xp / NEA_XP_PER_LEVEL + 1))
    
    if [ $level -gt $NEA_MAX_LEVEL ]; then
        level=$NEA_MAX_LEVEL
    fi
    
    echo "$level"
}

# Calcular XP necesario para próximo nivel
xp_to_next_level() {
    local current_xp="$1"
    local current_level=$(calculate_level "$current_xp")
    local next_level_xp=$((current_level * NEA_XP_PER_LEVEL))
    local needed=$((next_level_xp - current_xp))
    
    echo "$needed"
}

# Barra de progreso
progress_bar() {
    local current="$1"
    local total="$2"
    local width=50
    local percentage=$((current * 100 / total))
    local filled=$((width * current / total))
    local empty=$((width - filled))
    
    echo -n "["
    for ((i=0; i<filled; i++)); do echo -n "█"; done
    for ((i=0; i<empty; i++)); do echo -n "░"; done
    echo -n "] ${percentage}%"
}

# Logging
log_action() {
    local student="$1"
    local action="$2"
    local logfile="/var/log/nea_shell.log"
    
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] [$student] $action" >> "$logfile" 2>/dev/null
}

# Verificar si un comando está disponible
command_available() {
    command -v "$1" >/dev/null 2>&1
}

# ============================================================================
# INICIALIZACIÓN
# ============================================================================

# Crear directorios si no existen
mkdir -p "$NEA_STUDENTS_DIR" 2>/dev/null
mkdir -p "$NEA_MISSIONS_DIR" 2>/dev/null

# Exportar funciones para que estén disponibles en subshells
export -f print_color
export -f show_banner
export -f show_small_logo
export -f success
export -f error
export -f warning
export -f info
export -f separator
export -f line
export -f pause
export -f reset_screen
export -f get_user_grade
export -f calculate_level
export -f xp_to_next_level
export -f progress_bar
export -f log_action
export -f command_available

# Mensaje de carga (solo para debug)
# echo "NEA Environment loaded v${NEA_VERSION}"
