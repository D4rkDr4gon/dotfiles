#!/bin/bash

# Script de instalación para Neovim + LazyVim

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

# Instalar neovim desde repos oficiales
install_packages() {
    log "Instalando neovim..."
    
    if pacman -Q neovim >/dev/null 2>&1; then
        log "✓ neovim ya está instalado"
    else
        sudo pacman -S --noconfirm neovim
        log "✓ neovim instalado"
    fi
}

# Instalar dependencias adicionales para LazyVim
install_dependencies() {
    log "Instalando dependencias para LazyVim..."
    
    local deps=(
        "git"                # Para clonar repositorios
        "ripgrep"            # Para búsqueda de archivos
        "fd"                 # Para encontrar archivos
        "wl-clipboard"       # Para clipboard en Wayland
        "xsel"               # Para clipboard en X11
        "nodejs"             # Para LSPs y plugins
        "npm"                # Para paquetes npm
        "python"             # Para LSPs de Python
        "python-pip"         # Para paquetes Python
        "lua"                # Para configuración Lua
        "luarocks"           # Para paquetes Lua
    )
    
    for dep in "${deps[@]}"; do
        if pacman -Q "$dep" >/dev/null 2>&1; then
            log "✓ $dep ya está instalado"
        else
            log "Instalando $dep..."
            sudo pacman -S --noconfirm "$dep"
        fi
    done
}

# Backup de configuración existente
backup_existing_config() {
    local nvim_dir="$HOME/.config/nvim"
    local nvim_data="$HOME/.local/share/nvim"
    
    if [ -d "$nvim_dir" ] && [ ! -L "$nvim_dir" ]; then
        log "Haciendo backup de configuración existente..."
        mv "$nvim_dir" "$nvim_dir.backup.$(date +%Y%m%d_%H%M%S)"
        log "✓ Backup creado: $nvim_dir.backup.*"
    fi
    
    if [ -d "$nvim_data" ]; then
        log "Limpiando datos existentes..."
        rm -rf "$nvim_data"
        log "✓ Datos de nvim limpiados"
    fi
}

# Instalar LazyVim (config oficial)
install_lazyvim() {
    log "Instalando LazyVim..."
    
    # Clonar LazyVim starter
    if [ ! -d "$HOME/.config/nvim" ]; then
        git clone https://github.com/LazyVim/starter ~/.config/nvim
        cd ~/.config/nvim
        rm -rf .git  # Remover el control de versiones
        log "✓ LazyVim starter clonado"
    else
        log "✓ Directorio nvim ya existe"
    fi
}

# Crear symlinks con stow para configs adicionales
create_symlinks() {
    log "Creando symlinks con stow..."
    
    # Verificar si stow está instalado
    if ! command -v stow >/dev/null 2>&1; then
        log "Instalando stow..."
        sudo pacman -S --noconfirm stow
    fi
    
    # Ir al directorio de dotfiles
    cd /home/lcampassi/dotfiles
    
    # Crear symlink para lazy-nvim si existe
    if [ -d "lazy-nvim" ]; then
        # Primamos la configuración del repo sobre la de LazyVim starter
        rm -rf ~/.config/nvim
        stow -t ~/.config lazy-nvim
        log "✓ Symlinks de lazy-nvim creados (priorizando tu config)"
    else
        log "Directorio lazy-nvim no encontrado, usando LazyVim starter oficial"
    fi
}

# Instalar algunas herramientas útiles adicionales
install_additional_tools() {
    log "Instalando herramientas adicionales..."
    
    # Instalar Treesitter parsers desde npm
    if command -v npm >/dev/null 2>&1; then
        npm install -g tree-sitter-cli || warn "No se pudo instalar tree-sitter-cli"
    fi
    
    # Instalar Python LSPs
    if command -v pip3 >/dev/null 2>&1; then
        pip3 install --user pynvim || warn "No se pudo instalar pynvim"
    fi
}

# Verificar instalación
verify_installation() {
    log "Verificando instalación..."
    
    if command -v nvim >/dev/null 2>&1; then
        log "✓ neovim disponible: $(which nvim)"
        nvim --version | head -1
    fi
    
    if [ -d "$HOME/.config/nvim" ]; then
        log "✓ Configuración de nvim disponible"
    fi
    
    # Verificar LazyVim
    if [ -f "$HOME/.config/nvim/init.lua" ]; then
        log "✓ LazyVim configurado"
    fi
    
    # Verificar dependencias clave
    for cmd in ripgrep fd git nodejs npm python3; do
        if command -v "$cmd" >/dev/null 2>&1; then
            log "✓ $cmd disponible"
        else
            warn "$cmd no disponible"
        fi
    done
}

# Mostrar información post-instalación
show_post_install_info() {
    echo -e "${BLUE}========================================${NC}"
    echo -e "${BLUE}  LAZYVIM - PRIMEROS PASOS${NC}"
    echo -e "${BLUE}========================================${NC}"
    echo -e "${GREEN}Para iniciar LazyVim:${NC}"
    echo "  nvim"
    echo ""
    echo -e "${GREEN}LazyVim instalará automáticamente los plugins al primer inicio.${NC}"
    echo "  Esto puede tardar unos minutos."
    echo ""
    echo -e "${GREEN}Comandos útiles:${NC}"
    echo "  :Lazy              - Gestor de plugins"
    echo "  :Mason             - Gestor de LSPs"
    echo "  :Telescope         - Fuzzy finder"
    echo "  :lua vim.keymap.set('n', '<leader>l', vim.lsp.buf.hover)"
    echo ""
    echo -e "${GREEN}Para añadir configuraciones personalizadas:${NC}"
    echo "  ~/.config/nvim/lua/config/"
    echo "  ~/.config/nvim/lua/plugins/"
    echo ""
    echo -e "${GREEN}Documentación:${NC}"
    echo "  https://www.lazyvim.org/"
}

# Función principal
main() {
    echo -e "${BLUE}========================================${NC}"
    echo -e "${BLUE}  INSTALADOR DE NEVIM + LAZYVIM${NC}"
    echo -e "${BLUE}========================================${NC}"
    
    check_arch
    install_packages
    install_dependencies
    backup_existing_config
    install_lazyvim
    create_symlinks
    install_additional_tools
    verify_installation
    show_post_install_info
    
    echo -e "${GREEN}✅ Neovim + LazyVim instalado y configurado${NC}"
}

main "$@"