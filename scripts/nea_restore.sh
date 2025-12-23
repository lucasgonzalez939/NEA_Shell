#!/bin/bash
# ==============================================================================
# NEA Shell - RESTORE (Recuperación de Backups)
# ==============================================================================

if [[ $EUID -ne 0 ]]; then
   echo "Este script debe ejecutarse como root (sudo)."
   exit 1
fi

BACKUP_DIR="/opt/nea_backups"

# Colores
VERDE='\033[0;32m'
AMARILLO='\033[1;33m'
ROJO='\033[0;31m'
CIAN='\033[0;36m'
NC='\033[0m'

echo -e "${CIAN}=== NEA Shell - Sistema de Recuperación ===${NC}\n"

# Verificar que existan backups
if [ ! -d "$BACKUP_DIR" ] || [ -z "$(ls -A $BACKUP_DIR 2>/dev/null)" ]; then
    echo -e "${ROJO}Error: No se encontraron backups en $BACKUP_DIR${NC}"
    exit 1
fi

# Listar backups disponibles
echo -e "${AMARILLO}Backups disponibles:${NC}\n"
backups=($(ls -1t "$BACKUP_DIR"))
count=1

for backup in "${backups[@]}"; do
    backup_date=$(echo "$backup" | sed 's/_/ /g')
    backup_size=$(du -sh "$BACKUP_DIR/$backup" 2>/dev/null | cut -f1)
    echo -e "  ${VERDE}[$count]${NC} $backup_date (Tamaño: $backup_size)"
    ((count++))
done

# Solicitar selección
echo -e "\n${AMARILLO}¿Qué backup deseas restaurar?${NC}"
read -p "Ingresa el número [1-${#backups[@]}] o 'q' para salir: " selection

if [ "$selection" = "q" ] || [ "$selection" = "Q" ]; then
    echo "Operación cancelada."
    exit 0
fi

# Validar entrada
if ! [[ "$selection" =~ ^[0-9]+$ ]] || [ "$selection" -lt 1 ] || [ "$selection" -gt "${#backups[@]}" ]; then
    echo -e "${ROJO}Error: Selección inválida${NC}"
    exit 1
fi

# Obtener backup seleccionado
selected_backup="${backups[$((selection-1))]}"
backup_path="$BACKUP_DIR/$selected_backup"

echo -e "\n${AMARILLO}Has seleccionado: $selected_backup${NC}"
echo -e "${ROJO}⚠ ADVERTENCIA: Esto sobrescribirá los datos actuales de los estudiantes${NC}"
read -p "¿Estás seguro? (escribe 'SI' para confirmar): " confirm

if [ "$confirm" != "SI" ]; then
    echo "Operación cancelada."
    exit 0
fi

# Proceso de restauración
echo -e "\n${AMARILLO}[RESTORE] Iniciando restauración...${NC}"

for GRADE in 1ro 2do 3ro 4to 5to 6to; do
    SOURCE="$backup_path/grado_$GRADE"
    DEST="/home/grado_$GRADE/students"
    
    if [ -d "$SOURCE" ]; then
        echo -e "  → Restaurando grado_$GRADE..."
        
        # Crear backup de seguridad de los datos actuales
        if [ -d "$DEST" ]; then
            mv "$DEST" "${DEST}.old_$(date +%Y%m%d_%H%M%S)" 2>/dev/null
        fi
        
        # Copiar datos del backup
        cp -r "$SOURCE" "$DEST"
        
        if [ $? -eq 0 ]; then
            chown -R "grado_$GRADE:grado_$GRADE" "$DEST"
            echo -e "    ${VERDE}✓${NC} Restaurado exitosamente"
        else
            echo -e "    ${ROJO}✗${NC} Error en la restauración"
        fi
    else
        echo -e "  ${AMARILLO}⚠${NC} No hay datos para grado_$GRADE en este backup"
    fi
done

echo -e "\n${VERDE}=== Restauración completada ===${NC}"
echo "Backup usado: $selected_backup"
echo "Fecha: $(date '+%Y-%m-%d %H:%M:%S')"
echo ""
echo -e "${AMARILLO}Nota: Los datos anteriores se guardaron como *.old_* por seguridad${NC}"
