#!/bin/bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/lib/common.sh"

main() {
    check_arch
    header "BLACKARCH REPOS"
    if pacman -Q blackarch-keyring &>/dev/null; then
        log "BlackArch ya configurado"
        return 0
    fi
    warn "Esto agregara repositorios de pentesting a tu sistema"
    echo -n "   Continuar? [s/N]: "; read -r resp
    case "$resp" in s|S|y|Y) ;; *) log "Cancelado"; return 0 ;; esac

    local strap="$HOME/Downloads/strap.sh"
    mkdir -p "$HOME/Downloads"
    info "Descargando strap.sh..."
    curl -s "https://blackarch.org/strap.sh" -o "$strap"
    chmod +x "$strap"
    sudo "$strap"
    sudo pacman -Syy
    log "BlackArch configurado. Categorias: pacman -Sg blackarch"
}
main "$@"
