#!/bin/bash

# Script de instalación para Rofi

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

# Instalar rofi y sigma-file-manager
install_packages() {
    log "Instalando paquetes..."
    
    # Instalar rofi desde repos oficiales
    if pacman -Q rofi >/dev/null 2>&1; then
        log "✓ rofi ya está instalado"
    else
        sudo pacman -S --noconfirm rofi
        log "✓ rofi instalado"
    fi
    
    # Instalar sigma-file-manager desde AUR
    if command -v yay >/dev/null 2>&1; then
        if yay -Q sigma-file-manager-bin >/dev/null 2>&1; then
            log "✓ sigma-file-manager ya está instalado"
        else
            log "Instalando sigma-file-manager desde AUR..."
            yay -S --noconfirm sigma-file-manager-bin
            log "✓ sigma-file-manager instalado"
        fi
    else
        warn "yay no disponible, instala sigma-file-manager manualmente"
    fi
}

# Crear symlinks con stow
create_symlinks() {
    log "Creando symlinks con stow..."
    
    # Verificar si stow está instalado
    if ! command -v stow >/dev/null 2>&1; then
        log "Instalando stow..."
        sudo pacman -S --noconfirm stow
    fi
    
    # Ir al directorio de dotfiles
    cd /home/lcampassi/dotfiles
    
    # Crear symlink para rofi
    if [ -d "rofi" ]; then
        stow -t ~/.config rofi
        log "✓ Symlinks de rofi creados"
    else
        warn "Directorio rofi no encontrado en dotfiles"
    fi
}

# Verificar instalación
verify_installation() {
    log "Verificando instalación..."
    
    if command -v rofi >/dev/null 2>&1; then
        log "✓ rofi disponible: $(which rofi)"
    fi
    
    if [ -L ~/.config/rofi ]; then
        log "✓ Symlink de rofi creado correctamente"
    fi
    
    if command -v sigma-file-manager >/dev/null 2>&1; then
        log "✓ sigma-file-manager disponible"
    fi
}

# Función principal
main() {
    echo -e "${BLUE}========================================${NC}"
    echo -e "${BLUE}  INSTALADOR DE ROFI${NC}"
    echo -e "${BLUE}========================================${NC}"
    
    check_arch
    install_packages
    create_symlinks
    verify_installation
    
    echo -e "${GREEN}✅ Rofi instalado y configurado${NC}"
}

main "$@"