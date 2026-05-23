from libqtile.config import Group, Key
from libqtile.lazy import lazy
from .keys import keys, mod

# Mapeo OFICIAL (una sola verdad)
WORKSPACE_MAP = [
    ("1", "  "),
    ("2", " 󱍙 "),
    ("3", "  "),
    ("4", "  "),
    ("5", " 󰈹 ")
]

# Grupos: name = lo que Polybar va a mostrar
groups = [Group(name) for _, name in WORKSPACE_MAP]

# Keybindings: números → nombres
for key, name in WORKSPACE_MAP:
    keys.extend([
        Key([mod], key,
            lazy.group[name].toscreen(),
            desc=f"Go to {name}"
        ),
        Key([mod, "shift"], key,
            lazy.window.togroup(name),
            desc=f"Move window to {name}"
        ),
    ])
