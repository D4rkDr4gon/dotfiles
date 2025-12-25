# 🐉 D4rkDr4g0n Dotfiles

![Distro](https://img.shields.io/badge/Distro-Kali%20%7C%20Arch-red?style=for-the-badge&logo=linux)
![WM](https://img.shields.io/badge/WM-Qtile-blue?style=for-the-badge&logo=python)
![Status](https://img.shields.io/badge/Status-Stable-success?style=for-the-badge)
![License](https://img.shields.io/badge/License-MIT-orange?style=for-the-badge)

'''
██████╗ ██╗  ██╗██████╗ ██╗  ██╗██████╗ ██████╗  █████╗  ██████╗  ██████╗ ███╗   ██╗
██╔══██╗██║  ██║██╔══██╗██║ ██╔╝██╔══██╗██╔══██╗██╔══██╗██╔════╝ ██╔═══██╗████╗  ██║
██║  ██║███████║██████╔╝█████╔╝ ██║  ██║██████╔╝███████║██║  ███╗██║   ██║██╔██╗ ██║
██║  ██║╚════██║██╔══██╗██╔═██╗ ██║  ██║██╔══██╗██╔══██║██║   ██║██║   ██║██║╚██╗██║
██████╔╝     ██║██║  ██║██║  ██╗██████╔╝██║  ██║██║  ██║╚██████╔╝╚██████╔╝██║ ╚████║
╚═════╝      ╚═╝╚═╝  ╚═╝╚═╝  ╚═╝╚═════╝ ╚═╝  ╚═╝╚═╝  ╚═╝ ╚═════╝  ╚═════╝ ╚═╝  ╚═══╝
'''

# 📖 Sobre el Proyecto

Este repositorio contiene la configuración personal de mi entorno de trabajo ("Rice"). El objetivo es lograr un sistema minimalista, estético y altamente eficiente, optimizado tanto para Pentesting como para Desarrollo.

¿Qué se logra con esta configuración?

    Eficiencia: Todo el entorno se controla mediante el teclado (Tiling Window Manager).

    Modularidad: Qtile está configurado en módulos de Python fáciles de editar.

    Estética Cyberpunk: Tema de colores oscuros con acentos en rojo sangre y transparencias.

    Arsenal Completo: Integración automática de herramientas de BlackArch en sistemas Arch.

    Sincronización: Sistema basado en enlaces simbólicos para mantener la configuración actualizada.

---

# 📸 Galería

---
	
# 🛠️ El Arsenal (Tech Stack)

    Window Manager: Qtile (Python based)

    Barra: Polybar

    Terminal: Kitty

    Shell: Zsh + Oh My Zsh + Syntax Highlighting

    Launcher: Rofi

    Compositor: Picom (Fork con Blur)

    Editor: Sublime Text / Neovim

    Fuente: Hack Nerd Font

---

# ⚡ Instalación Automática (Recomendada)

He desarrollado un script en Python (install.py) que automatiza todo el proceso. Detecta tu distribución (Kali o Arch), instala dependencias, fuentes y crea los enlaces simbólicos.
### 1. Clonar

	git clone [https://github.com/TU_USUARIO/dotfiles.git](https://github.com/TU_USUARIO/dotfiles.git) ~/dotfiles
	cd ~/dotfiles

### 2. Ejecutar Instalador

	python3 install.py

Nota: El script pedirá tu contraseña de sudo para instalar paquetes. Si estás en Arch, configurará automáticamente los repositorios de BlackArch.

### 3. Reiniciar

Una vez finalizado, cierra sesión y vuelve a entrar seleccionando Qtile en tu gestor de sesiones, o simplemente reinicia la PC.

---

# ⚙️ Instalación Manual

Si prefieres tener control total o el script falla, sigue estos pasos:

### 1. Instalar Dependencias

En Kali Linux / Debian:

	sudo apt update
	sudo apt install qtile polybar picom rofi kitty nitrogen brightnessctl pulseaudio-utils zsh curl wget git flameshot thunar thunderbird obsidian

En Arch Linux:

	sudo pacman -S qtile polybar picom rofi kitty nitrogen brightnessctl pavucontrol zsh curl wget git flameshot base-devel thunar thunderbird obsidian

### 2. Instalar Fuentes

Debes descargar e instalar Hack Nerd Font para que los iconos se vean bien.


	wget [https://github.com/ryanoasis/nerd-fonts/releases/latest/download/Hack.zip](https://github.com/ryanoasis/nerd-fonts/releases/latest/download/Hack.zip)
	unzip Hack.zip -d ~/.local/share/fonts
	fc-cache -fv

### 3. Crear Enlaces Simbólicos (Symlinks)

Debes enlazar los archivos del repo a tu carpeta .config. ¡Cuidado! Esto reemplazará tus configuraciones actuales.

- Crear carpetas si no existen

	mkdir -p ~/.config

- Enlaces (Ejecutar desde ~/dotfiles)

	ln -sf ~/dotfiles/qtile ~/.config/qtile
	ln -sf ~/dotfiles/polybar ~/.config/polybar
	ln -sf ~/dotfiles/picom ~/.config/picom
	ln -sf ~/dotfiles/rofi ~/.config/rofi
	ln -sf ~/dotfiles/kitty ~/.config/kitty
	ln -sf ~/dotfiles/sublime-text ~/.config/sublime-text
	ln -sf ~/dotfiles/zshrc ~/.zshrc

### 4. Permisos

	chmod +x ~/.config/polybar/launch.sh

---

# ⌨️ Atajos de Teclado (Cheatsheet)

	- Mod = Tecla Super (Windows) 
	- Alt = Alt Izquierdo

## 🚀 Aplicaciones

	Atajo	Aplicación
	Mod + Enter	Terminal (Kitty)
	Mod + S	Launcher (Rofi)
	Mod + B	Navegador (Firefox)
	Mod + A	Archivos (Thunar)
	Mod + E	Email (Thunderbird)
	Mod + O	Notas (Obsidian)
	Mod + P	Contraseñas (Bitwarden)

## 🖼️ Ventanas y Gestión

	Atajo	Acción
	Mod + Q	Cerrar ventana activa
	Mod + F	Pantalla completa (Fullscreen)
	Mod + T	Modo flotante (Toggle floating)
	Alt + Tab	Moverse entre ventanas abiertas
	Mod + Tab	Cambiar Layout (Espacio de trabajo)
	Mod + Shift + Flechas	Mover ventana (Swap)
	Mod + Ctrl + Flechas	Redimensionar ventana (Grow)
	Mod + N	Normalizar tamaños

## ⚙️ Sistema y Multimedia

	Atajo	Acción
	Mod + Ctrl + R	Reiniciar Qtile (Recargar cambios)
	Mod + L	Cerrar Sesión / Bloquear PC
	Print	Captura de pantalla (Flameshot)
	Mod + Shift + S	Captura de pantalla (Flameshot)
	Fn + Volumen	Subir/Bajar/Mutear Audio
	Fn + Brillo	Subir/Bajar Brillo

---

# 🐛 Debugging / Solución de Problemas

1. Los iconos se ven como cuadrados raros

❌ Causa: No tienes instalada la fuente correcta. ✅ Solución: Ejecuta el paso 2 de la instalación manual (Hack Nerd Font) y reinicia.

2. Polybar no aparece

❌ Causa: El nombre de tu monitor en config.ini no coincide con el tuyo. ✅ Solución:

    Ejecuta xrandr en la terminal y mira el nombre de tu salida (ej: HDMI-1, eDP-1).

    Edita ~/.config/polybar/config.ini.

    Busca monitor = ... y cámbialo por el tuyo.

3. Qtile no inicia o pantalla negra

❌ Causa: Error de sintaxis en config.py. ✅ Solución:

    Entra a una TTY (Ctrl + Alt + F2).

    Logueate y ejecuta: qtile check.

    Te dirá exactamente en qué línea está el error de Python.

---

# 🤝 Contribuir

Si encuentras un error o quieres mejorar un módulo:

    Haz un Fork.

    Crea una rama (git checkout -b feature/nueva-mejora).

    Haz Commit (git commit -m 'Add some feature').

    Haz Push (git push origin feature/nueva-mejora).

    Abre un Pull Request.

---

Desarrollado por D4rkDr4g0n 🐉
