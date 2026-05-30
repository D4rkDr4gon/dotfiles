#!/bin/bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/lib/common.sh"

OFFICIAL_DEPS=(
    qtile python python-pip python-setuptools python-wheel python-cffi
    python-xcffib python-cairocffi python-dbus-next python-pywl
    python-psutil python-iwlib python-keybinder2 python-pyqt6-sip
    python-dateutil python-mpd2 pulseaudio brightnessctl networkmanager
    bluez bluez-utils alsa-utils lm_sensors acpid
)
DEV_TOOLS=(python-black python-flake8 python-mypy python-pylint python-autopep8 python-isort)
PYTHON_EXTRA=(qtile-extras python-netaddr python-requests python-beautifulsoup4 python-lxml python-yaml python-toml python-click)
AUR_PKGS=(python-qtile-git python-qtile-extras-git)

main() {
    check_arch
    header "QTILE WINDOW MANAGER"
    for pkg in "${OFFICIAL_DEPS[@]}"; do install_pacman_pkg "$pkg"; done
    for pkg in "${DEV_TOOLS[@]}"; do install_pacman_pkg "$pkg"; done
    for pkg in "${PYTHON_EXTRA[@]}"; do install_pacman_pkg "$pkg"; done

    if command -v yay &>/dev/null; then
        for pkg in "${AUR_PKGS[@]}"; do install_yay_pkg "$pkg"; done
    fi

    # Desktop entries
    local xsessions="/usr/share/xsessions/qtile.desktop"
    if [ ! -f "$xsessions" ]; then
        sudo tee "$xsessions" > /dev/null <<< '[Desktop Entry]
Name=Qtile
Comment=Qtile Session (X11)
Exec=/usr/bin/qtile start
Type=Application
Keywords=wm;tiling'
        log "Session X11 creada"
    fi

    local wayland_sessions="/usr/share/wayland-sessions/qtile-wayland.desktop"
    if [ ! -f "$wayland_sessions" ]; then
        sudo mkdir -p /usr/share/wayland-sessions
        sudo tee "$wayland_sessions" > /dev/null <<< '[Desktop Entry]
Name=Qtile (Wayland)
Comment=Qtile Session (Wayland)
Exec=/usr/bin/qtile start -b wayland
Type=Application
Keywords=wm;tiling;wayland'
        log "Session Wayland creada"
    fi

    log "Qtile instalado. Seleccionalo en lightdm (Qtile para X11, Qtile (Wayland) para Wayland)."
}
main "$@"
