#!/bin/bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/lib/common.sh"

PACKAGES=(
    ttf-hack-nerd ttf-jetbrains-mono-nerd
    ttf-font-awesome noto-fonts noto-fonts-emoji
)

main() {
    check_arch
    header "FUENTES NERD FONTS"
    for pkg in "${PACKAGES[@]}"; do install_pacman_pkg "$pkg"; done
    info "Actualizando cache de fuentes..."
    fc-cache -fv &>/dev/null
    if fc-list | grep -q "Hack.*Nerd"; then
        log "Hack Nerd Font disponible"
    fi
    log "Fuentes instaladas"
}
main "$@"
