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

    # Desktop entry
    local desktop="/usr/share/xsessions/qtile.desktop"
    if [ ! -f "$desktop" ]; then
        sudo tee "$desktop" > /dev/null <<< '[Desktop Entry]
Name=Qtile
Comment=Qtile Session
Exec=/usr/bin/qtile start
Type=Application
Keywords=wm;tiling'
        log "Session file creado"
    fi

    log "Qtile instalado. Seleccionalo en lightdm."
}
main "$@"
