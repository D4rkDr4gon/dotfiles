from libqtile.config import Group, Key
from libqtile.lazy import lazy
from .keys import keys, mod

group_names = [
    ("GENERAL", "  "), ("CTF", "  "), ("DEV", "  "), ("VPN", " ")
]

groups = [Group(name, label=label) for name, label in group_names]

for i, (name, label) in enumerate(group_names, 1):
    keys.extend([
        Key([mod], str(i), lazy.group[name].toscreen()),
        Key([mod, "shift"], str(i), lazy.window.togroup(name, switch_group=True)),
    ])
