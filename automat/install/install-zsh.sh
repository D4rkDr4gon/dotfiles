#!/bin/bash

# Script de instalación para Zsh + Powerlevel10k

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

# Instalar zsh desde repos oficiales
install_packages() {
    log "Instalando zsh..."
    
    if pacman -Q zsh >/dev/null 2>&1; then
        log "✓ zsh ya está instalado"
    else
        sudo pacman -S --noconfirm zsh
        log "✓ zsh instalado"
    fi
}

# Instalar powerlevel10k desde git
install_powerlevel10k() {
    log "Instalando powerlevel10k..."
    
    local zsh_custom="$HOME/.local/share/zsh"
    local p10k_dir="$zsh_custom/powerlevel10k"
    
    # Crear directorio si no existe
    mkdir -p "$zsh_custom"
    
    # Clonar o actualizar powerlevel10k
    if [ -d "$p10k_dir" ]; then
        cd "$p10k_dir"
        git pull origin master
        log "✓ powerlevel10k actualizado"
    else
        git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$p10k_dir"
        log "✓ powerlevel10k instalado"
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
    
    # Crear symlink para zshrc
    if [ -f "zshrc" ]; then
        stow -t "$HOME" zshrc
        log "✓ Symlink de .zshrc creado"
    else
        warn "Archivo zshrc no encontrado en dotfiles"
    fi
}

# Cambiar shell a zsh
change_shell() {
    log "Cambiando shell a zsh..."
    
    local current_shell=$(echo "$SHELL")
    
    if [ "$current_shell" = "/bin/zsh" ] || [ "$current_shell" = "/usr/bin/zsh" ]; then
        log "✓ Shell ya es zsh"
    else
        if chsh -s /bin/zsh; then
            log "✓ Shell cambiado a zsh"
        else
            warn "No se pudo cambiar el shell automáticamente. Ejecuta manualmente: chsh -s /bin/zsh"
        fi
    fi
}

# Verificar instalación
verify_installation() {
    log "Verificando instalación..."
    
    if command -v zsh >/dev/null 2>&1; then
        log "✓ zsh disponible: $(which zsh)"
        zsh --version | head -1
    fi
    
    if [ -d "$HOME/.local/share/zsh/powerlevel10k" ]; then
        log "✓ powerlevel10k disponible"
    fi
    
    if [ -L ~/.zshrc ]; then
        log "✓ Symlink de .zshrc creado correctamente"
    fi
    
    if [ "$SHELL" = "/bin/zsh" ] || [ "$SHELL" = "/usr/bin/zsh" ]; then
        log "✓ Shell activo es zsh"
    fi
}

# Mostrar información post-instalación
show_post_install_info() {
    echo -e "${BLUE}========================================${NC}"
    echo -e "${BLUE}  CONFIGURACIÓN DE ZSH${NC}"
    echo -e "${BLUE}========================================${NC}"
    echo -e "${GREEN}Para configurar powerlevel10k:${NC}"
    echo "  p10k configure"
    echo ""
    echo -e "${GREEN}Para probar configuración:${NC}"
    echo "  zsh"
    echo ""
    echo -e "${GREEN}Para recargar configuración:${NC}"
    echo "  source ~/.zshrc"
    echo ""
    echo -e "${GREEN}Reinicia sesión para cambios completos${NC}"
}

# Función principal
main() {
    echo -e "${BLUE}========================================${NC}"
    echo -e "${BLUE}  INSTALADOR DE ZSH + POWERLEVEL10K${NC}"
    echo -e "${BLUE}========================================${NC}"
    
    check_arch
    install_packages
    install_powerlevel10k
    create_symlinks
    change_shell
    verify_installation
    show_post_install_info
    
    echo -e "${GREEN}✅ Zsh + Powerlevel10k instalado y configurado${NC}"
}

main "$@"