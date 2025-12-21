import os
import subprocess
from libqtile import hook

@hook.subscribe.startup_once
def autostart():
    home = os.path.expanduser('~')
    
    # Lista de aplicaciones a iniciar
    processes = [
        ['nitrogen', '--restore'],
        [home + '/.config/polybar/launch.sh'],
        ['picom']
    ]

    for p in processes:
        try:
            subprocess.Popen(p)
        except Exception as e:
            print(f"Error al iniciar {p}: {e}")