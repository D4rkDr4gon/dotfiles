#!/bin/bash

# Script de instalación para Hack Nerd Fonts

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

# Instalar fuentes desde repos oficiales
install_packages() {
    log "Instalando fuentes Hack Nerd Fonts..."
    
    local fonts=(
        "ttf-hack-nerd"          # Hack Nerd Font
        "ttf-jetbrains-mono-nerd" # JetBrains Mono Nerd Font (opcional)
        "ttf-font-awesome"        # Iconos adicionales
        "noto-fonts"              # Fuentes base del sistema
        "noto-fonts-emoji"        # Emojis
    )
    
    for font in "${fonts[@]}"; do
        if pacman -Q "$font" >/dev/null 2>&1; then
            log "✓ $font ya está instalado"
        else
            log "Instalando $font..."
            sudo pacman -S --noconfirm "$font"
        fi
    done
}

# Actualizar caché de fuentes
update_font_cache() {
    log "Actualizando caché de fuentes..."
    
    # Actualizar caché de fuentes del sistema
    fc-cache -fv
    
    # Verificar si las fuentes están disponibles
    if fc-list | grep -q "Hack.*Nerd Font"; then
        log "✓ Hack Nerd Font disponible en el sistema"
    else
        warn "Hack Nerd Font no se encuentra en la lista de fuentes"
    fi
    
    # Mostrar algunas fuentes instaladas
    log "Fuentes Nerd disponibles:"
    fc-list | grep "Nerd Font" | head -5
}

# Verificar instalación
verify_installation() {
    log "Verificando instalación..."
    
    # Verificar paquetes instalados
    local key_fonts=("ttf-hack-nerd" "ttf-font-awesome" "noto-fonts")
    
    for font in "${key_fonts[@]}"; do
        if pacman -Q "$font" >/dev/null 2>&1; then
            log "✓ $font instalado"
        else
            warn "$font no instalado"
        fi
    done
    
    # Verificar disponibilidad de Hack Nerd Font
    if fc-list | grep -q "Hack.*Nerd Font"; then
        log "✓ Hack Nerd Font funcionando correctamente"
    fi
}

# Mostrar información post-instalación
show_post_install_info() {
    echo -e "${BLUE}========================================${NC}"
    echo -e "${BLUE}  FUENTES INSTALADAS${NC}"
    echo -e "${BLUE}========================================${NC}"
    echo -e "${GREEN}Fuentes principales instaladas:${NC}"
    echo "  Hack Nerd Font"
    echo "  JetBrains Mono Nerd Font"
    echo "  Font Awesome Icons"
    echo "  Noto Fonts"
    echo "  Noto Emoji"
    echo ""
    echo -e "${GREEN}Las fuentes se aplicarán automáticamente en:${NC}"
    echo "  Terminal (kitty)"
    echo "  Qtile"
    echo "  Polybar"
    echo "  Rofi"
    echo "  Neovim"
    echo ""
    echo -e "${GREEN}Para verificar fuentes disponibles:${NC}"
    echo "  fc-list | grep -i hack"
    echo "  fc-list | grep -i nerd"
    echo ""
    echo -e "${GREEN}Para probar fuentes:${NC}"
    echo "  kitty --config-dir ~/.config/kitty"
    echo "  # En kitty.conf ya debería estar configurado font_family Hack Nerd Font"
}

# Función principal
main() {
    echo -e "${BLUE}========================================${NC}"
    echo -e "${BLUE}  INSTALADOR DE FUENTES HACK NERD${NC}"
    echo -e "${BLUE}========================================${NC}"
    
    check_arch
    install_packages
    update_font_cache
    verify_installation
    show_post_install_info
    
    echo -e "${GREEN}✅ Fuentes Hack Nerd Fonts instaladas${NC}"
}

main "$@"