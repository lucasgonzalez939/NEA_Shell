#!/bin/bash
# ==============================================================================
# NEA Shell - Test de Validación v3.0
# ==============================================================================
# Este script verifica que las mejoras implementadas funcionen correctamente

# Colores
VERDE='\033[0;32m'
ROJO='\033[0;31m'
AMARILLO='\033[1;33m'
CIAN='\033[0;36m'
NC='\033[0m'

echo -e "${CIAN}=== Test de Validación NEA Shell v3.0 ===${NC}\n"

# Contador de pruebas
TOTAL_TESTS=0
PASSED_TESTS=0
FAILED_TESTS=0

# Función para ejecutar tests
run_test() {
    local test_name="$1"
    local test_command="$2"
    
    ((TOTAL_TESTS++))
    echo -n "[$TOTAL_TESTS] $test_name... "
    
    if eval "$test_command" &>/dev/null; then
        echo -e "${VERDE}✓ PASS${NC}"
        ((PASSED_TESTS++))
        return 0
    else
        echo -e "${ROJO}✗ FAIL${NC}"
        ((FAILED_TESTS++))
        return 1
    fi
}

echo -e "${AMARILLO}[SEGURIDAD]${NC}"

# Test 1: Verificar que existe el archivo de contraseñas
run_test "Archivo de contraseñas existe" "test -f /root/nea_passwords.txt"

# Test 2: Verificar permisos del archivo de contraseñas
run_test "Permisos del archivo de contraseñas (600)" "test \$(stat -c '%a' /root/nea_passwords.txt 2>/dev/null) = '600'"

# Test 3: Verificar que openssl está instalado
run_test "OpenSSL instalado" "command -v openssl"

echo -e "\n${AMARILLO}[SISTEMA DE BACKUP]${NC}"

# Test 4: Directorio de backups existe
run_test "Directorio de backups existe" "test -d /opt/nea_backups"

# Test 5: Script de restore existe y es ejecutable
run_test "Script nea_restore existe" "test -x /usr/local/bin/nea_restore"

# Test 6: Función de backup en nea_sync existe
run_test "Función backup_student_data en nea_sync" "grep -q 'backup_student_data' /usr/local/bin/nea_sync"

echo -e "\n${AMARILLO}[VALIDACIÓN DE ERRORES]${NC}"

# Test 7: nea_sync verifica conectividad
run_test "nea_sync verifica ping antes de sync" "grep -q 'ping -c 1 8.8.8.8' /usr/local/bin/nea_sync"

# Test 8: nea_syncthing valida API Key
run_test "nea_syncthing valida API Key" "grep -q 'if \[ -z \"\$API_KEY\" \]' /opt/nea_shell/scripts/nea_syncthing.sh"

# Test 9: nea_syncthing verifica respuestas HTTP
run_test "nea_syncthing verifica códigos HTTP" "grep -q 'http_code' /opt/nea_shell/scripts/nea_syncthing.sh"

echo -e "\n${AMARILLO}[SCRIPTS Y COMANDOS]${NC}"

# Test 10: Enlaces simbólicos correctos
run_test "Comando nea_sync (sin .sh)" "test -L /usr/local/bin/nea_sync"
run_test "Comando nea_restore (sin .sh)" "test -L /usr/local/bin/nea_restore"
run_test "Comando nea_login (sin .sh)" "test -L /usr/local/bin/nea_login"

echo -e "\n${AMARILLO}[ESTRUCTURA DE USUARIOS]${NC}"

# Test 13: Usuarios de grado existen
for GRADE in 1ro 2do 3ro 4to 5to 6to; do
    run_test "Usuario grado_$GRADE existe" "id grado_$GRADE"
done

echo -e "\n${AMARILLO}[REPOSITORIO]${NC}"

# Test 19: Repositorio existe en /opt
run_test "Repositorio clonado en /opt/nea_shell" "test -d /opt/nea_shell"

# Test 20: Archivo CHANGELOG.md existe
run_test "CHANGELOG.md documentado" "test -f /opt/nea_shell/CHANGELOG.md"

# Resumen
echo -e "\n${CIAN}=== RESUMEN DE PRUEBAS ===${NC}"
echo -e "Total de pruebas: $TOTAL_TESTS"
echo -e "${VERDE}Exitosas: $PASSED_TESTS${NC}"
echo -e "${ROJO}Fallidas: $FAILED_TESTS${NC}"

if [ $FAILED_TESTS -eq 0 ]; then
    echo -e "\n${VERDE}✓ Todas las pruebas pasaron correctamente${NC}"
    echo -e "${CIAN}El sistema NEA Shell v3.0 está funcionando correctamente${NC}"
    exit 0
else
    echo -e "\n${AMARILLO}⚠ Algunas pruebas fallaron. Revisa la instalación.${NC}"
    exit 1
fi
