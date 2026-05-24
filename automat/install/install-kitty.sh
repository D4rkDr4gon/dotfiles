#!/bin/bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/lib/common.sh"

main() {
    check_arch
    header "KITTY"
    install_pacman_pkg "kitty"
    stow_config "kitty"
    log "Kitty instalado"
}
main "$@"
