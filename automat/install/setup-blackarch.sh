#!/bin/bash

# Script para configurar repositorio BlackArch en Arch Linux
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

# Verificar si estamos en Arch
check_arch() {
    if [ ! -f /etc/arch-release ]; then
        error "Este script es solo para Arch Linux"
    fi
    log "✓ Arch Linux detectado"
}

# Verificar si BlackArch ya está configurado
check_blackarch() {
    if pacman -Q blackarch-keyring >/dev/null 2>&1; then
        log "✓ BlackArch ya está configurado"
        pacman -Sl blackarch | head -5
        return 0
    else
        warn "✗ BlackArch no está configurado"
        return 1
    fi
}

# Descargar script de configuración
download_strap() {
    log "Descargando script strap.sh de BlackArch..."
    
    local strap_url="https://blackarch.org/strap.sh"
    local strap_file="$HOME/Downloads/strap.sh"
    
    # Crear directorio si no existe
    mkdir -p "$(dirname "$strap_file")"
    
    # Descargar script
    if command -v curl >/dev/null 2>&1; then
        curl -s "$strap_url" -o "$strap_file"
    elif command -v wget >/dev/null 2>&1; then
        wget -q "$strap_url" -O "$strap_file"
    else
        error "Se requiere curl o wget para descargar el script"
    fi
    
    # Verificar descarga
    if [ ! -f "$strap_file" ]; then
        error "No se pudo descargar strap.sh"
    fi
    
    # Hacer ejecutable
    chmod +x "$strap_file"
    
    log "✓ Script descargado en: $strap_file"
    log "Para completar la instalación, ejecuta:"
    echo "sudo $strap_file"
}

# Verificar archivo strap.sh
verify_strap() {
    local strap_file="$HOME/Downloads/strap.sh"
    
    if [ -f "$strap_file" ]; then
        log "✓ Script strap.sh encontrado en: $strap_file"
        
        # Mostrar primeras líneas para verificación
        echo -e "${BLUE}Primeras líneas del script:${NC}"
        head -10 "$strap_file"
        
        return 0
    else
        warn "✗ Script strap.sh no encontrado"
        return 1
    fi
}

# Configurar pacman.conf para BlackArch
configure_pacman() {
    log "Configurando pacman.conf para BlackArch..."
    
    local pacman_conf="/etc/pacman.conf"
    local backup_conf="/etc/pacman.conf.bak"
    
    # Crear backup
    if [ ! -f "$backup_conf" ]; then
        sudo cp "$pacman_conf" "$backup_conf"
        log "✓ Backup creado: $backup_conf"
    fi
    
    # Verificar si BlackArch ya está en pacman.conf
    if grep -q "\[blackarch\]" "$pacman_conf"; then
        log "✓ BlackArch ya está configurado en pacman.conf"
        return 0
    fi
    
    # Agregar configuración de BlackArch
    log "Agregando configuración de BlackArch a pacman.conf..."
    
    sudo tee -a "$pacman_conf" << 'EOF'

[blackarch]
Server = https://mirrors.nix.org.tr/blackarch/$repo/os/$arch
Server = https://mirror.cyberbits.eu/blackarch/$repo/os/$arch
Server = https://mirror.freedif.org/BlackArch/$repo/os/$arch
Server = https://blackarch.org/blackarch/$repo/os/$arch
EOF
    
    log "✓ Configuración de BlackArch agregada a pacman.conf"
}

# Actualizar base de datos de paquetes
update_pacman_db() {
    log "Actualizando base de datos de paquetes..."
    
    echo -e "${YELLOW}Para actualizar la base de datos con BlackArch, ejecuta:${NC}"
    echo -e "${BLUE}sudo pacman -Syy${NC}"
    
    echo -e "${GREEN}Para verificar la configuración:${NC}"
    echo -e "${BLUE}pacman -Sl blackarch | head -10${NC}"
}

# Nota: Los aliases se configuran en el zshrc del repo y se gestionan con stow

# Mostrar categorías populares de BlackArch
show_categories() {
    log "Mostrando categorías populares de BlackArch..."
    
    echo -e "${BLUE}Categorías principales:${NC}"
    echo "  - blackarch-cracker        - Password cracking"
    echo "  - blackarch-recon          - Reconnaissance"
    echo "  - blackarch-exploitation   - Exploitation tools"
    echo "  - blackarch-forensic       - Forensic tools"
    echo "  - blackarch-malware        - Malware analysis"
    echo "  - blackarch-networking     - Network tools"
    echo "  - blackarch-web            - Web applications"
    echo "  - blackarch-wireless       - Wireless attacks"
    echo "  - blackarch-social         - Social engineering"
    echo "  - blackarch-crypto         - Cryptography"
    
    echo -e "${GREEN}Para explorar todas las categorías:${NC}"
    echo "pacman -Sg blackarch"
}

# Función principal
main() {
    echo -e "${BLUE}========================================${NC}"
    echo -e "${BLUE}  CONFIGURADOR DE BLACKARCH${NC}"
    echo -e "${BLUE}========================================${NC}"
    
    check_arch
    
    if check_blackarch; then
        log "BlackArch ya está configurado"
        show_categories
        exit 0
    fi
    
    download_strap
    verify_strap
    configure_pacman
    update_pacman_db
    show_categories
    
    echo -e "${YELLOW}========================================${NC}"
    echo -e "${YELLOW}  CONFIGURACIÓN PREPARADA${NC}"
    echo -e "${YELLOW}========================================${NC}"
    echo -e "${GREEN}Para completar la instalación, ejecuta:${NC}"
    echo -e "${BLUE}sudo ~/Downloads/strap.sh${NC}"
    echo ""
    echo -e "${GREEN}Luego actualiza la base de datos:${NC}"
    echo -e "${BLUE}sudo pacman -Syy${NC}"
}

main "$@"