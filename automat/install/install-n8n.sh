#!/bin/bash

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

# Instalar n8n desde repos oficiales
install_packages() {
    log "Instalando n8n..."
    
    if yay -Q n8n >/dev/null 2>&1; then
        log "✓ n8n ya está instalado"
    else
        yay -S --noconfirm n8n
        log "✓ n8n instalado"
    fi
}