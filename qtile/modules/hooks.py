import os
import subprocess
from libqtile import hook, qtile


@hook.subscribe.startup_once
def autostart():
    home = os.path.expanduser('~')

    processes = [
        ['nitrogen', '--restore'],
        ['bash', home + '/.config/polybar/launch.sh'],
        ['picom'],
        ['dunst'],
    ]

    for p in processes:
        try:
            subprocess.Popen(p)
        except Exception as e:
            print(f"Error al iniciar {p}: {e}")


@hook.subscribe.startup_complete
@hook.subscribe.screen_change
def setup_environment():
    if not qtile.groups_map:
        return

    # === GROUPS / SCREENS ===
    screens = qtile.screens

    if len(screens) >= 2:
        qtile.groups_map["PRINCIPAL"].toscreen(0)
        qtile.groups_map["DEV"].toscreen(0)
        qtile.groups_map["GENERAL"].toscreen(0)
        qtile.groups_map["EXTRAS"].toscreen(0)

        qtile.groups_map["SECUNDARIO"].toscreen(1)
    else:
        qtile.groups_map["PRINCIPAL"].toscreen(0)
        qtile.groups_map["SECUNDARIO"].toscreen(0)
        qtile.groups_map["DEV"].toscreen(0)
        qtile.groups_map["GENERAL"].toscreen(0)
        qtile.groups_map["EXTRAS"].toscreen(0)

    # === POLYBAR UPDATE ===
    try:
        subprocess.Popen([os.path.expanduser("~/.local/bin/polybarupdate")])
    except Exception as e:
        print(f"Error updating polybar: {e}")

    # === WELCOME NOTIFICATION ===
    try:
        subprocess.Popen([
            "notify-send", "-u", "normal", "-t", "5000",
            "Bienvenido D4rkDr4g0n",
            "Sistema listo. Usá Mod+Shift+Space para ajustes."
        ])
    except Exception as e:
        print(f"Error sending welcome notification: {e}")