#!/bin/bash
# ==============================================================================
# NEA Shell - GESTOR DE CONEXIÓN WIFI + TEST DE INTERNET
# ==============================================================================

# Colores y Formato
VERDE='\033[0;32m'
ROJO='\033[0;31m'
AMARILLO='\033[1;33m'
CIAN='\033[0;36m'
NC='\033[0m' # No Color

# Verificar privilegios de root
if [[ $EUID -ne 0 ]]; then
   echo -e "${ROJO}Error: Debes ejecutar este comando con 'sudo'.${NC}"
   exit 1
fi

clear
echo -e "${VERDE}===================================================="
echo "          SISTEMA DE COMUNICACIONES NEA Shell       "
echo -e "====================================================${NC}"

# 1. Mostrar estado actual
CURRENT_SSID=$(nmcli -t -f active,ssid dev wifi | grep '^si' | cut -d: -f2)
if [ -z "$CURRENT_SSID" ]; then
    echo -e "ESTADO: ${ROJO}Desconectado${NC}"
else
    echo -e "ESTADO: ${VERDE}Conectado a [$CURRENT_SSID]${NC}"
fi

echo -e "\n${AMARILLO}Escaneando redes disponibles...${NC}"
nmcli device wifi rescan 2>/dev/null
sleep 2

# Listar redes
nmcli --fields SSID,BARS,SECURITY device wifi list | grep -v "^\*"

echo -e "\n----------------------------------------------------"
read -p "SSID (Nombre de la red): " WIFI_NAME
read -s -p "CONTRASEÑA: " WIFI_PASS
echo -e "\n"

echo -e "${AMARILLO}Estableciendo enlace con $WIFI_NAME...${NC}"

# 2. Intento de Conexión
if nmcli device wifi connect "$WIFI_NAME" password "$WIFI_PASS"; then
    echo -e "${VERDE}¡ÉXITO! Enlace de radio establecido.${NC}"
    
    # 3. TEST DE CONEXIÓN A INTERNET (PING)
    echo -e "\n${CIAN}Iniciando test de respuesta de red (Ping a Google)...${NC}"
    
    # Hacemos 3 pings rápidos. Usamos 8.8.8.8 para evitar problemas de DNS.
    if ping -c 3 8.8.8.8 &> /dev/null; then
        echo -e "${VERDE}[OK] Conexión a Internet confirmada.${NC}"
        echo -e "${CIAN}Latencia detectada: $(ping -c 1 8.8.8.8 | grep 'time=' | awk -F'time=' '{print $2}')${NC}"
    else
        echo -e "${AMARILLO}[AVISO] Conectado al WiFi, pero no hay respuesta de Internet.${NC}"
        echo "Es posible que la red escolar tenga un portal cautivo o bloqueo de salida."
    fi

else
    echo -e "${ROJO}ERROR: No se pudo establecer la conexión.${NC}"
    echo "Verifica que el SSID y la contraseña sean correctos."
fi

echo -e "\n----------------------------------------------------"
echo -e "Presiona ENTER para volver a la terminal."
read