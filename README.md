# NEA Shell

**Sistema de Entrenamiento en Terminal para la Nueva Escuela Argentina (NEA)**

NEA Shell es un entorno de aprendizaje basado en la línea de comandos (CLI) diseñado para estudiantes de nivel primario (1° a 6° grado). El proyecto transforma netbooks de bajos recursos en terminales de "agentes" donde los alumnos desarrollan memoria muscular, habilidades de lectura técnica y lógica de programación a través de misiones gamificadas.

---

##  Objetivos del Proyecto

### Pedagógicos

* **Memoria Muscular:** Fomentar la precisión en el tipeo y el reconocimiento de sintaxis.
* **Navegación Abstracta:** Enseñar a los estudiantes a visualizar estructuras de directorios sin una interfaz gráfica.
* **Lógica de Sistemas:** Introducir conceptos de permisos, extensiones de archivos y automatización (scripting).
* **Lectura Comprensiva:** Obligar al estudiante a leer la salida de la terminal para resolver acertijos.

### Técnicos

* **Eficiencia:** Optimizado para hardware limitado (Netbooks con 2GB RAM).
* **Centralización:** Administración remota total mediante un repositorio de GitHub.
* **Persistencia:** Sincronización de progreso (XP y niveles) entre diferentes equipos mediante archivos JSON y Syncthing.
* **Resiliencia:** Capacidad de trabajar offline con actualizaciones automáticas al detectar conexión.

---

##  Estructura del Repositorio

Para mantener el proyecto organizado, el repositorio sigue esta jerarquía:

```text
NEA_Shell/
├── install_nea_shell.sh   # Script de despliegue inicial (ejecutar como root)
├── README.md              # Documentación general
├── scripts/               # Núcleo del sistema (se copian a /usr/local/bin/)
│   ├── nea_login.sh       # Portal de acceso e identificación de alumnos
│   ├── nea_tour.sh        # Motor de misiones y validación de XP
│   ├── nea_sync.sh        # Gestor de actualizaciones automáticas (GitHub)
│   └── nea_wifi.sh        # Utilidad de configuración de red
├── core/                  # Configuración del sistema
│   └── progress_base.json # Plantilla para nuevos perfiles de alumnos
└── missions/              # Archivos de datos para los niveles (Read-only)
    ├── nivel1/            # Archivos para misiones de 'ls' y 'cd'
    └── nivel2/            # Archivos para misiones de 'cat' y 'grep'

```

---

##  Aspectos Técnicos

### El Andamiaje de Sincronización

El sistema utiliza un servicio de `systemd` que ejecuta `nea_sync.sh` al inicio. Este script realiza un `git pull` desde el repositorio de **lucasgonzalez939** y redistribuye los archivos actualizados en el sistema local. Esto permite que el docente actualice el contenido de todas las netbooks simplemente haciendo un `git push`.

### Gestión de Usuarios

* **Usuarios de Grado:** Se crean cuentas de sistema (`grado_1ro` a `grado_6to`) para segmentar los grupos.
* **Sandbox de Alumno:** Cada alumno tiene su propia carpeta dentro del usuario de grado, donde se genera un archivo `.progress.json` oculto que rastrea sus logros.

---

##  Mapa de Entrenamiento (Roadmap de Comandos)

Los alumnos progresan desbloqueando comandos en el siguiente orden:

| Nivel | Comandos | Concepto Clave | Explicación |
| --- | --- | --- | --- |
| **1** | `cd`, `pwd` | Navegación y Rutas | **cd** = Change Directory (Cambiar de carpeta)<br>**pwd** = Print Working Directory (Mostrar ubicación) |
| **2** | `ls`, `ls -l`, `ls -a` | Visualización | **ls** = List (Listar archivos y carpetas) |
| **3** | `*`, `file` | Extensiones y Comodines | **\*** = Comodín (cualquier texto)<br>**file** = Identificar tipo de archivo |
| **4** | `cat`, `grep` | Lectura de datos | **cat** = Concatenate (Ver contenido)<br>**grep** = Buscar texto en archivos |
| **5** | `cp`, `mv`, `mkdir` | Organización | **cp** = Copy (Copiar)<br>**mv** = Move (Mover/Renombrar)<br>**mkdir** = Make Directory (Crear carpeta) |
| **6** | `rm`, `rmdir` | Borrado Responsable | **rm** = Remove (Borrar archivo)<br>**rmdir** = Remove Directory (Borrar carpeta vacía) |
| **7** | `touch`, `echo`, `chmod` | Scripting Básico | **touch** = Crear archivo vacío<br>**echo** = Imprimir texto<br>**chmod** = Cambiar permisos |

### 📚 Comandos Adicionales Útiles (Futuros Niveles)

- `wc` - Word Count (Contar palabras/líneas)
- `head` / `tail` - Ver inicio/final de archivo
- `clear` - Limpiar pantalla
- `history` - Ver historial de comandos
- `man` - Manual de ayuda de comandos

---

##  Instalación Inicial

En una netbook con Linux (Debian/Ubuntu/Fedora), abre una terminal y ejecuta:

```bash
# Clonar e instalar
git clone https://github.com/lucasgonzalez939/NEA_Shell.git
cd NEA_Shell
sudo chmod +x install_nea_shell.sh
sudo ./install_nea_shell.sh

```

---

## Instalación

### Instalación Completa

```bash
sudo bash install_nea_shell.sh
```

El script es interactivo y te guiará por el proceso. Características:

- ✅ **Reanudable**: Si falla, vuelve a ejecutarlo y continuará desde donde quedó
- ✅ **Seguro**: No recrea usuarios ni sobrescribe configuraciones existentes
- ✅ **Interactivo**: Opciones para Syncthing, NFS o ninguno

### Opciones de Sincronización

#### Opción 1: Syncthing (Recomendado para P2P)
- Sincronización automática entre múltiples nodos
- Requiere configuración manual del Web UI
- Acceso: http://localhost:8384

#### Opción 2: NFS (Recomendado para servidor central)
- Cliente de carpeta compartida en red
- Requiere servidor NFS configurado
- Montaje automático en `/mnt/nea_shared`

#### Opción 3: Sin sincronización
- Configuración manual posterior

---

##  Mantenimiento (Para el Docente)

Para añadir una nueva misión o corregir un script:

1. Realiza los cambios en tu computadora local dentro de la carpeta del repo.
2. Sube los cambios:
```bash
git add .
git commit -m "Añadida Misión 8: Redirección de salida"
git push origin main

```


3. Las netbooks descargarán los cambios automáticamente en el próximo reinicio o ciclo de sincronización.

---

## 🔒 Seguridad y Backups

### Contraseñas Seguras

Desde la versión 3.0, el sistema genera **contraseñas aleatorias únicas** para cada usuario de grado durante la instalación. Las contraseñas se guardan en:

```
/root/nea_passwords.txt
```

**Importante:** Este archivo solo es accesible por el usuario root. Guarda una copia segura en caso de necesitar recuperar las contraseñas.

### Sistema de Backup Automático

Cada vez que se ejecuta `nea_sync.sh`, el sistema crea un respaldo automático de todos los datos de estudiantes en:

```
/opt/nea_backups/YYYYMMDD_HHMMSS/
├── grado_1ro/
├── grado_2do/
...
└── grado_6to/
```

* **Retención:** Se mantienen los últimos 7 backups automáticamente.
* **Contenido:** Incluye todos los archivos `.progress.json` y carpetas de estudiantes.

### Restaurar un Backup

Si necesitas recuperar datos de estudiantes de un backup anterior:

```bash
sudo /usr/local/bin/nea_restore.sh
```

El script te mostrará una lista de backups disponibles y te guiará en el proceso de restauración.

**Nota:** La restauración crea una copia de seguridad de los datos actuales antes de sobrescribirlos (sufijo `.old_*`).

---

## 🔧 Solución de Problemas

### Las netbooks no sincronizan con GitHub

1. Verificar conectividad:
```bash
ping 8.8.8.8
```

2. Revisar logs del servicio:
```bash
journalctl -u nea-sync.service -n 50
```

3. Forzar sincronización manual:
```bash
sudo systemctl restart nea-sync.service
# o ejecutar directamente:
sudo /usr/local/bin/nea_sync.sh
```

### Un estudiante perdió su progreso

1. Listar backups disponibles:
```bash
sudo ls -lh /opt/nea_backups/
```

2. Restaurar desde un backup específico:
```bash
sudo /usr/local/bin/nea_restore.sh
```

### Syncthing no se conecta al servidor

1. Verificar que el servicio está corriendo:
```bash
systemctl status syncthing@root
```

2. Revisar la configuración:
```bash
# Acceder a la interfaz web local
firefox http://127.0.0.1:8384
```

3. Verificar conectividad con el servidor:
```bash
ping 192.168.1.100  # IP del servidor OMV
```

### Error al instalar: "contraseña insegura"

El sistema ahora genera contraseñas aleatorias automáticamente. Si ves este error, asegúrate de tener instalado `openssl`:

```bash
sudo apt install openssl
```

#### Reinstalar completamente
```bash
sudo rm /var/lib/nea_shell_install_state
sudo bash install_nea_shell.sh
```

#### Ver estado de instalación
```bash
cat /var/lib/nea_shell_install_state
```

#### Configurar solo la sincronización
```bash
# Marca pasos previos como completos y ejecuta solo sync
echo "dependencies=done" | sudo tee /var/lib/nea_shell_install_state
echo "repository=done" | sudo tee -a /var/lib/nea_shell_install_state
echo "users=done" | sudo tee -a /var/lib/nea_shell_install_state
echo "autoupdate=done" | sudo tee -a /var/lib/nea_shell_install_state
sudo bash install_nea_shell.sh
```

#### Problemas con NFS
```bash
# Verificar que el servidor NFS exporta correctamente
showmount -e <IP_DEL_SERVIDOR>

# Montar manualmente
sudo mount <IP_DEL_SERVIDOR>:/export/nea_data /mnt/nea_shared

# Ver logs de montaje
dmesg | grep -i nfs
```

#### Problemas con Syncthing
```bash
# Ver logs del servicio
sudo journalctl -u syncthing@neahost -n 50

# Reiniciar servicio
sudo systemctl restart syncthing@neahost

# Verificar estado
sudo systemctl status syncthing@neahost
```

---

###  Sincronización de Datos (Mesh Network)
El sistema utiliza **Syncthing** para crear una red descentralizada entre las netbooks y un servidor central (OpenMediaVault).
* **Protocolo:** BEP (Block Exchange Protocol).
* **Topología:** Estrella (Hub & Spoke) con el servidor como nodo central.
* **Seguridad:** Los datos están cifrados en tránsito mediante TLS.
* **Persistencia:** Los perfiles de los alumnos (`.progress.json`) se sincronizan en tiempo real, permitiendo la movilidad total en el laboratorio.


**Desarrollado por Lucas Gonzalez** *Makerspace & Robotics - Nueva Escuela Argentina*

