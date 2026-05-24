#!/bin/bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/lib/common.sh"

main() {
    check_arch
    header "POLYBAR"
    install_pacman_pkg "polybar"
    stow_config "polybar"
    if [ -f "$HOME/.config/polybar/launch.sh" ]; then
        chmod +x "$HOME/.config/polybar/launch.sh"
    fi
    log "Polybar instalado"
}
main "$@"
