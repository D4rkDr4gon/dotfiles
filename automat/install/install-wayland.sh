#!/bin/bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/lib/common.sh"

WAYLAND_PKGS=(
    wayland wlroots0.19
    waybar wlr-randr swaybg
    grim slurp wl-clipboard
    swaylock swayidle
)

main() {
    check_arch
    header "WAYLAND PACKAGES"

    for pkg in "${WAYLAND_PKGS[@]}"; do
        install_pacman_pkg "$pkg"
    done

    # Stow configs
    stow_config "waybar"
    stow_config "swaylock"

    if [ -f "$HOME/.config/waybar/launch.sh" ]; then
        chmod +x "$HOME/.config/waybar/launch.sh"
    fi

    log "Paquetes Wayland instalados. Selecciona 'Qtile (Wayland)' en lightdm."
    log "Rofi 2.0+ ya soporta Wayland nativamente (no requiere paquete extra)."
}

main "$@"
