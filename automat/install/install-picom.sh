#!/bin/bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/lib/common.sh"

main() {
    check_arch
    header "PICOM"
    install_pacman_pkg "picom"
    stow_config "picom"
    log "Picom instalado"
}
main "$@"
