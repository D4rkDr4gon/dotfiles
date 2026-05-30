#!/bin/bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/lib/common.sh"

main() {
    check_arch
    header "PICOM (X11 ONLY)"
    install_pacman_pkg "picom"
    stow_config "picom"
    log "Picom instalado (solo X11). En Wayland no necesita compositor externo (wlroots nativo)."
}
main "$@"
