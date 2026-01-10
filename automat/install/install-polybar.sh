#!/bin/bash

# Script de instalación para Polybar

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

# Instalar polybar y dependencias
install_packages() {
    log "Instalando polybar..."
    
    if pacman -Q polybar >/dev/null 2>&1; then
        log "✓ polybar ya está instalado"
    else
        sudo pacman -S --noconfirm polybar
        log "✓ polybar instalado"
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
    
    # Crear symlink para polybar
    if [ -d "polybar" ]; then
        stow -t ~/.config polybar
        log "✓ Symlinks de polybar creados"
    else
        warn "Directorio polybar no encontrado en dotfiles"
    fi
}

# Dar permisos al launch script
fix_permissions() {
    if [ -f ~/.config/polybar/launch.sh ]; then
        chmod +x ~/.config/polybar/launch.sh
        log "✓ Permisos de launch.sh corregidos"
    fi
}

# Verificar instalación
verify_installation() {
    log "Verificando instalación..."
    
    if command -v polybar >/dev/null 2>&1; then
        log "✓ polybar disponible: $(which polybar)"
    fi
    
    if [ -L ~/.config/polybar ]; then
        log "✓ Symlink de polybar creado correctamente"
    fi
    
    if [ -f ~/.config/polybar/launch.sh ]; then
        log "✓ launch.sh disponible y ejecutable"
    fi
}

# Función principal
main() {
    echo -e "${BLUE}========================================${NC}"
    echo -e "${BLUE}  INSTALADOR DE POLYBAR${NC}"
    echo -e "${BLUE}========================================${NC}"
    
    check_arch
    install_packages
    create_symlinks
    fix_permissions
    verify_installation
    
    echo -e "${GREEN}✅ Polybar instalado y configurado${NC}"
}

main "$@"