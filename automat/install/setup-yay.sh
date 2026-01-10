#!/bin/bash

# Script para configurar yay en Arch Linux
# Solo configura, no instala automáticamente

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

# Verificar si yay ya está instalado
check_yay_installed() {
    if command -v yay >/dev/null 2>&1; then
        log "✓ yay ya está instalado en: $(which yay)"
        yay --version
        return 0
    else
        warn "✗ yay no está instalado"
        return 1
    fi
}

# Instalar dependencias necesarias
install_dependencies() {
    log "Verificando dependencias necesarias..."
    
    local deps=("git" "base-devel")
    
    for dep in "${deps[@]}"; do
        if ! pacman -Q "$dep" >/dev/null 2>&1; then
            warn "Dependencia faltante: $dep"
            echo "Para instalar yay manualmente, ejecuta:"
            echo "sudo pacman -S $dep"
            return 1
        else
            log "✓ $dep está instalado"
        fi
    done
}

# Descargar código fuente de yay
download_yay() {
    log "Descargando código fuente de yay..."
    
    local temp_dir="/tmp/yay-build"
    
    # Limpiar directorio temporal si existe
    if [ -d "$temp_dir" ]; then
        rm -rf "$temp_dir"
    fi
    
    mkdir -p "$temp_dir"
    cd "$temp_dir"
    
    # Clonar repositorio
    git clone https://aur.archlinux.org/yay.git
    cd yay
    
    log "✓ Código fuente descargado en: $temp_dir/yay"
    echo "Para compilar yay manualmente:"
    echo "cd $temp_dir/yay"
    echo "makepkg -si"
}

# Configuración de yay
configure_yay() {
    log "Configurando yay para uso optimizado..."
    
    local yay_config="$HOME/.config/yay/config.json"
    local config_dir=$(dirname "$yay_config")
    
    # Crear directorio de configuración
    mkdir -p "$config_dir"
    
    # Crear archivo de configuración optimizado
    cat > "$yay_config" << 'EOF'
{
    "aururl": "https://aur.archlinux.org",
    "buildDir": "/tmp/yay-build",
    "editor": "",
    "editorflags": "",
    "makepkgbin": "/usr/bin/makepkg",
    "pacmanbin": "/usr/bin/pacman",
    "pacmanconf": "/etc/pacman.conf",
    "tarbin": "/usr/bin/bsdtar",
    "redownload": "no",
    "rebuild": "no",
    "answerdiff": "None",
    "answeredit": "None",
    "answerupgrade": "None",
    "gitbin": "/usr/bin/git",
    "gpgbin": "/usr/bin/gpg",
    "gpgflags": "",
    "mflags": "",
    "sortby": "votes",
    "searchby": "name",
    "git": "false",
    "timeupdate": "false",
    "topdown": "true",
    "cleanAfter": "true",
    "devel": "false",
    "provides": "true",
    "pgpfetch": "true",
    "upgrademenu": "true",
    "cleanmenu": "true",
    "diffmenu": "true",
    "editmenu": "false",
    "combinedupgrade": "false",
    "useask": "false",
    "batchinstall": "true",
    "sudoloop": "true",
    "requestsplitn": "150",
    "sortmode": "0",
    "completionrefreshtime": "1",
    "maxconcurrentdownloads": "1",
    "separatesources": "true",
    "debug": "false"
}
EOF
    
    log "✓ Configuración de yay guardada en: $yay_config"
}

# Nota: Los aliases se configuran en el zshrc del repo y se gestionan con stow

# Mostrar ayuda
show_help() {
    echo -e "${BLUE}Configuración de yay completada${NC}"
    echo -e "${GREEN}Comandos útiles:${NC}"
    echo "  yay -Ss <paquete>    - Buscar paquete"
    echo "  yay -S <paquete>     - Instalar paquete"
    echo "  yay -Syu             - Actualizar sistema"
    echo "  yay -R <paquete>     - Remover paquete"
    echo "  yay -Sc              - Limpiar caché"
    echo "  yay -Si <paquete>    - Información del paquete"
}

# Función principal
main() {
    echo -e "${BLUE}========================================${NC}"
    echo -e "${BLUE}  CONFIGURADOR DE YAY${NC}"
    echo -e "${BLUE}========================================${NC}"
    
    # Verificar si estamos en Arch
    if [ ! -f /etc/arch-release ]; then
        error "Este script es solo para Arch Linux"
    fi
    
    if check_yay_installed; then
        log "Configurando yay existente..."
        configure_yay
        show_help
        exit 0
    fi
    
    warn "yay no está instalado. Preparando configuración..."
    
    if ! install_dependencies; then
        error "Instala las dependencias faltantes primero"
    fi
    
    download_yay
    configure_yay
    
    echo -e "${YELLOW}========================================${NC}"
    echo -e "${YELLOW}  CONFIGURACIÓN PREPARADA${NC}"
    echo -e "${YELLOW}========================================${NC}"
    echo -e "${GREEN}Para completar la instalación, ejecuta:${NC}"
    echo -e "${BLUE}cd /tmp/yay-build/yay${NC}"
    echo -e "${BLUE}makepkg -si${NC}"
    echo ""
    echo -e "${GREEN}O ejecuta el script install-yay.sh si lo tienes${NC}"
}

main "$@"