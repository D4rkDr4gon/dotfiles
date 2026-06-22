#!/bin/bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/lib/common.sh"

OFFICIAL_DEPS=(
    hyprland
    hyprpaper
    hyprlock
    hypridle
    xdg-desktop-portal-hyprland
)

main() {
    check_arch
    header "HYPRLAND WINDOW MANAGER"

    for pkg in "${OFFICIAL_DEPS[@]}"; do
        install_pacman_pkg "$pkg"
    done

    # Stow hypr config
    stow_config "hypr"

    # Copiar desktop entry personalizado a /usr/share/wayland-sessions/
    # No puede ser symlink por limitaciones del directorio del sistema
    local dotfiles_desktop="$HOME/dotfiles/hypr/hyprland.desktop"
    local system_desktop="/usr/share/wayland-sessions/hyprland.desktop"
    if [ -f "$dotfiles_desktop" ]; then
        if sudo cp "$dotfiles_desktop" "$system_desktop"; then
            log "✓ Desktop entry copiado a $system_desktop"
        else
            warn "No se pudo copiar el desktop entry. Hacelo manual:"
            warn "  sudo cp ~/dotfiles/hypr/hyprland.desktop /usr/share/wayland-sessions/hyprland.desktop"
        fi
    else
        warn "Desktop entry no encontrado en $dotfiles_desktop"
        if [ -f "$system_desktop" ]; then
            log "  Usando el existente en $system_desktop"
        fi
    fi

    # Dar permisos de ejecución a scripts
    local hypr_scripts=(
        "$HOME/.config/hypr/scripts/hypr-workspaces.py"
        "$HOME/.config/hypr/scripts/hypr-workspace-switch.sh"
    )
    for script in "${hypr_scripts[@]}"; do
        if [ -f "$script" ]; then
            chmod +x "$script"
        fi
    done

    log "Hyprland instalado. Seleccionalo en LightDM para iniciar sesión."
    log ""
    log "⚠️  IMPORTANTE: Probá primero con:"
    log "   hyprctl monitors        # Verificar monitores"
    log "   Hyprland                # Iniciar desde TTY para probar"
    log ""
    log "Si ves pantalla negra, ejecutá:"
    log "   export WLR_NO_HARDWARE_CURSORS=1"
    log "   export WLR_RENDERER_ALLOW_SOFTWARE=1"
    log "   Hyprland"
}

main "$@"
