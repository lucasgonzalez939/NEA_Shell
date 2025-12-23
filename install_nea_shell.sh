#!/bin/bash
# ==============================================================================
# SCRIPT DE INSTALACIÓN MAESTRA - NEA Shell
# ==============================================================================

if [[ $EUID -ne 0 ]]; then
   echo "Este script debe ejecutarse como root (sudo)."
   exit 1
fi

echo "=== INICIANDO INSTALACIÓN: NEA Shell ==="

# 1. DEPENDENCIAS
echo "--- [1/6] Instalando herramientas..."
apt update && apt install -y git network-manager pv jq xinit

# 2. REPOSITORIO DE LUCAS GONZALEZ
echo "--- [2/6] Configurando repositorio NEA Shell..."
REPO_URL="https://github.com/lucasgonzalez939/NEA_Shell.git"
REPO_DIR="/opt/nea_shell"

if [ ! -d "$REPO_DIR" ]; then
    git clone "$REPO_URL" "$REPO_DIR"
else
    cd "$REPO_DIR" && git pull
fi

chmod +x "$REPO_DIR"/*.sh
chmod +x "$REPO_DIR/scripts"/*.sh

# Enlaces simbólicos para que los comandos funcionen desde cualquier lugar
ln -sf "$REPO_DIR/scripts/nea_tour.sh" /usr/local/bin/nea_tour
ln -sf "$REPO_DIR/scripts/nea_login.sh" /usr/local/bin/nea_login
ln -sf "$REPO_DIR/scripts/nea_wifi.sh" /usr/local/bin/nea_wifi
ln -sf "$REPO_DIR/scripts/nea_sync.sh" /usr/local/bin/nea_sync
ln -sf "$REPO_DIR/scripts/nea_restore.sh" /usr/local/bin/nea_restore
ln -sf "$REPO_DIR/scripts/nea_report.sh" /usr/local/bin/nea_report
ln -sf "$REPO_DIR/scripts/nea_syncthing.sh" /usr/local/bin/nea_syncthing

# 3. USUARIOS DE GRADO
echo "--- [3/6] Configurando usuarios de NEA Shell..."
GRADES=("1ro" "2do" "3ro" "4to" "5to" "6to")

# Crear archivo de contraseñas seguro
PASSWORD_FILE="/root/nea_passwords.txt"
echo "=== CONTRASEÑAS DE NEA SHELL ===" > "$PASSWORD_FILE"
echo "Generadas el: $(date)" >> "$PASSWORD_FILE"
echo "----------------------------------------" >> "$PASSWORD_FILE"

for GRADE in "${GRADES[@]}"; do
    USERNAME="grado_$GRADE"
    
    # Generar contraseña aleatoria de 12 caracteres
    PASS=$(openssl rand -base64 12 | tr -dc 'a-zA-Z0-9' | head -c 12)
    
    id "$USERNAME" &>/dev/null || useradd -m -s /bin/bash "$USERNAME"
    echo "$USERNAME:$PASS" | chpasswd
    
    # Guardar en archivo seguro
    echo "$USERNAME -> $PASS" >> "$PASSWORD_FILE"
    echo "  ✓ Usuario $USERNAME creado con contraseña segura"

    # Auto-login al portal NEA Shell
    BASHRC="/home/$USERNAME/.bashrc"
    grep -q "nea_login" "$BASHRC" || echo -e "\nsource /usr/local/bin/nea_login" >> "$BASHRC"

    mkdir -p "/home/$USERNAME/students" "/home/$USERNAME/missions"
    chown root:root "/home/$USERNAME/missions"
    chown "$USERNAME:$USERNAME" "/home/$USERNAME/students"
done

# Asegurar permisos del archivo de contraseñas
chmod 600 "$PASSWORD_FILE"
echo "  ℹ Contraseñas guardadas en: $PASSWORD_FILE"

# 4. SERVICIO DE AUTO-UPDATE
echo "--- [4/6] Activando NEA Sync Service..."
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

echo "=== INSTALACIÓN DE NEA Shell COMPLETADA ==="

echo "--- [5/6] Configurando sincronización de datos (Syncthing)..."
bash "$REPO_DIR/scripts/nea_syncthing.sh"