# 🐧 D4rkDr4gon's Dotfiles | Kali Linux 2025

Este repositorio contiene mis configuraciones personalizadas para un entorno de trabajo minimalista, modular y eficiente. Optimizado para **Kali Linux** utilizando **Qtile** como Window Manager y **Polybar** como barra de estado.

---

## 📊 Estructura del Proyecto

He modularizado cada componente para facilitar el mantenimiento y la personalización sin riesgo de romper la configuración global.

### 🐍 Qtile (Gestor de Ventanas)
Configuración dividida en lógica de Python:
- `config.py`: Punto de entrada que orquesta la carga de módulos.
- `modules/keys.py`: Definición de atajos de teclado y multimedia.
- `modules/groups.py`: Gestión de escritorios virtuales (WEB, CTF, WORK, GENERAL, VPN).
- `modules/hooks.py`: Ganchos de sistema y **Autostart** (Nitrogen, Picom, Polybar).
- `modules/screens.py`: Configuración de monitores y wallpapers.
- `modules/layouts.py`: Gestión de ventanas (Columns, MonadTall).
- `modules/mouse.py`: Comportamiento del ratón en ventanas flotantes.

### 🎨 Polybar (Barra de Estado)
Modularizada por widgets para una edición rápida:
- `config.ini`: Estética general, fuentes y posición.
- `colors.ini`: Paleta de colores centralizada.
- `modules/`: Archivos `.ini` individuales para Batería, Brillo, Red, Audio y más.
- `launch.sh`: Script para refrescar la barra automáticamente.

---

## ⌨️ Atajos de Teclado (Keybindings)

Estos son los atajos principales configurados en `modules/keys.py`:

Usa el código con precaución.
Combinación
	Acción
Mod + Enter	Abrir Terminal (Alacritty)
Mod + S	Menú de Aplicaciones (Rofi)
Mod + B	Navegador Web (Firefox)
Mod + E	Correo Electrónico (Thunderbird)
Mod + A	Explorador de Archivos (Thunar)
Mod + O	Notas (Obsidian)
Mod + Q	Cerrar Ventana Enfocada
Mod + Ctrl + R	Reiniciar Qtile (Aplicar cambios)
Mod + Shift + S	Captura de Pantalla (Flameshot)
PrintScreen	Captura de Pantalla Completa
Controles Multimedia:

    Fn + Brillo: Controlado mediante brightnessctl.
    Fn + Volumen: Controlado mediante pactl (Pulseaudio).

🛠️ Guía de Instalación (Paso a Paso)
Para replicar este entorno exactamente igual, sigue estos pasos:
1. Instalar Dependencias
Asegúrate de tener todas las herramientas necesarias instaladas en tu Kali Linux:
bash

sudo apt update && sudo apt install qtile polybar alacritty picom nitrogen brightnessctl pulseaudio-utils rofi thunar flameshot thunderbird obsidian fonts-jetbrains-mono

Usa el código con precaución.
2. Clonar el Repositorio
bash

git clone github.com ~/dotfiles

Usa el código con precaución.
3. Desplegar Configuraciones
Copia los archivos a sus rutas correspondientes en el directorio .config:
bash

# Crear carpetas si no existen
mkdir -p ~/.config/{qtile,polybar,alacritty}

# Copiar Qtile
cp -r ~/dotfiles/qtile/* ~/.config/qtile/

# Copiar Polybar
cp -r ~/dotfiles/polybar/* ~/.config/polybar/

# Copiar Alacritty
cp -r ~/dotfiles/alacritty/* ~/.config/alacritty/

# Configuración de Shell y otros
cp ~/dotfiles/zshrc ~/.zshrc

Usa el código con precaución.
4. Permisos de Ejecución
Es vital que los scripts tengan permisos para que Qtile pueda lanzarlos:
bash

chmod +x ~/.config/polybar/launch.sh

Usa el código con precaución.
5. Aplicar Cambios
Reinicia tu sesión o presiona Mod + Control + R si ya estás dentro de Qtile para ver tu nueva barra y atajos funcionando.

📝 Notas

    Modularidad: Si deseas agregar un nuevo atajo, edita únicamente ~/.config/qtile/modules/keys.py.
    Iconos: Esta configuración utiliza JetBrainsMono Nerd Font. Si los iconos no se ven, asegúrate de tener instalada una "Nerd Font".

Mantenido por D4rkDr4gon 
