#!/bin/bash
# ==============================================================================
# NEA Shell - SYNC v3.0 (Con sistema de backup)
# ==============================================================================

REPO_DIR="/opt/nea_shell"
BACKUP_DIR="/opt/nea_backups"
BACKUP_DATE=$(date +%Y%m%d_%H%M%S)
BACKUP_PATH="$BACKUP_DIR/$BACKUP_DATE"

# Colores para logs
VERDE='\033[0;32m'
AMARILLO='\033[1;33m'
ROJO='\033[0;31m'
NC='\033[0m'

# Función de backup
backup_student_data() {
    echo -e "${AMARILLO}[BACKUP] Creando respaldo de datos de estudiantes...${NC}"
    
    mkdir -p "$BACKUP_PATH"
    
    for GRADE in 1ro 2do 3ro 4to 5to 6to; do
        STUDENT_DIR="/home/grado_$GRADE/students"
        
        if [ -d "$STUDENT_DIR" ]; then
            echo "  → Respaldando grado_$GRADE..."
            cp -r "$STUDENT_DIR" "$BACKUP_PATH/grado_$GRADE" 2>/dev/null
            
            if [ $? -eq 0 ]; then
                echo -e "    ${VERDE}✓${NC} Backup completado"
            else
                echo -e "    ${ROJO}✗${NC} Error en backup"
            fi
        fi
    done
    
    # Mantener solo los últimos 7 backups
    echo -e "${AMARILLO}[BACKUP] Limpiando backups antiguos...${NC}"
    cd "$BACKUP_DIR" && ls -t | tail -n +8 | xargs -r rm -rf
    
    echo -e "${VERDE}[BACKUP] Backup completado: $BACKUP_PATH${NC}"
}

# Verificar conectividad
echo "[SYNC] Verificando conexión a internet..."
if ! ping -c 1 8.8.8.8 &> /dev/null; then
    echo -e "${ROJO}[SYNC] Sin conexión a internet. Abortando sincronización.${NC}"
    exit 1
fi

echo -e "${VERDE}[SYNC] Conexión establecida${NC}"

# Crear backup antes de actualizar
backup_student_data

# Crear backup antes de actualizar
backup_student_data

# Actualizar desde GitHub
echo -e "\n${AMARILLO}[SYNC] Sincronizando con repositorio GitHub...${NC}"
if [ ! -d "$REPO_DIR" ]; then
    echo -e "${ROJO}[ERROR] Directorio $REPO_DIR no existe${NC}"
    exit 1
fi

cd "$REPO_DIR" || exit 1

# Guardar hash del commit actual
OLD_COMMIT=$(git rev-parse HEAD 2>/dev/null)

# Intentar actualizar
if git pull origin main; then
    NEW_COMMIT=$(git rev-parse HEAD 2>/dev/null)
    
    if [ "$OLD_COMMIT" != "$NEW_COMMIT" ]; then
        echo -e "${VERDE}[SYNC] ✓ Repositorio actualizado${NC}"
        echo "       Commit anterior: ${OLD_COMMIT:0:7}"
        echo "       Commit nuevo: ${NEW_COMMIT:0:7}"
    else
        echo -e "${VERDE}[SYNC] Sistema ya está actualizado${NC}"
    fi
else
    echo -e "${ROJO}[ERROR] Falló git pull. Revisa la conexión o conflictos.${NC}"
    exit 1
fi

# 1. Hacer ejecutables los scripts
echo -e "\n${AMARILLO}[SYNC] Actualizando scripts...${NC}"
chmod +x "$REPO_DIR/scripts"/*.sh

# 2. Actualizar binarios globales (enlaces simbólicos o copia)
cp "$REPO_DIR/scripts"/*.sh /usr/local/bin/
if [ $? -eq 0 ]; then
    echo -e "${VERDE}[SYNC] ✓ Scripts actualizados en /usr/local/bin${NC}"
else
    echo -e "${ROJO}[ERROR] Falló la copia de scripts${NC}"
fi

# 3. Actualizar carpetas de misiones de los grados
echo -e "\n${AMARILLO}[SYNC] Actualizando misiones...${NC}"
MISSIONS_UPDATED=0

for GRADE in 1ro 2do 3ro 4to 5to 6to; do
    if [ -d "$REPO_DIR/missions" ]; then
        cp -r "$REPO_DIR/missions/"* "/home/grado_$GRADE/missions/" 2>/dev/null
        if [ $? -eq 0 ]; then
            ((MISSIONS_UPDATED++))
        fi
    fi
done

if [ $MISSIONS_UPDATED -gt 0 ]; then
    echo -e "${VERDE}[SYNC] ✓ Misiones actualizadas para $MISSIONS_UPDATED grados${NC}"
else
    echo -e "${AMARILLO}[SYNC] No hay misiones nuevas para actualizar${NC}"
fi

echo -e "\n${VERDE}=== NEA Shell: Sincronización completada ===${NC}"
echo "Fecha: $(date '+%Y-%m-%d %H:%M:%S')"
echo "Backup guardado en: $BACKUP_PATH"