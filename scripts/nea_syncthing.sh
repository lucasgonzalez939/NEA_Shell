#!/bin/bash
# ==============================================================================
# NEA Shell - CONFIGURADOR DE SYNCTHING
# ==============================================================================

# Colores
VERDE='\033[0;32m'
CIAN='\033[0;36m'
ROJO='\033[0;31m'
AMARILLO='\033[1;33m'
NC='\033[0m'

# Servidor Central (Cambia esto por la IP de tu OpenMediaVault)
SERVER_IP="192.168.1.100" 
SERVER_ID="ID-DEL-SERVIDOR-OMV-AQUI" # Obtén esto de la interfaz de OMV

echo -e "${CIAN}--- Configurando Syncthing para NEA Shell ---${NC}"

# 1. Instalación
echo "Instalando Syncthing..."
if ! apt update && apt install -y syncthing; then
    echo -e "${ROJO}Error: No se pudo instalar Syncthing${NC}"
    exit 1
fi

# 2. Habilitar el servicio para el usuario root (o un usuario administrador)
# Nota: Para simplificar en el lab, lo correremos como servicio de sistema
systemctl enable syncthing@root
systemctl start syncthing@root

# Función para esperar a que Syncthing esté listo
wait_for_syncthing() {
    local max_wait=30
    local count=0
    
    echo "  ⏳ Esperando que Syncthing inicie..."
    while [ $count -lt $max_wait ]; do
        if systemctl is-active --quiet syncthing@root; then
            sleep 2  # Dar tiempo adicional para que cree archivos
            if [ -f "/root/.config/syncthing/config.xml" ]; then
                echo "  ✓ Syncthing iniciado correctamente"
                return 0
            fi
        fi
        sleep 1
        ((count++))
    done
    
    echo "  ⚠ Timeout esperando Syncthing"
    return 1
}

# Detener servicio si existe
systemctl stop syncthing@root 2>/dev/null || true

# Iniciar servicio y esperar
systemctl start syncthing@root
systemctl enable syncthing@root

# Esperar a que Syncthing cree su configuración
if ! wait_for_syncthing; then
    echo "  ⚠ Syncthing no creó archivos de configuración"
    echo "  ℹ Intentando arranque manual..."
    
    # Arranque manual para forzar creación de config
    su - root -c "syncthing -home=/root/.config/syncthing -no-browser -logfile=/root/.config/syncthing/syncthing.log &"
    sleep 5
    pkill -u root syncthing
    sleep 2
fi

# Buscar config.xml en ubicaciones posibles
CONFIG_FILE=""
POSSIBLE_PATHS=(
    "/root/.config/syncthing/config.xml"
    "/home/root/.config/syncthing/config.xml"
    "/home/root/.local/share/syncthing/config.xml"
)

for path in "${POSSIBLE_PATHS[@]}"; do
    if [ -f "$path" ]; then
        CONFIG_FILE="$path"
        SYNC_HOME=$(dirname "$path")
        echo "  ✓ Configuración encontrada: $CONFIG_FILE"
        break
    fi
done

if [ -z "$CONFIG_FILE" ]; then
    echo "  ✗ ERROR: No se encontró config.xml de Syncthing"
    echo "  ℹ Ubicaciones verificadas:"
    printf '    - %s\n' "${POSSIBLE_PATHS[@]}"
    exit 1
fi

# Obtener API Key con reintentos
get_api_key() {
    local max_retries=3
    local retry=0
    
    while [ $retry -lt $max_retries ]; do
        if [ -f "$CONFIG_FILE" ]; then
            API_KEY=$(grep -oP '<apikey>\K[^<]+' "$CONFIG_FILE" 2>/dev/null)
            
            if [ -n "$API_KEY" ] && [ "$API_KEY" != "" ]; then
                echo "$API_KEY"
                return 0
            fi
        fi
        
        ((retry++))
        if [ $retry -lt $max_retries ]; then
            echo "  ⏳ Reintento $retry/$max_retries para obtener API key..."
            sleep 3
            systemctl restart syncthing@root
            sleep 5
        fi
    done
    
    return 1
}

echo "  🔑 Obteniendo API Key..."
API_KEY=$(get_api_key)

if [ -z "$API_KEY" ] || [ "$API_KEY" == "" ]; then
    echo "  ⚠ No se pudo obtener API key automáticamente"
    echo "  ℹ Generando nueva API key..."
    
    # Generar y configurar nueva API key
    NEW_API_KEY=$(openssl rand -hex 32)
    
    # Detener servicio para modificar config
    systemctl stop syncthing@root
    
    # Modificar config.xml
    if grep -q "<apikey>" "$CONFIG_FILE"; then
        sed -i "s|<apikey>.*</apikey>|<apikey>$NEW_API_KEY</apikey>|" "$CONFIG_FILE"
    else
        sed -i "s|<gui |<gui>\n        <apikey>$NEW_API_KEY</apikey>\n    <gui |" "$CONFIG_FILE"
    fi
    
    API_KEY="$NEW_API_KEY"
    chown root:root "$CONFIG_FILE"
    
    systemctl start syncthing@root
    sleep 3
    
    echo "  ✓ API Key configurada: ${API_KEY:0:8}..."
fi

# Guardar API Key de forma segura
API_KEY_FILE="/root/nea_syncthing_api.txt"
echo "$API_KEY" > "$API_KEY_FILE"
chmod 600 "$API_KEY_FILE"
echo "  ✓ API Key guardada en: $API_KEY_FILE"

# 4. Configurar carpetas de los grados mediante la API
GRADES=("1ro" "2do" "3ro" "4to" "5to" "6to")

for GRADE in "${GRADES[@]}"; do
    FOLDER_ID="nea-grado-$GRADE"
    FOLDER_PATH="/home/grado_$GRADE/students"

    echo -e "Configurando sincronización para: ${VERDE}$FOLDER_ID${NC}"
    
    # Comando para añadir la carpeta a Syncthing mediante su API local
    # (Esto es más limpio que editar el XML a mano)
    response=$(curl -s -o /dev/null -w "%{http_code}" -X PUT -H "X-API-Key: $API_KEY" \
         -d '{
           "id": "'$FOLDER_ID'",
           "path": "'$FOLDER_PATH'",
           "type": "sendreceive",
           "rescanIntervalS": 300
         }' \
         "http://127.0.0.1:8384/rest/config/folders/$FOLDER_ID")
    
    if [ "$response" != "200" ] && [ "$response" != "204" ]; then
        echo -e "  ${AMARILLO}⚠ Advertencia: No se pudo configurar $FOLDER_ID (HTTP $response)${NC}"
    else
        echo -e "  ${VERDE}✓ Carpeta $FOLDER_ID configurada correctamente${NC}"
    fi
done

# 5. Añadir el Servidor Central como "Dispositivo de Confianza"
if [ ! -z "$SERVER_ID" ] && [ "$SERVER_ID" != "ID-DEL-SERVIDOR-OMV-AQUI" ]; then
    echo -e "\nConfigurando servidor central..."
    response=$(curl -s -o /dev/null -w "%{http_code}" -X PUT -H "X-API-Key: $API_KEY" \
         -d '{
           "deviceID": "'$SERVER_ID'",
           "name": "NEA-SERVIDOR-CENTRAL",
           "addresses": ["tcp://'$SERVER_IP':22000"],
           "compression": "metadata",
           "introducer": true
         }' \
         "http://127.0.0.1:8384/rest/config/devices/$SERVER_ID")
    
    if [ "$response" != "200" ] && [ "$response" != "204" ]; then
        echo -e "${AMARILLO}⚠ Advertencia: No se pudo configurar el servidor central (HTTP $response)${NC}"
    else
        echo -e "${VERDE}✓ Servidor central configurado correctamente${NC}"
    fi
else
    echo -e "${AMARILLO}⚠ Servidor central no configurado. Edita SERVER_ID en el script.${NC}"
fi

# 6. Reiniciar Syncthing para aplicar cambios
systemctl restart syncthing@root
sleep 3

echo -e "\n${VERDE}=== Syncthing configurado correctamente ===${NC}"
echo -e "${CIAN}ID de esta Netbook:${NC}"
syncthing --device-id

echo -e "\n${AMARILLO}Próximos pasos:${NC}"
echo "1. Copia el Device ID mostrado arriba"
echo "2. Añádelo en el servidor OMV desde la interfaz web"
echo "3. Verifica la conexión en http://127.0.0.1:8384"