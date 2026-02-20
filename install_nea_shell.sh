#!/bin/bash
# ==============================================================================
# SCRIPT DE INSTALACIÓN MAESTRA - NEA Shell
# ==============================================================================

# Estado de instalación
STATE_FILE="/var/lib/nea_shell_install_state"
REPO_DIR="/opt/nea_shell"
PASSWORD_FILE="/root/nea_passwords.txt"

# Colores para output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Función para logging
log_info() {
    echo -e "${BLUE}ℹ${NC} $1"
}

log_success() {
    echo -e "${GREEN}✓${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

log_error() {
    echo -e "${RED}✗${NC} $1"
}

# ==============================================================================
# PRE-FLIGHT CHECKS
# ==============================================================================

# Verificar si estamos corriendo como root
if [[ $EUID -ne 0 ]]; then
    echo ""
    log_error "Este script debe ejecutarse como root."
    echo ""
    
    # Verificar si sudo está disponible
    if command -v sudo &>/dev/null; then
        log_info "Detectado 'sudo' disponible. Intenta ejecutar:"
        echo "  sudo bash $0"
    else
        log_warning "'sudo' no está instalado en este sistema."
        log_info "Opciones para ejecutar como root:"
        echo ""
        echo "  Opción 1 - Cambiar a root temporalmente:"
        echo "    su -"
        echo "    bash $0"
        echo ""
        echo "  Opción 2 - Instalar sudo (como root):"
        echo "    su -"
        echo "    apt update && apt install -y sudo"
        echo "    usermod -aG sudo $(logname)"
        echo "    exit"
        echo "    # Luego cierra sesión y vuelve a iniciar"
    fi
    echo ""
    exit 1
fi

# Verificar conectividad a internet
check_internet() {
    log_info "Verificando conectividad a internet..."
    
    local test_urls=("8.8.8.8" "1.1.1.1" "github.com")
    local connected=false
    
    for url in "${test_urls[@]}"; do
        if ping -c 1 -W 2 "$url" &>/dev/null; then
            connected=true
            break
        fi
    done
    
    if [ "$connected" = false ]; then
        log_error "No se detectó conexión a internet."
        log_info "El sistema NEA Shell requiere conexión para la instalación inicial."
        echo ""
        log_info "Verifica tu conexión e intenta nuevamente."
        log_info "Si estás en una netbook, puedes usar: nmtui (NetworkManager)"
        exit 1
    fi
    
    log_success "Conexión a internet verificada"
}

# Instalar paquete si no está presente
ensure_package() {
    local package="$1"
    local description="$2"
    
    if ! command -v "$package" &>/dev/null && ! dpkg -l | grep -q "^ii  $package "; then
        log_info "Instalando $description ($package)..."
        
        if apt install -y "$package" 2>/dev/null; then
            log_success "$description instalado correctamente"
        else
            log_error "Error instalando $description"
            return 1
        fi
    fi
    return 0
}

# Actualizar índice de paquetes
update_package_index() {
    if is_completed "pkg_index_updated"; then
        return 0
    fi
    
    log_info "Actualizando índice de paquetes (esto puede tomar un momento)..."
    
    if apt update; then
        mark_completed "pkg_index_updated"
        log_success "Índice de paquetes actualizado"
        return 0
    else
        log_error "Error actualizando índice de paquetes"
        log_warning "Continuando de todas formas, pero puede haber errores..."
        return 1
    fi
}

# Crear directorio para estado si no existe
mkdir -p "$(dirname "$STATE_FILE")"

# Cargar estado previo
declare -A COMPLETED_STEPS
if [ -f "$STATE_FILE" ]; then
    while IFS='=' read -r key value; do
        COMPLETED_STEPS["$key"]="$value"
    done < "$STATE_FILE"
fi

# Marcar paso como completado
mark_completed() {
    COMPLETED_STEPS["$1"]="done"
    # Evitar duplicados
    grep -v "^$1=" "$STATE_FILE" > "${STATE_FILE}.tmp" 2>/dev/null || true
    mv "${STATE_FILE}.tmp" "$STATE_FILE" 2>/dev/null || true
    echo "$1=done" >> "$STATE_FILE"
}

# Desmarcar paso (para re-ejecución)
unmark_step() {
    unset COMPLETED_STEPS["$1"]
    grep -v "^$1=" "$STATE_FILE" > "${STATE_FILE}.tmp" 2>/dev/null || true
    mv "${STATE_FILE}.tmp" "$STATE_FILE" 2>/dev/null || true
}

# Verificar si un paso está completado
is_completed() {
    [[ "${COMPLETED_STEPS[$1]}" == "done" ]]
}

# Prompt interactivo con default
ask_yes_no() {
    local prompt="$1"
    local default="${2:-n}"
    local response
    
    if [[ "$default" == "y" ]]; then
        prompt="$prompt [S/n]: "
    else
        prompt="$prompt [s/N]: "
    fi
    
    read -r -p "$prompt" response
    response=${response:-$default}
    
    [[ "$response" =~ ^[SsYy]$ ]]
}

echo ""
echo "╔════════════════════════════════════════════════════════════╗"
echo "║         INSTALACIÓN DE NEA Shell - Sistema Educativo       ║"
echo "╚════════════════════════════════════════════════════════════╝"
echo ""

# Verificar estado previo de instalación
if [ -f "$STATE_FILE" ]; then
    log_info "Detectada instalación previa."
    echo ""
    
    # Mostrar menú de selección de pasos
    echo "Seleccione qué pasos desea ejecutar:"
    echo ""
    echo "  1) Ejecutar todos los pasos pendientes (continuar instalación)"
    echo "  2) Re-ejecutar pasos específicos"
    echo "  3) Empezar desde cero (borrar estado y re-instalar todo)"
    echo "  4) Salir"
    echo ""
    read -r -p "Seleccione una opción [1-4]: " MENU_CHOICE
    
    case $MENU_CHOICE in
        2)
            echo ""
            echo "Seleccione los pasos a re-ejecutar (separados por espacios):"
            echo ""
            echo "  0) Pre-requisitos"
            echo "  1) Dependencias"
            echo "  2) Repositorio"
            echo "  3) Usuarios y contraseñas"
            echo "  4) Servicio auto-update"
            echo "  5) Sincronización de datos"
            echo "  6) Finalización"
            echo ""
            read -r -p "Números de pasos (ej: 3 5): " -a STEPS_TO_RERUN
            
            # Desmarcar los pasos seleccionados
            for step_num in "${STEPS_TO_RERUN[@]}"; do
                case $step_num in
                    0) unmark_step "prerequisites"; unmark_step "pkg_index_updated" ;;
                    1) unmark_step "dependencies" ;;
                    2) unmark_step "repository" ;;
                    3) unmark_step "users" ;;
                    4) unmark_step "autoupdate" ;;
                    5) unmark_step "sync" ;;
                    6) unmark_step "finalize" ;;
                esac
            done
            
            echo ""
            log_success "Pasos seleccionados se ejecutarán nuevamente"
            sleep 2
            ;;
        3)
            echo ""
            log_warning "Esto borrará todo el estado de instalación."
            if ask_yes_no "¿Está seguro?" "n"; then
                rm -f "$STATE_FILE"
                declare -A COMPLETED_STEPS=()
                log_success "Estado borrado. Iniciando instalación completa..."
                sleep 2
            else
                log_info "Operación cancelada"
                exit 0
            fi
            ;;
        4)
            log_info "Saliendo..."
            exit 0
            ;;
        1|*)
            log_info "Continuando instalación..."
            ;;
    esac
    echo ""
fi

# Verificar que git está disponible (prerequisito para obtener el script)
if ! command -v git &>/dev/null; then
    log_error "Git no está instalado."
    log_error "Git es necesario para clonar el repositorio de NEA Shell."
    echo ""
    log_info "Para instalar git, ejecuta como root:"
    echo "  apt update && apt install -y git"
    echo ""
    log_info "Luego vuelve a ejecutar este script."
    exit 1
fi

log_success "Git detectado: $(git --version)"

# Verificar internet
check_internet

# Actualizar índice de paquetes
update_package_index

# Lista de paquetes esenciales (sin git, ya es prerequisito)
declare -A ESSENTIAL_PACKAGES=(
    ["curl"]="Herramienta de transferencia de datos"
    ["wget"]="Descargador de archivos"
    ["openssl"]="Herramientas criptográficas"
    ["sudo"]="Ejecutar comandos con privilegios"
)

log_info "Instalando herramientas esenciales..."

for package in "${!ESSENTIAL_PACKAGES[@]}"; do
    ensure_package "$package" "${ESSENTIAL_PACKAGES[$package]}"
done

# Verificar que el usuario que invocó sudo existe
if [ -n "$SUDO_USER" ]; then
    log_info "Configurando sudo para usuario: $SUDO_USER"
    
    # Agregar usuario al grupo sudo si no está
    if ! groups "$SUDO_USER" | grep -q sudo; then
        usermod -aG sudo "$SUDO_USER"
        log_success "Usuario $SUDO_USER agregado al grupo sudo"
        log_warning "Nota: Necesitarás cerrar sesión y volver a iniciar para que los cambios surtan efecto"
    fi
fi

mark_completed "prerequisites"
log_success "Pre-requisitos verificados e instalados"

# ==============================================================================
# PASO 1: DEPENDENCIAS
# ==============================================================================
if is_completed "dependencies"; then
    log_success "[1/6] Dependencias ya instaladas (omitiendo)"
else
    echo ""
    log_info "[1/6] Instalando dependencias de NEA Shell..."
    
    # Asegurar que el índice esté actualizado
    if ! is_completed "pkg_index_updated"; then
        update_package_index
    fi
    
    # Paquetes requeridos para NEA Shell
    declare -A NEA_PACKAGES=(
        ["network-manager"]="Gestor de redes"
        ["pv"]="Monitor de progreso para pipes"
        ["jq"]="Procesador JSON en línea de comandos"
        ["xinit"]="Inicializador de X Window"
    )
    
    local failed_packages=()
    
    for package in "${!NEA_PACKAGES[@]}"; do
        if ! ensure_package "$package" "${NEA_PACKAGES[$package]}"; then
            failed_packages+=("$package")
        fi
    done
    
    if [ ${#failed_packages[@]} -gt 0 ]; then
        log_error "No se pudieron instalar algunos paquetes: ${failed_packages[*]}"
        
        if ask_yes_no "¿Desea continuar de todas formas?" "n"; then
            log_warning "Continuando sin algunos paquetes. Algunas funciones pueden no estar disponibles."
        else
            log_error "Instalación cancelada."
            exit 1
        fi
    fi
    
    mark_completed "dependencies"
    log_success "Dependencias instaladas correctamente"
fi

# ==============================================================================
# PASO 2: REPOSITORIO
# ==============================================================================
if is_completed "repository"; then
    log_success "[2/6] Repositorio ya configurado (omitiendo)"
else
    echo ""
    log_info "[2/6] Configurando repositorio NEA Shell..."
    REPO_URL="https://github.com/lucasgonzalez939/NEA_Shell.git"
    
    # Verificar que git está disponible
    if ! command -v git &>/dev/null; then
        log_error "Git no está disponible. No se puede continuar."
        exit 1
    fi
    
    if [ ! -d "$REPO_DIR" ]; then
        log_info "Clonando repositorio desde GitHub..."
        
        if git clone "$REPO_URL" "$REPO_DIR"; then
            log_success "Repositorio clonado correctamente"
        else
            log_error "Error clonando repositorio"
            log_info "Verifica tu conexión a internet e intenta nuevamente"
            exit 1
        fi
    else
        log_info "Actualizando repositorio existente..."
        cd "$REPO_DIR" && git pull
        log_success "Repositorio actualizado"
    fi
    
    chmod +x "$REPO_DIR"/*.sh 2>/dev/null || true
    chmod +x "$REPO_DIR/scripts"/*.sh 2>/dev/null || true
    
    # Crear directorio de scripts si no existe
    mkdir -p "$REPO_DIR/scripts"
    
    # Enlaces simbólicos (verificar que existen antes de crear)
    declare -A SYMLINKS=(
        ["$REPO_DIR/scripts/nea_tour.sh"]="/usr/local/bin/nea_tour"
        ["$REPO_DIR/scripts/nea_login.sh"]="/usr/local/bin/nea_login"
        ["$REPO_DIR/scripts/nea_wifi.sh"]="/usr/local/bin/nea_wifi"
        ["$REPO_DIR/scripts/nea_sync.sh"]="/usr/local/bin/nea_sync"
        ["$REPO_DIR/scripts/nea_restore.sh"]="/usr/local/bin/nea_restore"
        ["$REPO_DIR/scripts/nea_report.sh"]="/usr/local/bin/nea_report"
    )
    
    for source in "${!SYMLINKS[@]}"; do
        target="${SYMLINKS[$source]}"
        
        if [ -f "$source" ]; then
            ln -sf "$source" "$target"
        else
            log_warning "Script no encontrado: $source (será creado en actualizaciones futuras)"
        fi
    done
    
    mark_completed "repository"
    log_success "Enlaces simbólicos creados"
fi

# ==============================================================================
# PASO 3: USUARIOS
# ==============================================================================
if is_completed "users"; then
    log_success "[3/6] Usuarios ya configurados (omitiendo)"
else
    echo ""
    log_info "[3/6] Configurando usuarios de NEA Shell..."
    GRADES=("1ro" "2do" "3ro" "4to" "5to" "6to")
    
    # Verificar si el archivo de contraseñas existe
    if [ -f "$PASSWORD_FILE" ]; then
        log_warning "Archivo de contraseñas existente encontrado"
        if ask_yes_no "¿Desea regenerar las contraseñas?" "n"; then
            echo "=== CONTRASEÑAS DE NEA SHELL ===" > "$PASSWORD_FILE"
            echo "Regeneradas el: $(date)" >> "$PASSWORD_FILE"
            echo "----------------------------------------" >> "$PASSWORD_FILE"
            REGENERATE_PASSWORDS=true
        else
            log_info "Manteniendo contraseñas existentes"
            REGENERATE_PASSWORDS=false
        fi
    else
        echo "=== CONTRASEÑAS DE NEA SHELL ===" > "$PASSWORD_FILE"
        echo "Generadas el: $(date)" >> "$PASSWORD_FILE"
        echo "----------------------------------------" >> "$PASSWORD_FILE"
        REGENERATE_PASSWORDS=true
    fi
    
    for GRADE in "${GRADES[@]}"; do
        USERNAME="grado_$GRADE"
        
        if id "$USERNAME" &>/dev/null; then
            log_info "Usuario $USERNAME ya existe"
            
            # Si regeneramos passwords, actualizar REALMENTE la contraseña del sistema
            if [ "$REGENERATE_PASSWORDS" = true ]; then
                PASS=$(openssl rand -base64 9 | tr -dc 'a-zA-Z0-9' | head -c 6)
                
                # Cambiar contraseña del sistema
                echo "$USERNAME:$PASS" | chpasswd
                
                # Guardar en archivo
                echo "$USERNAME -> $PASS" >> "$PASSWORD_FILE"
                log_success "Contraseña actualizada para $USERNAME: $PASS"
            else
                log_info "Contraseña de $USERNAME no modificada"
            fi
        else
            # Generar contraseña aleatoria de 6 caracteres (letras y números)
            PASS=$(openssl rand -base64 9 | tr -dc 'a-zA-Z0-9' | head -c 6)
            
            # Crear usuario
            useradd -m -s /bin/bash "$USERNAME"
            
            # Establecer contraseña
            echo "$USERNAME:$PASS" | chpasswd
            
            # Guardar en archivo seguro
            echo "$USERNAME -> $PASS" >> "$PASSWORD_FILE"
            log_success "Usuario $USERNAME creado con contraseña: $PASS"
        fi
        
        # Auto-login al portal NEA Shell
        BASHRC="/home/$USERNAME/.bashrc"
        if ! grep -q "nea_login" "$BASHRC" 2>/dev/null; then
            echo -e "\n# NEA Shell Auto-Login" >> "$BASHRC"
            echo "if [ -f /usr/local/bin/nea_login ]; then" >> "$BASHRC"
            echo "    source /usr/local/bin/nea_login" >> "$BASHRC"
            echo "fi" >> "$BASHRC"
        fi
        
        mkdir -p "/home/$USERNAME/students" "/home/$USERNAME/missions"
        chown root:root "/home/$USERNAME/missions" 2>/dev/null || true
        chown -R "$USERNAME:$USERNAME" "/home/$USERNAME/students"
    done
    
    # Asegurar permisos del archivo de contraseñas
    chmod 600 "$PASSWORD_FILE"
    
    # Configurar pantalla de bienvenida pre-login
    log_info "Configurando pantalla de bienvenida..."
    
    # Crear issue (mensaje pre-login)
    cat > /etc/issue << 'EOF'

    ███╗   ██╗███████╗ █████╗     ███████╗██╗  ██╗███████╗██╗     ██╗     
    ████╗  ██║██╔════╝██╔══██╗    ██╔════╝██║  ██║██╔════╝██║     ██║     
    ██╔██╗ ██║█████╗  ███████║    ███████╗███████║█████╗  ██║     ██║     
    ██║╚██╗██║██╔══╝  ██╔══██║    ╚════██║██╔══██║██╔══╝  ██║     ██║     
    ██║ ╚████║███████╗██║  ██║    ███████║██║  ██║███████╗███████╗███████╗
    ╚═╝  ╚═══╝╚══════╝╚═╝  ╚═╝    ╚══════╝╚═╝  ╚═╝╚══════╝╚══════╝╚══════╝
                                                                          
    ════════════════════════════════════════════════════════════════════════
              🚀 SISTEMA DE ENTRENAMIENTO EN TERMINAL 🚀
    ════════════════════════════════════════════════════════════════════════

    👋 ¡Hola, Agente!

    📖 INSTRUCCIONES PARA INGRESAR:

       1️⃣  Tu usuario es: grado_1ro (o 2do, 3ro, etc. según tu grado)
       2️⃣  La contraseña te la dará tu profesor/a
       3️⃣  Escribe tu usuario y presiona ENTER
       4️⃣  Escribe tu contraseña y presiona ENTER
           (No verás lo que escribes, ¡es secreto! 🤫)

    💡 CONSEJOS:
       • Lee todo con atención
       • Escribe exactamente lo que ves
       • Si te equivocas, vuelve a intentar
       • ¡Diviértete aprendiendo!

    ════════════════════════════════════════════════════════════════════════

EOF
    
    # Crear MOTD (mensaje después del login)
    cat > /etc/motd << 'EOF'

    ╔════════════════════════════════════════════════════════════════════╗
    ║                    ✨ BIENVENIDO A NEA SHELL ✨                    ║
    ╚════════════════════════════════════════════════════════════════════╝

    🎯 MISIÓN: Convertirte en un experto de la terminal

    📚 COMANDOS BÁSICOS PARA EMPEZAR:
       • nea_tour  → Comenzar las misiones
       • pwd       → ¿Dónde estoy?
       • ls        → ¿Qué hay aquí?
       • cd        → Cambiar de carpeta
       • clear     → Limpiar la pantalla

    💪 CONSEJOS DE AGENTE EXPERTO:
       ✓ Lee cada instrucción completa antes de escribir
       ✓ Usa TAB para autocompletar nombres de archivos
       ✓ Usa las flechas ↑↓ para ver comandos anteriores
       ✓ Si algo no funciona, lee el mensaje de error

    🏆 TU PROGRESO:
       • Nivel actual: Se carga al ejecutar nea_tour
       • XP ganado: Completa misiones para ganar experiencia

    ════════════════════════════════════════════════════════════════════════
    🚀 Ejecuta 'nea_tour' para comenzar tu primera misión
    ════════════════════════════════════════════════════════════════════════

EOF
    
    log_success "Pantallas de bienvenida configuradas"
    
    mark_completed "users"
    log_success "Usuarios configurados correctamente"
    log_info "Contraseñas guardadas en: $PASSWORD_FILE"
fi

# ==============================================================================
# PASO 4: SERVICIO AUTO-UPDATE
# ==============================================================================
if is_completed "autoupdate"; then
    log_success "[4/6] Servicio de auto-actualización ya configurado (omitiendo)"
else
    echo ""
    log_info "[4/6] Activando NEA Sync Service..."
    
    cat <<EOF > /etc/systemd/system/nea-sync.service
[Unit]
Description=Actualización automática de NEA Shell
After=network-online.target
Wants=network-online.target

[Service]
Type=oneshot
ExecStart=/usr/local/bin/nea_sync
RemainAfterExit=yes

[Install]
WantedBy=multi-user.target
EOF
    
    systemctl daemon-reload
    systemctl enable nea-sync.service
    
    mark_completed "autoupdate"
    log_success "Servicio de auto-actualización activado"
fi

# ==============================================================================
# PASO 5: SINCRONIZACIÓN DE DATOS
# ==============================================================================
if is_completed "sync"; then
    log_success "[5/6] Sincronización ya configurada (omitiendo)"
else
    echo ""
    echo "╔════════════════════════════════════════════════════════════╗"
    echo "║           CONFIGURACIÓN DE SINCRONIZACIÓN DE DATOS         ║"
    echo "╚════════════════════════════════════════════════════════════╝"
    echo ""
    log_info "[5/6] Seleccione el método de sincronización:"
    echo ""
    echo "  1) Syncthing (P2P, automático, requiere configuración manual)"
    echo "  2) NFS (Cliente de red compartida, requiere servidor NFS)"
    echo "  3) Ninguno (configurar más tarde)"
    echo ""
    read -r -p "Seleccione una opción [1/2/3]: " SYNC_CHOICE
    
    case $SYNC_CHOICE in
        1)
            log_info "Configurando Syncthing..."
            
            # Instalar Syncthing si no está instalado
            if ! command -v syncthing &>/dev/null; then
                log_info "Instalando Syncthing..."
                apt install -y syncthing
            fi
            
            # Crear usuario para Syncthing si no existe
            if ! id neahost &>/dev/null; then
                useradd -r -s /bin/false neahost
                log_success "Usuario neahost creado"
            fi
            
            # Configurar servicio
            systemctl enable syncthing@neahost.service
            systemctl start syncthing@neahost.service
            
            log_success "Syncthing instalado y ejecutándose"
            echo ""
            log_warning "CONFIGURACIÓN MANUAL REQUERIDA:"
            echo ""
            echo "  1. Espera 10 segundos a que Syncthing inicie completamente"
            echo "  2. Accede a: http://localhost:8384"
            echo "  3. Ve a Acciones → Configuración → GUI"
            echo "  4. Desactiva 'Usar HTTPS para GUI' si tienes problemas"
            echo "  5. En 'Compartir' → añade las carpetas de los usuarios"
            echo "  6. En 'Dispositivos remotos' → añade otros nodos NEA"
            echo ""
            read -r -p "Presiona ENTER cuando hayas completado la configuración manual..."
            
            mark_completed "sync"
            echo "sync_method=syncthing" >> "$STATE_FILE"
            log_success "Syncthing configurado"
            ;;
            
        2)
            log_info "Configurando cliente NFS..."
            
            # Instalar cliente NFS
            apt install -y nfs-common
            
            echo ""
            log_info "Configuración de NFS requiere la siguiente información:"
            echo ""
            read -r -p "IP del servidor NFS: " NFS_SERVER
            read -r -p "Ruta exportada en el servidor (ej: /export/nea_data): " NFS_PATH
            read -r -p "Punto de montaje local (default: /mnt/nea_shared): " MOUNT_POINT
            MOUNT_POINT=${MOUNT_POINT:-/mnt/nea_shared}
            
            # Crear punto de montaje
            mkdir -p "$MOUNT_POINT"
            
            # Agregar a fstab
            FSTAB_ENTRY="$NFS_SERVER:$NFS_PATH $MOUNT_POINT nfs defaults,_netdev 0 0"
            
            if grep -q "$NFS_SERVER:$NFS_PATH" /etc/fstab; then
                log_warning "Entrada NFS ya existe en /etc/fstab"
            else
                echo "$FSTAB_ENTRY" >> /etc/fstab
                log_success "Entrada agregada a /etc/fstab"
            fi
            
            # Intentar montar
            log_info "Intentando montar recurso NFS..."
            if mount -a; then
                log_success "NFS montado correctamente en $MOUNT_POINT"
                
                # Crear enlaces simbólicos para cada usuario
                for GRADE in 1ro 2do 3ro 4to 5to 6to; do
                    USERNAME="grado_$GRADE"
                    ln -sf "$MOUNT_POINT/$GRADE" "/home/$USERNAME/shared" 2>/dev/null || true
                done
                
                mark_completed "sync"
                echo "sync_method=nfs" >> "$STATE_FILE"
                echo "nfs_server=$NFS_SERVER" >> "$STATE_FILE"
                echo "nfs_path=$NFS_PATH" >> "$STATE_FILE"
                echo "nfs_mount=$MOUNT_POINT" >> "$STATE_FILE"
            else
                log_error "Error al montar NFS. Verifica la configuración del servidor."
                log_info "Puedes intentar manualmente: mount $NFS_SERVER:$NFS_PATH $MOUNT_POINT"
                
                if ask_yes_no "¿Desea continuar sin sincronización?" "n"; then
                    mark_completed "sync"
                    echo "sync_method=none" >> "$STATE_FILE"
                else
                    log_error "Instalación cancelada. Ejecuta el script nuevamente."
                    exit 1
                fi
            fi
            ;;
            
        3|*)
            log_info "Sincronización omitida. Puedes configurarla más tarde."
            mark_completed "sync"
            echo "sync_method=none" >> "$STATE_FILE"
            ;;
    esac
fi

# ==============================================================================
# PASO 6: FINALIZACIÓN
# ==============================================================================
if is_completed "finalize"; then
    log_success "[6/6] Instalación ya completada anteriormente"
else
    echo ""
    log_info "[6/6] Finalizando instalación..."
    
    mark_completed "finalize"
    
    echo ""
    echo "╔════════════════════════════════════════════════════════════╗"
    echo "║         ✓ INSTALACIÓN DE NEA Shell COMPLETADA             ║"
    echo "╚════════════════════════════════════════════════════════════╝"
    echo ""
    log_success "Sistema instalado correctamente"
    echo ""
    echo "📋 INFORMACIÓN IMPORTANTE:"
    echo ""
    echo "  📁 Contraseñas: $PASSWORD_FILE"
    echo "  📂 Repositorio: $REPO_DIR"
    echo "  📝 Estado: $STATE_FILE"
    echo ""
    
    # Mostrar info según método de sync
    if grep -q "sync_method=syncthing" "$STATE_FILE" 2>/dev/null; then
        echo "  🔄 Syncthing Web UI: http://localhost:8384"
        echo "  ℹ  Recuerda configurar carpetas y dispositivos remotos"
    elif grep -q "sync_method=nfs" "$STATE_FILE" 2>/dev/null; then
        NFS_MOUNT=$(grep "nfs_mount=" "$STATE_FILE" | cut -d'=' -f2)
        echo "  🔄 NFS montado en: $NFS_MOUNT"
        echo "  ℹ  Enlaces creados en /home/grado_*/shared"
    else
        echo "  ⚠  Sincronización no configurada"
        echo "  ℹ  Re-ejecuta el script para configurarla"
    fi
    
    echo ""
    echo "📌 PRÓXIMOS PASOS:"
    echo ""
    echo "  1. Revisa las contraseñas en $PASSWORD_FILE"
    echo "  2. Prueba el login: su - grado_1ro"
    echo "  3. Ejecuta el tour: nea_tour"
    
    # Advertencia sobre sudo si fue configurado durante la instalación
    if [ -n "$SUDO_USER" ] && grep -q "usermod -aG sudo" <(compgen -G "/tmp/nea_sudo_added_*" 2>/dev/null); then
        echo ""
        log_warning "Se agregó tu usuario al grupo sudo."
        log_info "Cierra sesión y vuelve a iniciar para aplicar los cambios."
    fi
    
    echo ""
    
    if ask_yes_no "¿Desea ver las contraseñas generadas ahora?" "y"; then
        echo ""
        cat "$PASSWORD_FILE"
        echo ""
    fi
fi

echo ""
log_info "Para re-ejecutar la instalación completa, elimina: $STATE_FILE"
log_info "Para ver el estado actual: cat $STATE_FILE"
echo ""