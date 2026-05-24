#!/bin/bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/lib/common.sh"

main() {
    check_arch
    header "YAY (AUR HELPER)"
    if command -v yay &>/dev/null; then
        log "yay ya instalado: $(yay --version | head -1)"
        return 0
    fi
    info "Instalando yay..."
    local tmpdir
    tmpdir=$(mktemp -d)
    sudo pacman -S --noconfirm --needed git base-devel
    git clone https://aur.archlinux.org/yay.git "$tmpdir/yay"
    cd "$tmpdir/yay"
    makepkg -si --noconfirm
    cd "$HOME"
    rm -rf "$tmpdir"
    command -v yay &>/dev/null && log "yay instalado" || error "Fallo instalacion de yay"
}
main "$@"
