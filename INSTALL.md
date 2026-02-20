# Guía de Instalación - NEA Shell

## Requisitos Mínimos

- **Sistema Operativo**: Debian 10+, Ubuntu 18.04+, o derivados
- **RAM**: 512 MB (2GB recomendado)
- **Espacio**: 2 GB libres
- **Conectividad**: Acceso a internet durante la instalación
- **Privilegios**: Acceso root o sudo
- **Git**: Debe estar instalado previamente (ver instrucciones abajo)

## Pre-requisito: Instalar Git

**Git es necesario para descargar NEA Shell.** Si no lo tienes instalado:

```bash
# Como root
su -
apt update
apt install -y git
exit

# O con sudo
sudo apt update
sudo apt install -y git
```

## Instalación Rápida

### Si ya tienes git y sudo configurados:

```bash
git clone https://github.com/lucasgonzalez939/NEA_Shell.git
cd NEA_Shell
sudo bash install_nea_shell.sh
```

## Instalación Paso a Paso (Sistema Básico)

### 1. Obtener Acceso Root

Si tu sistema no tiene `sudo` configurado:

```bash
# Cambiar a usuario root
su -

# Navegar al directorio del usuario
cd /home/tu_usuario
```

### 2. Instalar Git

**⚠️ IMPORTANTE: Este paso es OBLIGATORIO**

```bash
# Como root o con sudo
apt update
apt install -y git

# Verificar instalación
git --version
# Debe mostrar: git version 2.x.x
```

### 3. Clonar el Repositorio

```bash
# Descargar NEA Shell
git clone https://github.com/lucasgonzalez939/NEA_Shell.git
cd NEA_Shell
```

### 4. Ejecutar el Instalador

```bash
# Como root
bash install_nea_shell.sh

# O con sudo
sudo bash install_nea_shell.sh
```

El script verificará automáticamente que git esté instalado. Si no lo está, mostrará un mensaje de error con instrucciones.

## Configuración de Sudo (Opcional pero Recomendado)

Si el script detecta que no tienes `sudo`, te mostrará instrucciones. También puedes configurarlo manualmente:

```bash
# Como root
apt update
apt install -y sudo

# Agregar tu usuario al grupo sudo
usermod -aG sudo tu_usuario

# Salir y volver a iniciar sesión
exit
```

Luego cierra sesión completamente y vuelve a iniciar sesión para que los cambios surtan efecto.

## Proceso de Instalación Interactivo

El instalador te guiará a través de 7 pasos:

0. **[0/6] Pre-requisitos**: Verificación de git, internet, instalación de curl, wget, openssl
1. **[1/6] Dependencias**: Instalación de network-manager, pv, jq, xinit
2. **[2/6] Repositorio**: Clonación y configuración del código
3. **[3/6] Usuarios**: Creación de cuentas grado_1ro a grado_6to + pantallas de bienvenida
4. **[4/6] Auto-actualización**: Configuración del servicio systemd
5. **[5/6] Sincronización**: Elección entre Syncthing, NFS o ninguno
6. **[6/6] Finalización**: Resumen y próximos pasos

### Reanudación Automática

Si la instalación se interrumpe, simplemente vuelve a ejecutar el script:

```bash
sudo bash install_nea_shell.sh
```

El sistema detectará qué pasos ya se completaron y continuará desde el último pendiente.

## Opciones de Sincronización

### Opción 1: Syncthing (P2P)

**Ventajas:**
- Sincronización automática entre netbooks
- No requiere servidor central
- Funciona en redes locales

**Desventajas:**
- Requiere configuración manual en Web UI
- Cada dispositivo debe conocer a los demás

**Configuración Post-Instalación:**

1. Accede a http://localhost:8384
2. Desactiva HTTPS si tienes problemas (Acciones → Configuración → GUI)
3. Agrega carpetas a sincronizar (Agregar Carpeta)
4. Conecta con otros dispositivos (Agregar Dispositivo Remoto)

### Opción 2: NFS (Servidor Central)

**Ventajas:**
- Configuración centralizada
- Fácil administración desde un punto
- Ideal para laboratorios con servidor

**Desventajas:**
- Requiere servidor NFS configurado
- Dependencia de red

**Requisitos del Servidor NFS:**

```bash
# En el servidor (ejemplo con Debian)
apt install -y nfs-kernel-server

# Crear carpeta compartida
mkdir -p /export/nea_data
chmod 755 /export/nea_data

# Configurar exportación
echo "/export/nea_data 192.168.1.0/24(rw,sync,no_subtree_check)" >> /etc/exports

# Aplicar cambios
exportfs -ra
systemctl restart nfs-kernel-server
```

**Durante la instalación del cliente, necesitarás:**
- IP del servidor NFS (ej: 192.168.1.100)
- Ruta exportada (ej: /export/nea_data)

### Opción 3: Sin Sincronización

Elige esta opción si:
- Quieres configurar la sincronización más tarde
- Vas a usar un método personalizado
- Solo estás probando el sistema

Puedes volver a ejecutar el script y elegir una opción de sincronización después.

## Verificación de la Instalación

### Comprobar Usuarios

```bash
# Listar usuarios creados
getent passwd | grep grado_

# Debe mostrar:
# grado_1ro:x:1001:1001::/home/grado_1ro:/bin/bash
# grado_2do:x:1002:1002::/home/grado_2do:/bin/bash
# ...
```

### Comprobar Comandos

```bash
# Verificar que los comandos estén disponibles
which nea_tour nea_login nea_sync

# Debe mostrar rutas como:
# /usr/local/bin/nea_tour
# /usr/local/bin/nea_login
# ...
```

### Ver Contraseñas

```bash
# Solo accesible como root
sudo cat /root/nea_passwords.txt
```

### Probar Login

```bash
# Cambiar a un usuario de grado
su - grado_1ro

# Deberías ver el portal de NEA Shell
```

## Solución de Problemas Comunes

### Error: "Git no está instalado"

```bash
# Instalar git como root
su -
apt update
apt install -y git
exit

# Verificar instalación
git --version
```

### Error: "comando no encontrado" para git

Esto significa que git no está en el PATH del sistema. Instalalo manualmente:

```bash
# Como root
su -
apt update
apt install -y git

# Verificar
which git
# Debe mostrar: /usr/bin/git
```

### Error: "No se detectó conexión a internet"

```bash
# Verificar conectividad
ping -c 3 8.8.8.8

# Si no funciona, configurar red con NetworkManager
nmtui
```

### Error: "apt: comando no encontrado"

Si estás en una distribución que usa `yum` o `dnf` en lugar de `apt`:

```bash
# Para Fedora/CentOS/RHEL
yum install -y git curl wget openssl

# Para distribuciones más nuevas
dnf install -y git curl wget openssl
```

**Nota:** El script actual está optimizado para sistemas Debian/Ubuntu. Para otras distribuciones, considera adaptar los comandos de instalación de paquetes.

### Instalación se queda en "Actualizando índice de paquetes"

```bash
# Cancelar con Ctrl+C
# Limpiar cache de apt
sudo apt clean
sudo rm -rf /var/lib/apt/lists/*
sudo apt update

# Reintentar instalación
sudo bash install_nea_shell.sh
```

### Error de permisos al crear enlaces simbólicos

```bash
# Asegurarte de ejecutar como root
sudo -i
cd /home/tu_usuario/NEA_Shell
bash install_nea_shell.sh
```

## Reinstalación Completa

Para borrar todo y empezar de nuevo:

```bash
# Eliminar usuarios (como root)
for grade in 1ro 2do 3ro 4to 5to 6to; do
    userdel -r grado_$grade 2>/dev/null
done

# Eliminar estado de instalación
rm /var/lib/nea_shell_install_state

# Eliminar repositorio
rm -rf /opt/nea_shell

# Eliminar enlaces simbólicos
rm /usr/local/bin/nea_*

# Re-ejecutar instalador
cd NEA_Shell
sudo bash install_nea_shell.sh
```

## Desinstalación

Para remover completamente NEA Shell:

```bash
# Ejecutar como root o con sudo
sudo bash << 'EOF'
# Detener servicios
systemctl stop nea-sync.service
systemctl disable nea-sync.service

# Remover usuarios
for grade in 1ro 2do 3ro 4to 5to 6to; do
    userdel -r grado_$grade
done

# Remover archivos
rm -rf /opt/nea_shell
rm -rf /opt/nea_backups
rm /root/nea_passwords.txt
rm /var/lib/nea_shell_install_state
rm /etc/systemd/system/nea-sync.service

# Remover enlaces simbólicos
rm /usr/local/bin/nea_*

# Recargar systemd
systemctl daemon-reload

echo "NEA Shell desinstalado completamente"
EOF
```

## Soporte

Si encuentras problemas no cubiertos en esta guía:

1. Verifica el estado de instalación: `cat /var/lib/nea_shell_install_state`
2. Revisa los logs del sistema: `journalctl -xe`
3. Reporta el issue en GitHub con detalles del error

## Siguientes Pasos

Después de la instalación exitosa:

1. Lee el archivo de contraseñas: `sudo cat /root/nea_passwords.txt`
2. Prueba el acceso: `su - grado_1ro`
3. Explora el sistema: `nea_tour`
4. Configura la sincronización si elegiste Syncthing
5. Lee la documentación completa en `README.md`
