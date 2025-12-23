# 📦 Guía de Despliegue - NEA Shell v3.0

## Pre-requisitos

- [ ] Git instalado y configurado
- [ ] Acceso root a las netbooks del laboratorio
- [ ] Conexión a internet estable
- [ ] Repositorio GitHub accesible
- [ ] Credenciales de acceso al repositorio

---

## 🚀 Despliegue en Nueva Instalación

### Paso 1: Clonar el Repositorio

```bash
cd /tmp
git clone https://github.com/lucasgonzalez939/NEA_Shell.git
cd NEA_Shell
```

### Paso 2: Ejecutar Instalación

```bash
sudo chmod +x install_nea_shell.sh
sudo ./install_nea_shell.sh
```

**Tiempo estimado:** 5-10 minutos

### Paso 3: Guardar Contraseñas

```bash
# Copiar archivo de contraseñas a un lugar seguro
sudo cp /root/nea_passwords.txt ~/nea_passwords_backup_$(date +%Y%m%d).txt
chmod 600 ~/nea_passwords_backup_*.txt
```

⚠️ **IMPORTANTE:** Guarda este archivo en un lugar seguro. Es la única copia de las contraseñas.

### Paso 4: Verificar Instalación

```bash
sudo ./test_validation.sh
```

Deberías ver:
```
✓ Todas las pruebas pasaron correctamente
El sistema NEA Shell v3.0 está funcionando correctamente
```

---

## 🔄 Actualización desde Versión Anterior

### Opción A: Actualización Completa (Recomendado)

**⚠️ ADVERTENCIA:** Esto sobrescribirá las contraseñas existentes.

```bash
# 1. Backup manual de datos de estudiantes
sudo cp -r /home/grado_*/students /tmp/backup_students_$(date +%Y%m%d)

# 2. Reinstalar
cd /opt/nea_shell
git pull origin main
sudo bash install_nea_shell.sh

# 3. Recuperar contraseñas
sudo cat /root/nea_passwords.txt
```

### Opción B: Actualización Selectiva (Mantener contraseñas)

```bash
# 1. Actualizar repositorio
cd /opt/nea_shell
sudo git pull origin main

# 2. Actualizar solo los scripts
sudo chmod +x scripts/*.sh
sudo cp scripts/*.sh /usr/local/bin/

# 3. Actualizar servicio systemd
sudo systemctl daemon-reload
sudo systemctl restart nea-sync.service

# 4. Verificar
sudo nea_sync
```

---

## 🔧 Configuración Post-Instalación

### 1. Configurar Syncthing

```bash
sudo nea_syncthing
```

**Pasos:**
1. Copia el Device ID mostrado
2. Ingresa al servidor OMV: http://SERVER_IP:8384
3. Añade el Device ID de cada netbook
4. Acepta las carpetas compartidas

### 2. Probar Conectividad

```bash
sudo nea_wifi
```

**Ingresar:**
- SSID de la red escolar
- Contraseña WiFi

### 3. Forzar Primera Sincronización

```bash
sudo systemctl start nea-sync.service
# o manualmente:
sudo nea_sync
```

---

## 👥 Creación de Perfiles de Estudiantes

### Método Manual

```bash
# Cambiar a usuario de grado
su - grado_1ro  # Usar contraseña de /root/nea_passwords.txt

# Crear carpeta de estudiante
mkdir -p ~/students/juan_perez
cd ~/students/juan_perez

# Crear archivo de progreso
cat > .progress.json << EOF
{
  "name": "Juan Pérez",
  "level": 1,
  "xp": 0,
  "badges": [],
  "unlocked_commands": ["cd", "ls"],
  "last_login": "$(date -Iseconds)"
}
EOF

chmod 644 .progress.json
```

### Script Automatizado (Próximamente)

```bash
sudo nea_create_student --grade 1ro --name "Juan Pérez"
```

---

## 📊 Monitoreo y Mantenimiento

### Ver Progreso de Estudiantes

```bash
sudo nea_report
```

### Verificar Backups

```bash
sudo ls -lh /opt/nea_backups/
```

### Ver Logs de Sincronización

```bash
journalctl -u nea-sync.service -n 50 -f
```

### Forzar Backup Manual

```bash
sudo nea_sync  # Esto crea backup automáticamente
```

---

## 🆘 Recuperación ante Desastres

### Restaurar desde Backup

```bash
sudo nea_restore
```

**Seleccionar:**
- Número del backup a restaurar
- Confirmar con "SI"

### Restaurar Contraseñas Perdidas

Si perdiste `/root/nea_passwords.txt`:

```bash
# Opción 1: Cambiar contraseñas manualmente
sudo passwd grado_1ro
sudo passwd grado_2do
# ... etc

# Opción 2: Reinstalar (pérdida de contraseñas actuales)
sudo bash install_nea_shell.sh
```

### Sistema Corrupto

```bash
# 1. Backup de datos de estudiantes
sudo cp -r /home/grado_*/students /tmp/emergency_backup

# 2. Reinstalar completamente
sudo rm -rf /opt/nea_shell
cd /tmp
git clone https://github.com/lucasgonzalez939/NEA_Shell.git
cd NEA_Shell
sudo bash install_nea_shell.sh

# 3. Restaurar datos
sudo cp -r /tmp/emergency_backup/* /home/grado_*/students/
```

---

## 🔐 Seguridad y Permisos

### Archivo de Contraseñas

```bash
# Verificar permisos correctos
sudo ls -l /root/nea_passwords.txt
# Debe mostrar: -rw------- 1 root root

# Si está mal:
sudo chmod 600 /root/nea_passwords.txt
```

### Verificar Usuarios

```bash
# Listar usuarios de grado
getent passwd | grep grado_

# Verificar carpetas
for grade in 1ro 2do 3ro 4to 5to 6to; do
    echo "=== grado_$grade ==="
    ls -ld /home/grado_$grade/students
done
```

---

## 📝 Checklist de Despliegue

### Pre-Instalación
- [ ] Internet funcional
- [ ] Acceso root confirmado
- [ ] Repositorio clonado
- [ ] Dependencias verificadas (git, openssl)

### Durante Instalación
- [ ] Script ejecutado sin errores
- [ ] Contraseñas generadas correctamente
- [ ] Usuarios creados (6 grados)
- [ ] Servicio systemd habilitado
- [ ] Syncthing configurado

### Post-Instalación
- [ ] Tests de validación pasados
- [ ] Contraseñas respaldadas
- [ ] Primera sincronización exitosa
- [ ] Conectividad WiFi probada
- [ ] Syncthing conectado al servidor
- [ ] Backup inicial creado

### Verificación Final
- [ ] Login en cada usuario de grado funcional
- [ ] Scripts accesibles desde PATH
- [ ] nea_report muestra datos correctos
- [ ] Logs de systemd sin errores
- [ ] Documentación entregada al docente

---

## 📞 Contacto y Soporte

**Desarrollador:** Lucas Gonzalez  
**Institución:** Nueva Escuela Argentina - Makerspace & Robotics  
**Email:** [Tu email aquí]  
**GitHub:** https://github.com/lucasgonzalez939/NEA_Shell

### Reportar Problemas

```bash
# Generar reporte de diagnóstico
sudo journalctl -u nea-sync.service > ~/nea_debug.log
sudo dmesg >> ~/nea_debug.log
cat /var/log/syslog | grep nea >> ~/nea_debug.log

# Enviar a soporte junto con:
# - Salida de: sudo ./test_validation.sh
# - Descripción del problema
# - Netbook afectada
```

---

## 🎓 Capacitación para Docentes

### Comandos Básicos para el Docente

```bash
# Ver progreso de todos los estudiantes
sudo nea_report

# Forzar actualización de contenido
sudo nea_sync

# Restaurar datos perdidos
sudo nea_restore

# Revisar logs de errores
journalctl -u nea-sync.service -n 50

# Ver contraseñas de grados
sudo cat /root/nea_passwords.txt
```

### Mantenimiento Semanal

1. **Lunes:** Verificar backups (`ls /opt/nea_backups/`)
2. **Miércoles:** Revisar progreso (`sudo nea_report`)
3. **Viernes:** Forzar sincronización (`sudo nea_sync`)

### Mantenimiento Mensual

1. Actualizar contenido del repositorio
2. Verificar espacio en disco: `df -h`
3. Revisar logs: `journalctl -u nea-sync.service --since "1 month ago"`
4. Probar restauración de backup en netbook de prueba

---

## ✅ Siguiente Paso

Una vez completado el despliegue:

```bash
# Commit de cambios al repositorio
cd /home/lucas/Documentos/src/NEA_Shell
git add .
git commit -m "feat: NEA Shell v3.0 - Producción Ready"
git push origin main
```

**¡El sistema está listo para usar en producción!** 🎉
