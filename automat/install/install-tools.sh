#!/bin/bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/lib/common.sh"

OFFICIAL=(obsidian flameshot firefox copyq discord spotify btop)
AUR_TOOLS=(sigma-file-manager-bin bitwarden onedriver)

main() {
    check_arch
    header "HERRAMIENTAS DE PRODUCTIVIDAD"
    for pkg in "${OFFICIAL[@]}"; do install_pacman_pkg "$pkg"; done
    if command -v yay &>/dev/null; then
        for pkg in "${AUR_TOOLS[@]}"; do install_yay_pkg "$pkg"; done
    fi
    mkdir -p "$HOME/Pictures/Screenshots" "$HOME/Downloads/TEMP" "$HOME/Documents/Projects"
    log "Herramientas instaladas"
}
main "$@"
