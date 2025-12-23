# Changelog - NEA Shell

## [3.0.0] - 2025-12-23

### 🔒 Seguridad

#### **Generación de Contraseñas Aleatorias**
- **CAMBIO CRÍTICO**: Las contraseñas ahora se generan aleatoriamente durante la instalación
- Cada usuario de grado (`grado_1ro` a `grado_6to`) recibe una contraseña única de 12 caracteres
- Las contraseñas se almacenan en `/root/nea_passwords.txt` (solo accesible por root)
- **Acción requerida**: Después de la instalación, guarda una copia segura del archivo de contraseñas

**Antes:**
```bash
# Contraseña hardcodeada igual para todos
echo "$USERNAME:nea2025" | chpasswd
```

**Ahora:**
```bash
# Contraseña única generada con OpenSSL
PASS=$(openssl rand -base64 12 | tr -dc 'a-zA-Z0-9' | head -c 12)
echo "$USERNAME:$PASS" | chpasswd
```

---

### 💾 Sistema de Backup Automático

#### **Backup antes de cada sincronización**
- `nea_sync.sh` ahora crea automáticamente un respaldo completo antes de actualizar
- Los backups se guardan en `/opt/nea_backups/YYYYMMDD_HHMMSS/`
- Incluye todas las carpetas de estudiantes y archivos `.progress.json`
- Retención automática: se mantienen solo los últimos 7 backups

#### **Script de Restauración**
- Nuevo comando: `sudo nea_restore`
- Interfaz interactiva para seleccionar qué backup restaurar
- Muestra tamaño y fecha de cada backup disponible
- Crea backup de seguridad de los datos actuales antes de restaurar (sufijo `.old_*`)

**Ejemplo de uso:**
```bash
$ sudo nea_restore

=== NEA Shell - Sistema de Recuperación ===

Backups disponibles:

  [1] 20251223 141530 (Tamaño: 45M)
  [2] 20251223 080000 (Tamaño: 43M)
  [3] 20251222 170000 (Tamaño: 41M)

¿Qué backup deseas restaurar?
```

---

### ✅ Validación de Errores

#### **nea_syncthing.sh - Validación de API de Syncthing**
- Verifica que la instalación de Syncthing se complete correctamente
- Valida que el API Key se obtenga exitosamente
- Comprueba el código HTTP de cada operación de configuración
- Mensajes claros de error y advertencia con códigos de colores

**Mejoras implementadas:**
```bash
# Verificar instalación
if ! apt install -y syncthing; then
    echo "Error: No se pudo instalar Syncthing"
    exit 1
fi

# Validar respuestas HTTP
response=$(curl -s -o /dev/null -w "%{http_code}" ...)
if [ "$response" != "200" ] && [ "$response" != "204" ]; then
    echo "⚠ Advertencia: Error HTTP $response"
fi
```

#### **nea_sync.sh - Logs detallados de sincronización**
- Verifica conectividad a internet antes de intentar sincronizar
- Registra commits de Git (anterior y nuevo) para rastrear cambios
- Valida cada operación crítica (git pull, copia de archivos, etc.)
- Contador de misiones actualizadas por grado
- Salida estructurada con timestamps y códigos de color

**Ejemplo de salida:**
```
[BACKUP] Creando respaldo de datos de estudiantes...
  → Respaldando grado_1ro...
    ✓ Backup completado

[SYNC] Verificando conexión a internet...
[SYNC] ✓ Conexión establecida
[SYNC] Sincronizando con repositorio GitHub...
[SYNC] ✓ Repositorio actualizado
       Commit anterior: a1b2c3d
       Commit nuevo: e4f5g6h

=== NEA Shell: Sincronización completada ===
Fecha: 2025-12-23 14:15:30
Backup guardado en: /opt/nea_backups/20251223_141530
```

---

### 🔧 Mejoras Técnicas

#### **Normalización de comandos**
- Los scripts ahora se invocan sin extensión `.sh`:
  - `nea_sync` (antes: `nea_sync.sh`)
  - `nea_login` (antes: `nea_login.sh`)
  - `nea_tour`, `nea_wifi`, `nea_restore`, etc.
- Enlaces simbólicos más limpios y consistentes
- Actualizado el servicio systemd para usar la nueva nomenclatura

#### **Estructura mejorada de scripts**
- Todos los scripts ahora incluyen:
  - Encabezado con nombre y versión
  - Códigos de color para mejor legibilidad
  - Validación de permisos (root cuando es necesario)
  - Manejo de errores con mensajes descriptivos

---

### 📚 Documentación

#### **README.md actualizado**
- Nueva sección: **🔒 Seguridad y Backups**
  - Explicación del sistema de contraseñas aleatorias
  - Documentación del sistema de backup automático
  - Instrucciones para restaurar backups

- Nueva sección: **🔧 Solución de Problemas**
  - Guía para problemas de sincronización con GitHub
  - Procedimiento de recuperación de datos perdidos
  - Troubleshooting de Syncthing
  - Solución para errores de instalación

#### **Nuevo archivo: CHANGELOG.md**
- Historial de cambios detallado
- Documentación de breaking changes
- Guías de migración cuando sea necesario

---

### ⚠️ Breaking Changes

1. **Contraseñas**: Las instalaciones existentes seguirán usando `nea2025`. Para actualizar a contraseñas aleatorias, debes cambiar manualmente las contraseñas o reinstalar.

2. **Comandos sin `.sh`**: Los scripts ahora se llaman sin extensión. Actualiza cualquier script personalizado o documentación que use los nombres antiguos.

---

### 🔜 Próximas Mejoras Planeadas

- [ ] Sistema de hints progresivos en misiones
- [ ] Dashboard web para visualización de progreso
- [ ] Modo offline completo con caché de misiones
- [ ] Sistema de badges y logros
- [ ] Validación de entrada en `nea_wifi.sh`

---

### 🐛 Correcciones de Bugs

- **nea_syncthing.sh**: Ahora valida que el SERVER_ID no sea el placeholder por defecto
- **nea_sync.sh**: Previene errores silenciosos cuando no existe el directorio de misiones
- **install_nea_shell.sh**: Mejor manejo de instalaciones existentes vs nuevas

---

## [2.0.0] - Versión anterior

*Documentación de versiones anteriores pendiente*
