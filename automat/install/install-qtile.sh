#!/bin/bash

# Script de instalación para Qtile y componentes

set -euo pipefail

# Colores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1"
    exit 1
}

# Verificar si estamos en Arch
check_arch() {
    if [ ! -f /etc/arch-release ]; then
        error "Este script es solo para Arch Linux"
    fi
}

# Instalar dependencias de Qtile
install_qtile_deps() {
    log "Instalando dependencias de Qtile..."
    
    local qtile_deps=(
        "python"
        "python-pip"
        "python-setuptools"
        "python-wheel"
        "python-cffi"
        "python-xcffib"
        "python-cairocffi"
        "python-dbus-next"
        "python-pywl"
        "python-psutil"
        "python-iwlib"
        "python-keybinder2"
        "python-pyqt6-sip"
        "python-dateutil"
        "python-mpd2"
    )
    
    for dep in "${qtile_deps[@]}"; do
        if pacman -Q "$dep" >/dev/null 2>&1; then
            log "✓ $dep ya está instalado"
        else
            log "Instalando $dep..."
            sudo pacman -S --noconfirm "$dep"
        fi
    done
}

# Instalar Qtile
install_qtile() {
    log "Instalando Qtile..."
    
    if pacman -Q qtile >/dev/null 2>&1; then
        log "✓ Qtile ya está instalado"
    else
        sudo pacman -S --noconfirm qtile
        log "✓ Qtile instalado"
    fi
}

# Instalar dependencias opcionales para widgets
install_optional_deps() {
    log "Instalando dependencias opcionales para widgets..."
    
    local optional_deps=(
        "pulseaudio"           # Para control de volumen
        "brightnessctl"         # Para control de brillo
        "networkmanager"        # Para widgets de red
        "bluez"                 # Para widgets Bluetooth
        "bluez-utils"          # Para widgets Bluetooth
        "alsa-utils"           # Para widgets de audio
        "lm_sensors"            # Para monitoreo de temperatura
        "acpid"                 # Para eventos ACPI
    )
    
    for dep in "${optional_deps[@]}"; do
        if pacman -Q "$dep" >/dev/null 2>&1; then
            log "✓ $dep ya está instalado"
        else
            log "Instalando $dep..."
            sudo pacman -S --noconfirm "$dep"
        fi
    done
}

# Instalar herramientas de desarrollo para Qtile
install_dev_tools() {
    log "Instalando herramientas de desarrollo para Qtile..."
    
    local dev_tools=(
        "python-black"
        "python-flake8"
        "python-mypy"
        "python-pylint"
        "python-autopep8"
        "python-isort"
    )
    
    for tool in "${dev_tools[@]}"; do
        if pacman -Q "$tool" >/dev/null 2>&1; then
            log "✓ $tool ya está instalado"
        else
            log "Instalando $tool..."
            sudo pacman -S --noconfirm "$tool"
        fi
    done
}

# Instalar dependencias para Python específicas de Qtile
install_python_deps() {
    log "Instalando dependencias Python específicas..."
    
    local python_deps=(
        "qtile-extras"
        "python-psutil"
        "python-iwlib"
        "python-netaddr"
        "python-requests"
        "python-beautifulsoup4"
        "python-lxml"
        "python-yaml"
        "python-toml"
        "python-click"
    )
    
    for dep in "${python_deps[@]}"; do
        if pacman -Q "$dep" >/dev/null 2>&1; then
            log "✓ $dep ya está instalado"
        else
            log "Instalando $dep..."
            sudo pacman -S --noconfirm "$dep"
        fi
    done
}

# Instalar desde AUR si está disponible
install_aur_packages() {
    if command -v yay >/dev/null 2>&1; then
        log "Instalando paquetes AUR para Qtile..."
        
        local aur_packages=(
            "python-qtile-git"       # Versión git de Qtile
            "python-qtile-extras-git" # Extras de Qtile
        )
        
        for package in "${aur_packages[@]}"; do
            log "Verificando $package desde AUR..."
            if yay -Q "$package" >/dev/null 2>&1; then
                log "✓ $package ya está instalado"
            else
                log "Instalando $package desde AUR..."
                yay -S --noconfirm "$package" || warn "No se pudo instalar $package desde AUR"
            fi
        done
    else
        warn "yay no disponible, omitiendo paquetes AUR"
    fi
}

# Crear script de prueba para Qtile
create_test_script() {
    log "Creando script de prueba para Qtile..."
    
    local test_script="$HOME/.config/qtile/test-config.py"
    local config_dir=$(dirname "$test_script")
    
    mkdir -p "$config_dir"
    
    cat > "$test_script" << 'EOF'
#!/usr/bin/env python3
"""
Script de prueba para verificar configuración de Qtile
"""

from libqtile import bar, layout, widget
from libqtile.config import Click, Drag, Group, Key, Match, Screen
from libqtile.lazy import lazy

# Configuración básica de prueba
mod = "mod4"
terminal = "kitty"

keys = [
    Key([mod], "Return", lazy.spawn(terminal)),
    Key([mod, "shift"], "q", lazy.window.kill()),
    Key([mod, "control"], "r", lazy.reload_config()),
]

groups = [Group(i) for i in "123456789"]

layouts = [
    layout.Max(),
    layout.Stack(stacks=2),
    layout.Bsp(),
    layout.Columns(),
]

widget_defaults = dict(
    font="sans",
    fontsize=12,
    padding=3,
)

screens = [
    Screen(
        top=bar.Bar(
            [
                widget.CurrentLayout(),
                widget.GroupBox(),
                widget.Prompt(),
                widget.WindowName(),
                widget.Clock(format="%Y-%m-%d %a %I:%M %p"),
            ],
            24,
        ),
    ),
]

# Fin del archivo de configuración
EOF
    
    log "✓ Script de prueba creado en: $test_script"
    log "Para probar la configuración: qtile -c $test_script check"
}

# Verificar instalación
verify_installation() {
    log "Verificando instalación de Qtile..."
    
    if command -v qtile >/dev/null 2>&1; then
        log "✓ qtile instalado: $(qtile --version)"
    else
        error "qtile no se encuentra en PATH"
    fi
    
    # Verificar módulos Python
    python3 -c "import libqtile" 2>/dev/null && log "✓ libqtile importable"
    
    # Verificar configuración si existe
    if [ -f "$HOME/.config/qtile/config.py" ]; then
        if qtile check >/dev/null 2>&1; then
            log "✓ Configuración de Qtile válida"
        else
            warn "Configuración de Qtile tiene errores"
        fi
    fi
}

# Configurar gestor de sesiones
configure_sessions() {
    log "Configurando Qtile en gestor de sesiones..."
    
    local session_dir="/usr/share/xsessions"
    local desktop_file="$session_dir/qtile.desktop"
    
    if [ -f "$desktop_file" ]; then
        log "✓ Qtile ya está configurado en el gestor de sesiones"
        return 0
    fi
    
    if [ -w "$session_dir" ]; then
        sudo tee "$desktop_file" << 'EOF'
[Desktop Entry]
Name=Qtile
Comment=Qtile Session
Exec=/usr/bin/qtile start
Type=Application
Keywords=wm;tiling
EOF
        log "✓ Qtile configurado en el gestor de sesiones"
    else
        warn "No se puede escribir en $session_dir. Configuración manual requerida."
    fi
}

# Función principal
main() {
    echo -e "${BLUE}========================================${NC}"
    echo -e "${BLUE}  INSTALADOR DE QTILE${NC}"
    echo -e "${BLUE}========================================${NC}"
    
    check_arch
    
    install_qtile_deps
    install_qtile
    install_optional_deps
    install_dev_tools
    install_python_deps
    install_aur_packages
    create_test_script
    configure_sessions
    verify_installation
    
    echo -e "${GREEN}========================================${NC}"
    echo -e "${GREEN}  INSTALACIÓN DE QTILE COMPLETADA${NC}"
    echo -e "${GREEN}========================================${NC}"
    echo -e "${YELLOW}Para usar Qtile:${NC}"
    echo "1. Cierra sesión actual"
    echo "2. Selecciona Qtile en el gestor de sesiones"
    echo "3. O ejecuta: startx /usr/bin/qtile start"
    echo ""
    echo -e "${GREEN}Para recargar configuración: Mod + Ctrl + R${NC}"
    echo -e "${GREEN}Para verificar configuración: qtile check${NC}"
}

main "$@"