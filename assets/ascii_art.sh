#!/bin/bash
# ==============================================================================
# NEA Shell - ARTE ASCII Y BANNERS
# ==============================================================================

# Banner principal del sistema
show_main_banner() {
    cat << "EOF"
    ███╗   ██╗███████╗ █████╗     ███████╗██╗  ██╗███████╗██╗     ██╗     
    ████╗  ██║██╔════╝██╔══██╗    ██╔════╝██║  ██║██╔════╝██║     ██║     
    ██╔██╗ ██║█████╗  ███████║    ███████╗███████║█████╗  ██║     ██║     
    ██║╚██╗██║██╔══╝  ██╔══██║    ╚════██║██╔══██║██╔══╝  ██║     ██║     
    ██║ ╚████║███████╗██║  ██║    ███████║██║  ██║███████╗███████╗███████╗
    ╚═╝  ╚═══╝╚══════╝╚═╝  ╚═╝    ╚══════╝╚═╝  ╚═╝╚══════╝╚══════╝╚══════╝
                                                                            
            🎯 Sistema de Entrenamiento - Nueva Escuela Argentina
EOF
}

# Banner de bienvenida
show_welcome_banner() {
    cat << "EOF"
    ╔═══════════════════════════════════════════════════════════════════╗
    ║                                                                   ║
    ║                    ¡BIENVENIDO, AGENTE!                          ║
    ║                                                                   ║
    ║   Estás a punto de iniciar tu entrenamiento en el sistema CLI    ║
    ║   Completa misiones, gana XP y desbloquea nuevas habilidades     ║
    ║                                                                   ║
    ╚═══════════════════════════════════════════════════════════════════╝
EOF
}

# Banner de nivel completado
show_level_up_banner() {
    cat << "EOF"
    ⠀⠀⠀⠀⠀⠀⠀⢀⣀⣀⣀⣀⣀⣀⣀⣀⣀⣀⡀⠀⠀⠀⠀⠀⠀⠀
    ⠀⠀⠀⠀⠀⣠⣾⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣷⣄⠀⠀⠀⠀⠀
    ⠀⠀⠀⠀⣸⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣧⠀⠀⠀⠀
    ⠀⠀⠀⠀⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠀⠀⠀⠀
    ⠀⠀⠀⠀⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠀⠀⠀⠀
    ⠀⠀⠀⠀⠹⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠏⠀⠀⠀⠀
    ⠀⠀⠀⠀⠀⠈⠻⢿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡿⠟⠁⠀⠀⠀⠀⠀
    ⠀⠀⠀⠀⠀⠀⠀⠀⠈⠉⠛⠛⠛⠛⠛⠛⠉⠁⠀⠀⠀⠀⠀⠀⠀⠀
    
               🎉 ¡SUBISTE DE NIVEL! 🎉
EOF
}

# Badge: Primeros pasos
show_badge_first_steps() {
    cat << "EOF"
        🐣
      PRIMEROS
       PASOS
EOF
}

# Badge: Explorador
show_badge_explorer() {
    cat << "EOF"
        🔍
     EXPLORADOR
EOF
}

# Badge: Maestro de archivos
show_badge_file_master() {
    cat << "EOF"
        📁
      MAESTRO
        DE
     ARCHIVOS
EOF
}

# Badge: Destructor
show_badge_destroyer() {
    cat << "EOF"
        💣
    DESTRUCTOR
EOF
}

# Badge: Programador
show_badge_programmer() {
    cat << "EOF"
        💻
    PROGRAMADOR
EOF
}

# Animación de carga
show_loading_animation() {
    local message="${1:-Cargando}"
    local duration="${2:-2}"
    
    echo -n "$message "
    for i in $(seq 1 $duration); do
        echo -n "."
        sleep 0.5
    done
    echo " ✓"
}

# Barra de progreso animada
show_progress_animation() {
    local current=$1
    local total=$2
    local width=50
    local percentage=$((current * 100 / total))
    local filled=$((current * width / total))
    
    printf "\r["
    for ((i=0; i<filled; i++)); do printf "█"; done
    for ((i=filled; i<width; i++)); do printf "░"; done
    printf "] %d%%" "$percentage"
}

# Celebración ASCII
show_celebration() {
    cat << "EOF"
        🎊 🎉 🎊 🎉 🎊 🎉 🎊
       ✨  ¡MISIÓN COMPLETADA!  ✨
        🎊 🎉 🎊 🎉 🎊 🎉 🎊
EOF
}

# Logo pequeño para el prompt
show_mini_logo() {
    echo "🎯 NEA"
}

# Separador decorativo
show_separator() {
    echo "════════════════════════════════════════════════════════════════════"
}

# Mensaje de despedida
show_goodbye_banner() {
    cat << "EOF"
    ╔═══════════════════════════════════════════════════════════════════╗
    ║                                                                   ║
    ║              👋 ¡Hasta luego, Agente!                            ║
    ║                                                                   ║
    ║        Tu progreso ha sido guardado automáticamente.             ║
    ║        Vuelve pronto para continuar tu entrenamiento.            ║
    ║                                                                   ║
    ╚═══════════════════════════════════════════════════════════════════╝
EOF
}

# Mensaje motivacional aleatorio
show_motivational_message() {
    local messages=(
        "💪 ¡Sigue así! Cada comando te hace más fuerte."
        "🧠 El conocimiento es poder. ¡Y tú estás ganando ambos!"
        "🚀 Los grandes programadores también empezaron aquí."
        "⚡ La práctica hace al maestro. ¡No te rindas!"
        "🌟 Cada error es una oportunidad de aprender."
        "🎯 Tu determinación es admirable, Agente."
        "🔥 ¡Estás en llamas! Continúa así."
        "💡 Un pequeño paso para ti, un gran salto para tu aprendizaje."
    )
    
    local random_index=$((RANDOM % ${#messages[@]}))
    echo "${messages[$random_index]}"
}

# Exportar funciones para que otros scripts puedan usarlas
export -f show_main_banner
export -f show_welcome_banner
export -f show_level_up_banner
export -f show_celebration
export -f show_goodbye_banner
export -f show_motivational_message
export -f show_separator
export -f show_mini_logo
export -f show_loading_animation
export -f show_progress_animation
