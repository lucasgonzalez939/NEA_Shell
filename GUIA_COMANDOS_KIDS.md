# 📚 Guía de Comandos para Niños - NEA Shell

## Filosofía Educativa

Cada comando se explica con:
1. **Nombre en inglés** - Para entender el origen
2. **Traducción al español** - Para comprender su función
3. **Analogía del mundo real** - Para facilitar la comprensión
4. **Ejemplos prácticos** - Para aprender haciendo

---

## 🎯 Comandos por Nivel

### Nivel 1: Navegación (50 XP)

#### 📂 `cd` - Change Directory
**Español:** Cambiar de carpeta/directorio  
**Analogía:** Como caminar de una habitación a otra en tu casa  
**Uso:**
```bash
cd documentos     # Entrar a la carpeta 'documentos'
cd ..             # Volver a la carpeta anterior (subir un nivel)
cd ~              # Ir a tu carpeta personal (casa)
cd /              # Ir a la raíz del sistema (edificio completo)
```

#### 📍 `pwd` - Print Working Directory
**Español:** Mostrar ubicación actual  
**Analogía:** Como preguntar "¿Dónde estoy?"  
**Uso:**
```bash
pwd               # Muestra tu ubicación actual
```

---

### Nivel 2: Visualización (60 XP)

#### 📋 `ls` - List
**Español:** Listar  
**Analogía:** Como ver qué hay dentro de una mochila o cajón  
**Uso:**
```bash
ls                # Ver archivos normales
ls -l             # Ver con detalles (tamaño, fecha, permisos)
ls -a             # Ver TODO (incluso archivos ocultos que empiezan con .)
ls -la            # Combinar: ver TODO con detalles
ls *.txt          # Ver solo archivos .txt
```

**Colores en ls:**
- 🔵 Azul = Carpetas
- ⚪ Blanco = Archivos normales
- 🟢 Verde = Archivos ejecutables (programas)
- 🔴 Rojo = Archivos comprimidos (.zip, .tar)

---

### Nivel 3: Patrones y Tipos (70 XP)

#### ⭐ `*` - Comodín (Wildcard)
**Español:** Cualquier cosa  
**Analogía:** Como el comodín en un juego de cartas  
**Uso:**
```bash
ls *.txt          # Todos los archivos que terminan en .txt
ls foto*          # Todo lo que empieza con 'foto'
ls *2024*         # Todo lo que contiene '2024' en el nombre
rm *.tmp          # ¡CUIDADO! Borra todos los .tmp
```

#### 🔍 `file` - Identify File Type
**Español:** Identificar tipo de archivo  
**Analogía:** Como un detector que te dice qué hay en una caja cerrada  
**Uso:**
```bash
file documento.txt       # Te dice: "archivo de texto"
file foto.jpg            # Te dice: "imagen JPEG"
file misterio            # Te dice qué es realmente
```

---

### Nivel 4: Lectura de Datos (80 XP)

#### 📖 `cat` - Concatenate
**Español:** Ver/Mostrar contenido  
**Analogía:** Como abrir un libro y leer todas las páginas  
**Uso:**
```bash
cat archivo.txt          # Ver contenido completo
cat file1.txt file2.txt  # Ver múltiples archivos seguidos
cat *.txt                # Ver todos los archivos .txt
```

#### 🔎 `grep` - Global Regular Expression Print
**Español:** Buscar texto  
**Analogía:** Como usar Ctrl+F para buscar una palabra  
**Uso:**
```bash
grep palabra archivo.txt         # Buscar 'palabra' en archivo
grep -i palabra archivo.txt      # Buscar sin importar mayúsculas
grep -r texto .                  # Buscar en todas las carpetas
grep "frase completa" archivo    # Buscar frase con espacios
```

---

### Nivel 5: Organización (90 XP)

#### 📄 `cp` - Copy
**Español:** Copiar  
**Analogía:** Como fotocopiar un documento (tienes el original + la copia)  
**Uso:**
```bash
cp original.txt copia.txt        # Copiar archivo
cp -r carpeta carpeta2           # Copiar carpeta completa (-r = recursivo)
cp *.txt respaldo/               # Copiar todos los .txt a carpeta
```

#### 🚚 `mv` - Move
**Español:** Mover o Renombrar  
**Analogía:** Como mover algo a otra habitación, o cambiarle el nombre  
**Uso:**
```bash
mv archivo.txt otra_carpeta/     # Mover archivo
mv viejo.txt nuevo.txt           # Renombrar archivo
mv *.jpg fotos/                  # Mover todas las imágenes
```

#### 📁 `mkdir` - Make Directory
**Español:** Crear carpeta  
**Analogía:** Como construir un cajón nuevo para guardar cosas  
**Uso:**
```bash
mkdir mi_carpeta                 # Crear carpeta simple
mkdir -p ruta/a/carpeta          # Crear carpetas anidadas
mkdir fotos videos documentos    # Crear múltiples carpetas
```

---

### Nivel 6: Borrado Responsable (100 XP)

#### ⚠️ `rm` - Remove
**Español:** Borrar (¡PERMANENTEMENTE!)  
**Analogía:** Como tirar algo a la basura y que el camión se lo lleve (NO hay papelera de reciclaje)  
**⚡ PELIGRO:** ¡No se puede deshacer!  

**Uso SEGURO:**
```bash
# SIEMPRE hacer esto PRIMERO:
ls basura.txt                    # Ver qué vas a borrar

# LUEGO borrar:
rm basura.txt                    # Borrar archivo
rm -i importante.txt             # Preguntar antes de borrar (-i = interactivo)
```

**⛔ NUNCA HAGAS ESTO:**
```bash
rm -rf /                         # ¡DESTRUYE TODO EL SISTEMA!
rm -rf *                         # ¡Borra todo en la carpeta actual!
rm *.* sin verificar primero     # Puede borrar más de lo esperado
```

#### 🗑️ `rmdir` - Remove Directory
**Español:** Borrar carpeta vacía  
**Analogía:** Solo funciona si el cajón está vacío  
**Uso:**
```bash
rmdir carpeta_vacia              # Borrar carpeta vacía
rmdir -p ruta/vacia/anidada      # Borrar jerarquía de carpetas vacías
```

---

### Nivel 7: Automatización (120 XP)

#### ✨ `touch` - Create Empty File
**Español:** Crear archivo vacío  
**Analogía:** Como crear una hoja en blanco  
**Uso:**
```bash
touch nuevo.txt                  # Crear archivo vacío
touch archivo1 archivo2 archivo3 # Crear múltiples archivos
```

#### 💬 `echo` - Print Text
**Español:** Imprimir/Escribir texto  
**Analogía:** Como gritarle algo a la computadora para que lo repita  
**Uso:**
```bash
echo "Hola Mundo"                # Mostrar en pantalla
echo "Texto" > archivo.txt       # Guardar en archivo (sobrescribe)
echo "Más texto" >> archivo.txt  # Añadir al final del archivo
echo $HOME                       # Mostrar valor de variable
```

#### 🔐 `chmod` - Change Mode
**Español:** Cambiar permisos  
**Analogía:** Como darle permiso a alguien para usar tus juguetes  
**Uso:**
```bash
chmod +x script.sh               # Hacer ejecutable (puede correr como programa)
chmod -x script.sh               # Quitar permiso de ejecución
chmod 755 archivo                # Permisos completos (avanzado)
```

---

## 🎓 Comandos Útiles Adicionales

### Para obtener ayuda:
```bash
man comando          # Manual completo del comando
comando --help       # Ayuda rápida
```

### Para el día a día:
```bash
clear               # Limpiar pantalla
history             # Ver historial de comandos usados
wc archivo.txt      # Contar líneas, palabras y caracteres
head archivo.txt    # Ver primeras 10 líneas
tail archivo.txt    # Ver últimas 10 líneas
```

---

## 🚦 Reglas de Oro para Niños

1. **SIEMPRE** usa `ls` antes de `rm` para ver qué vas a borrar
2. **NUNCA** uses `rm -rf` sin supervisión de un adulto
3. **LEE** bien los mensajes de error, te dan pistas
4. **PRACTICA** en carpetas de prueba primero
5. **PREGUNTA** si no estás seguro antes de borrar algo
6. **USA** `pwd` si te pierdes y no sabes dónde estás
7. **COMBINA** comandos para ser más eficiente (ej: `ls -la`)

---

## 🎯 Tips para Padres y Docentes

### Enseñanza Progresiva:
1. Empezar solo con `cd` y `ls` (Nivel 1-2)
2. Agregar visualización y búsqueda (Nivel 3-4)
3. Practicar organización antes de borrado (Nivel 5)
4. **Supervisar siempre** el uso de `rm` (Nivel 6)
5. Fomentar creatividad con scripts (Nivel 7)

### Crear Entorno Seguro:
```bash
# Crear carpeta de práctica segura
mkdir ~/practica_terminal
cd ~/practica_terminal

# Crear archivos de prueba
touch archivo1.txt archivo2.txt
mkdir carpeta1 carpeta2
echo "Contenido de prueba" > archivo1.txt
```

### Señales de Alerta:
- ⚠️ Si ves `rm -rf` sin supervisión
- ⚠️ Si intentan borrar desde `/` (raíz del sistema)
- ⚠️ Si usan `sudo` sin entender qué hacen
- ⚠️ Si ejecutan comandos copiados de internet sin leer

---

## 📚 Recursos Adicionales

### Páginas para practicar:
- **OverTheWire Bandit** - Juegos de terminal
- **Command Line Challenge** - Desafíos interactivos
- **Terminus** - Juego de aventura en terminal

### Libros recomendados:
- "The Linux Command Line" by William Shotts
- "Learn Enough Command Line to Be Dangerous"

---

**Creado con ❤️ para NEA Shell**  
*Making the terminal accessible and fun for everyone!*
