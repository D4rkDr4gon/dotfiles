import os
from libqtile import layout
from libqtile.config import Match
from typing import List

# 1. IMPORTACIÓN DE MÓDULOS PROPIOS
# Asegúrate de haber creado la carpeta 'modules' y el archivo '__init__.py'
from modules.keys import keys, mod
from modules.groups import groups
from modules.layouts import layouts, floating_layout
from modules.screens import screens
from modules.mouse import mouse
import modules.hooks  # Registra el autostart automáticamente

# 2. CONFIGURACIONES GLOBALES
widget_defaults = dict(
    font="sans",
    fontsize=12,
    padding=3,
)
extension_defaults = widget_defaults.copy()

# Comportamiento de ventanas y ratón
dgroups_key_binder = None
dgroups_app_rules: list[Match] = []
follow_mouse_focus = True
bring_front_click = False
floats_kept_above = True
cursor_warp = False
auto_fullscreen = True
focus_on_window_activation = "smart"
focus_previous_on_window_remove = False
reconfigure_screens = True
auto_minimize = True

# Compatibilidad con aplicaciones Java (como Burp Suite en Kali)
wmname = "LG3D"

# 3. CONFIGURACIÓN PARA WAYLAND (Opcional)
wl_input_rules = None
wl_xcursor_theme = None
wl_xcursor_size = 24