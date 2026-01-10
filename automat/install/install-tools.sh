#!/bin/bash

# Script de instalación para herramientas de productividad

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

# Instalar herramientas desde repos oficiales
install_official_tools() {
    log "Instalando herramientas desde repos oficiales..."
    
    local tools=(
        "obsidian"           # Notas y documentación
        "flameshot"          # Capturas de pantalla
        "firefox"            # Navegador web
        "copyq"              # Portapapeles avanzado
        "discord"            # Comunicación
        "spotify"            # Música
        "btop"               # Monitor de sistema
    )
    
    for tool in "${tools[@]}"; do
        if pacman -Q "$tool" >/dev/null 2>&1; then
            log "✓ $tool ya está instalado"
        else
            log "Instalando $tool..."
            sudo pacman -S --noconfirm "$tool"
            log "✓ $tool instalado"
        fi
    done
}

# Instalar herramientas desde AUR
install_aur_tools() {
    if command -v yay >/dev/null 2>&1; then
        log "Instalando herramientas desde AUR..."
        
        local aur_tools=(
            "sigma-file-manager-bin"  # Gestor de archivos alternativo
            "bitwarden"              # Gestor de contraseñas
            "onedriver"               # Cliente de OneDrive
        )
        
        for tool in "${aur_tools[@]}"; do
            if yay -Q "$tool" >/dev/null 2>&1; then
                log "✓ $tool ya está instalado"
            else
                log "Instalando $tool desde AUR..."
                yay -S --noconfirm "$tool"
                log "✓ $tool instalado"
            fi
        done
    else
        warn "yay no disponible, instala manualmente:"
        echo "  - sigma-file-manager-bin"
        echo "  - bitwarden"
    fi
}

# Configurar herramientas básicas
configure_tools() {
    log "Configurando herramientas..."
    
    # Crear directorios útiles
    mkdir -p ~/Pictures/Screenshots
    mkdir -p ~/Downloads/TEMP
    mkdir -p ~/Documents/Projects
    log "✓ Directorios de trabajo creados"
}

# Verificar instalación
verify_installation() {
    log "Verificando instalación..."
    
    local key_tools=(
        "obsidian:notes"
        "flameshot:screenshot"
        "firefox:browser"
        "discord:chat"
        "spotify:music"
        "btop:monitor"
    )
    
    for tool_info in "${key_tools[@]}"; do
        local tool=$(echo "$tool_info" | cut -d: -f1)
        local desc=$(echo "$tool_info" | cut -d: -f2)
        
        if command -v "$tool" >/dev/null 2>&1; then
            log "✓ $tool ($desc) disponible"
        else
            warn "✗ $tool ($desc) no encontrado"
        fi
    done
    
    # Verificar herramientas AUR
    if command -v yay >/dev/null 2>&1; then
        if yay -Q sigma-file-manager-bin >/dev/null 2>&1; then
            log "✓ sigma-file-manager disponible"
        fi
        
        if yay -Q bitwarden >/dev/null 2>&1; then
            log "✓ bitwarden disponible"
        fi
        
        if yay -Q onedriver >/dev/null 2>&1; then
            log "✓ onedriver disponible"
        fi
    fi
}

# Mostrar información post-instalación
show_post_install_info() {
    echo -e "${BLUE}========================================${NC}"
    echo -e "${BLUE}  HERRAMIENTAS INSTALADAS${NC}"
    echo -e "${BLUE}========================================${NC}"
    echo -e "${GREEN}Productividad:${NC}"
    echo "  obsidian           - Notas y documentación"
    echo "  firefox            - Navegador web"
    echo "  sigma-file-manager - Gestor de archivos"
    echo "  copyq              - Portapapeles avanzado"
    echo ""
    echo -e "${GREEN}Multimedia:${NC}"
    echo "  spotify            - Música streaming"
    echo "  flameshot          - Capturas de pantalla"
    echo ""
    echo -e "${GREEN}Comunicación:${NC}"
    echo "  discord            - Chat y voz"
    echo "  bitwarden          - Gestor de contraseñas"
    echo ""
    echo -e "${GREEN}Almacenamiento:${NC}"
    echo "  onedriver          - Cliente de OneDrive"
    echo ""
    echo -e "${GREEN}Sistema:${NC}"
    echo "  btop               - Monitor de sistema"
    echo ""
    echo -e "${GREEN}Atajos útiles:${NC}"
    echo "  flameshot gui      - Abrir herramienta de captura"
    echo "  copyq              - Abrir gestor de portapapeles"
    echo "  btop               - Monitor de sistema"
    echo ""
    echo -e "${YELLOW}Nota: Algunas aplicaciones pueden requerir reinicio para aparecer en menús.${NC}"
}

# Función principal
main() {
    echo -e "${BLUE}========================================${NC}"
    echo -e "${BLUE}  INSTALADOR DE HERRAMIENTAS${NC}"
    echo -e "${BLUE}========================================${NC}"
    
    check_arch
    install_official_tools
    install_aur_tools
    configure_tools
    verify_installation
    show_post_install_info
    
    echo -e "${GREEN}========================================${NC}"
    echo -e "${GREEN}  INSTALACIÓN DE HERRAMIENTAS COMPLETADA${NC}"
    echo -e "${GREEN}========================================${NC}"
}

main "$@"