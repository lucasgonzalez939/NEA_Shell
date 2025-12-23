#!/bin/bash
# ==============================================================================
# NEA Shell - DASHBOARD DE PROGRESO DEL DOCENTE
# ==============================================================================

# Colores para la tabla
VERDE='\033[0;32m'
CIAN='\033[0;36m'
AMARILLO='\033[1;33m'
NC='\033[0m'

# Verificar si jq está instalado
if ! command -v jq &> /dev/null; then
    echo "Error: 'jq' no está instalado. Instálalo con: sudo apt install jq"
    exit 1
fi

clear
echo -e "${CIAN}========================================================================"
echo "                NEA Shell - REPORTE GENERAL DE AGENTES"
echo -e "========================================================================${NC}"

# Cabecera de la tabla
printf "%-12s | %-15s | %-6s | %-8s | %-20s\n" "GRADO" "ESTUDIANTE" "NIVEL" "XP" "LOGROS (Badges)"
echo "------------------------------------------------------------------------"

# Buscar en cada carpeta de grado
GRADES=("1ro" "2do" "3ro" "4to" "5to" "6to")

for GRADE in "${GRADES[@]}"; do
    BASE_PATH="/home/grado_$GRADE/students"
    
    if [ -d "$BASE_PATH" ]; then
        # Iterar por cada carpeta de estudiante
        for STUDENT_DIR in "$BASE_PATH"/*; do
            if [ -d "$STUDENT_DIR" ]; then
                JSON_FILE="$STUDENT_DIR/.progress.json"
                
                if [ -f "$JSON_FILE" ]; then
                    # Extraer datos usando jq
                    NAME=$(jq -r '.name' "$JSON_FILE")
                    LEVEL=$(jq -r '.level' "$JSON_FILE")
                    XP=$(jq -r '.xp' "$JSON_FILE")
                    BADGES=$(jq -r '.badges | join(", ")' "$JSON_FILE")
                    
                    # Formatear color según nivel
                    COLOR=$NC
                    if [ "$LEVEL" -ge 5 ]; then COLOR=$VERDE; fi
                    if [ "$LEVEL" -le 1 ]; then COLOR=$AMARILLO; fi

                    # Imprimir fila
                    printf "%-12s | %-15s | ${COLOR}%-6s${NC} | %-8s | %-20s\n" \
                           "Grado $GRADE" "$NAME" "$LEVEL" "$XP" "$BADGES"
                fi
            fi
        done
    fi
done

echo "------------------------------------------------------------------------"
echo -e "${CIAN}Reporte generado el: $(date '+%d/%m/%Y %H:%M:%S')${NC}"
