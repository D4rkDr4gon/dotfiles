# 🐉 D4rkDr4g0n Dotfiles

![Distro](https://img.shields.io/badge/Distro-Kali%20%7C%20Arch-red?style=for-the-badge&logo=linux)
![WM](https://img.shields.io/badge/WM-Qtile-blue?style=for-the-badge&logo=python)
![Status](https://img.shields.io/badge/Status-Stable-success?style=for-the-badge)
![License](https://img.shields.io/badge/License-MIT-orange?style=for-the-badge)

██████╗ ██╗  ██╗██████╗ ██╗  ██╗██████╗ ██████╗  █████╗  ██████╗  ██████╗ ███╗   ██╗
██╔══██╗██║  ██║██╔══██╗██║ ██╔╝██╔══██╗██╔══██╗██╔══██╗██╔════╝ ██╔═══██╗████╗  ██║
██║  ██║███████║██████╔╝█████╔╝ ██║  ██║██████╔╝███████║██║  ███╗██║   ██║██╔██╗ ██║
██║  ██║╚════██║██╔══██╗██╔═██╗ ██║  ██║██╔══██╗██╔══██║██║   ██║██║   ██║██║╚██╗██║
██████╔╝     ██║██║  ██║██║  ██╗██████╔╝██║  ██║██║  ██║╚██████╔╝╚██████╔╝██║ ╚████║
╚═════╝      ╚═╝╚═╝  ╚═╝╚═╝  ╚═╝╚═════╝ ╚═╝  ╚═╝╚═╝  ╚═╝ ╚═════╝  ╚═════╝ ╚═╝  ╚═══╝

## 📋 Resumen General

Este repositorio contiene una configuración personalizada de entorno de trabajo ("Rice") optimizada para **Arch Linux** (aunque también compatible con Kali Linux), utilizando **Qtile** como window manager principal. La configuración está diseñada con una estética **cyberpunk** y enfocada tanto en **pentesting** como en **desarrollo**.

## 🏗️ Estructura de Configuración

### Componentes Principales

```
dotfiles/
├── qtile/           # Window manager principal
├── polybar/         # Barra de estado personalizada
├── picom/           # Compositor con efectos de blur
├── rofi/            # Launcher de aplicaciones
├── kitty/           # Terminal moderno
├── zsh/             # Shell configurado
├── sublime-text/    # Editor de texto
├── lazy-nvim/       # Configuración de Neovim
├── nvchad/          # Configuración alternativa de Neovim
├── fastfetch/       # Información del sistema
├── onedrive/        # Sincronización con OneDrive
├── automat/         # Scripts de automatización
└── recursos/        # Recursos adicionales
```

---


## 🎨 Características Principales

### 1. **Tema Cyberpunk**

- **Colores**: Oscuros con acentos en rojo sangre
- **Transparencias**: Efectos de blur y transparencias
- **Fuente**: Hack Nerd Font para iconos y símbolos

### 2. **Window Manager: Qtile**

- **Basado en Python**: Configuración modular y fácil de editar
- **Tiling**: Gestión eficiente de ventanas
- **Control por teclado**: Todo el entorno controlado con atajos

### 3. **Stack Tecnológico**

```
Window Manager: Qtile (Python)
Barra: Polybar
Terminal: Kitty
Shell: Zsh + powerlevel10K
Launcher: Rofi
Compositor: Picom (con blur)
Editor: Sublime Text / Neovim
Info Sistema: Fastfetch personalizado
```

---


## 🔧 Configuraciones Detalladas

### Qtile Configuration

- **Layouts**: MonadTall, MonadWide, Floating
- **Widgets**: Barra personalizada con información del sistema
- **Atajos**: Control completo por teclado
- **Autostart**: Scripts de inicio automático

### Polybar

- **Módulos**: Workspace, ventana, reloj, volumen, batería, red
- **Tema**: Coherente con el tema cyberpunk
- **Integración**: Con Qtile y sistema

### Picom

- **Blur**: Efectos de desenfoque en ventanas
- **Sombras**: Sombras personalizadas
- **Transparencias**: Niveles de opacidad configurados

### Kitty Terminal

- **Tema**: Esquema de colores cyberpunk
- **Fuentes**: Hack Nerd Font
- **Integración**: Con el sistema de temas

### Rofi Launcher

- **Tema**: Diseño cyberpunk personalizado
- **Modos**: Drun, run, window
- **Integración**: Con el tema general

---

## ⌨️ Atajos de Teclado Principales

### Aplicaciones

- `Mod + Enter`: Terminal (Kitty)
- `Mod + S`: Launcher (Rofi)
- `Mod + B`: Navegador (Firefox)
- `Mod + O`: Notas (Obsidian)

### Gestión de Ventanas

- `Mod + Q`: Cerrar ventana
- `Mod + F`: Pantalla completa
- `Mod + T`: Modo flotante
- `Mod + Shift + Flechas`: Mover ventana
- `Mod + Ctrl + Flechas`: Redimensionar

### Sistema

- `Mod + Ctrl + R`: Reiniciar Qtile
- `Mod + L`: Bloquear PC / Apagar PC / Reboot PC / Suspend PC
- `Print`: Captura de pantalla

---


## 🎯 Características Especiales

### 1. **Integración BlackArch**

- Configuración para herramientas de pentesting
- Repositorios especializados

### 2. **Modularidad**

- Qtile configurado en módulos Python
- Cada componente independiente
- Fácil personalización

### 3. **Estética Unificada**

- Todos los componentes con mismo tema
- Coherencia visual completa
- Diseño cyberpunk consistente

### 4. **Optimización para Teclado**

- Todo accesible mediante atajos
- Flujo de trabajo eficiente
- Mínimo uso de mouse

---

## 🔄 Gestión de Configuración

### Enlaces Simbólicos

La configuración se basa en enlaces simbólicos desde el repositorio:

```
# Estructura de enlaces
ln -sf ~/dotfiles/qtile ~/.config/qtile
ln -sf ~/dotfiles/polybar ~/.config/polybar
ln -sf ~/dotfiles/picom ~/.config/picom
ln -sf ~/dotfiles/rofi ~/.config/rofi
ln -sf ~/dotfiles/kitty ~/.config/kitty
ln -sf ~/dotfiles/zshrc ~/.zshrc
```

### Sincronización

- Cambios en el repo se reflejan automáticamente
- Fácil mantenimiento y actualización
- Versionado de configuración

---

## 🎯 Propósito y Uso

Este conjunto de dotfiles está diseñado para:

1. **Pentesters**: Integración con herramientas de seguridad
2. **Desarrolladores**: Entorno eficiente y personalizable
3. **Minimalistas**: Sistema limpio y controlado por teclado
4. **Estetas**: Interfaz visualmente atractiva y coherente

---

## 📦 Dependencias Principales

### Para Arch Linux

```
# Window Manager y componentes
sudo pacman -S qtile polybar picom rofi kitty nitrogen

# Herramientas del sistema
sudo pacman -S brightnessctl pavucontrol zsh curl wget git

# Aplicaciones
sudo pacman -S flameshot thunar thunderbird obsidian

# Fuentes
sudo pacman -S ttf-hack-nerd-font
```

### Configuración Adicional

- **powerlevel10k:** Embellezedor para ZSH
- **Plugins**: Syntax highlighting, autosuggestions
- **Temas**: Coherentes con el diseño general

---

## 🔍 Personalización

### Qtile

- Layouts personalizables
- Widgets configurables
- Atajos modificables

### Polybar

- Módulos personalizables
- Temas editables
- Integración flexible

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