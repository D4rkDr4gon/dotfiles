import os
import subprocess
from libqtile import hook


@hook.subscribe.startup_once
def autostart():
    home = os.path.expanduser('~')

    # Desactivar DPMS y screen saver — solo bloqueo manual
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
        'bash', '-c',
        'sleep 2 && notify-send -u normal -t 5000 "Bienvenido de nuevo! D4rkDr4g0n" "Todos los sistemas en linea a la espera de ordenes."'
    ])
