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

# Esperar a que se genere la configuración inicial
echo "Esperando inicialización de Syncthing..."
sleep 5

# 3. Obtener el API Key de la configuración generada
API_KEY=$(grep -Po '(?<=<apikey>).*(?=</apikey>)' /root/.config/syncthing/config.xml)

if [ -z "$API_KEY" ]; then
    echo -e "${ROJO}Error: No se pudo obtener la API Key de Syncthing${NC}"
    exit 1
fi
echo -e "${VERDE}API Key obtenida correctamente${NC}"

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