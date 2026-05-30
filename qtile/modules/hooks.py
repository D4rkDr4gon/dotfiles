import os
import subprocess
import threading
from libqtile import hook


OPACITY_RULES = {
    "obsidian": 0.92,
    "sublime_text": 0.92,
    "subl": 0.92,
    "thunar": 0.92,
    "Thunar": 0.92,
    "rofi": 0.75,
    "dunst": 0.85,
    "kitty": 0.85,
}


def _apply_opacity(client, opacity):
    try:
        client.set_opacity(opacity)
    except Exception:
        pass


@hook.subscribe.client_new
def float_and_opacity(client):
    wm_class = " ".join(client.get_wm_class() or [])
    if "firefox" in wm_class:
        if client.floating:
            client.disable_floating()
        if client.maximized:
            client.toggle_maximized()
    for app, opacity in OPACITY_RULES.items():
        if app in wm_class:
            threading.Timer(0.3, _apply_opacity, args=[client, opacity]).start()
            break


@hook.subscribe.startup_once
def autostart():
    home = os.path.expanduser('~')
    is_wayland = 'WAYLAND_DISPLAY' in os.environ

    if is_wayland:
        processes = [
            ['bash', home + '/.config/waybar/launch.sh'],
            ['dunst'],
        ]
    else:
        subprocess.Popen(['xset', 's', 'off'])
        subprocess.Popen(['xset', '-dpms'])

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

    subprocess.Popen([
        'notify-send', '-u', 'normal', '-t', '3000',
        'Bienvenido de nuevo! D4rkDr4g0n',
        'Todos los sistemas en linea a la espera de ordenes.'
    ])
