#!/bin/bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/lib/common.sh"

main() {
    check_arch
    header "ROFI"
    install_pacman_pkg "rofi"
    stow_config "rofi"
    if command -v yay &>/dev/null; then
        install_yay_pkg "sigma-file-manager-bin"
    fi
    log "Rofi instalado"
}
main "$@"
