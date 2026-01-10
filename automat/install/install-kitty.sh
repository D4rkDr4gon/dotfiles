#!/bin/bash

# Script de instalación para Kitty

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

# Instalar kitty desde repos oficiales
install_packages() {
    log "Instalando kitty..."
    
    if pacman -Q kitty >/dev/null 2>&1; then
        log "✓ kitty ya está instalado"
    else
        sudo pacman -S --noconfirm kitty
        log "✓ kitty instalado"
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
    
    # Crear symlink para kitty
    if [ -d "kitty" ]; then
        stow -t ~/.config kitty
        log "✓ Symlinks de kitty creados"
    else
        warn "Directorio kitty no encontrado en dotfiles"
    fi
}

# Verificar instalación
verify_installation() {
    log "Verificando instalación..."
    
    if command -v kitty >/dev/null 2>&1; then
        log "✓ kitty disponible: $(which kitty)"
    fi
    
    if [ -L ~/.config/kitty ]; then
        log "✓ Symlink de kitty creado correctamente"
    fi
    
    if [ -f ~/.config/kitty/kitty.conf ]; then
        log "✓ Configuración de kitty disponible"
    fi
}

# Función principal
main() {
    echo -e "${BLUE}========================================${NC}"
    echo -e "${BLUE}  INSTALADOR DE KITTY${NC}"
    echo -e "${BLUE}========================================${NC}"
    
    check_arch
    install_packages
    create_symlinks
    verify_installation
    
    echo -e "${GREEN}✅ Kitty instalado y configurado${NC}"
}

main "$@"