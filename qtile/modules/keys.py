from libqtile.config import Key
from libqtile.lazy import lazy
from libqtile.utils import guess_terminal

mod = "mod4"
terminal = guess_terminal()
browser = "firefox"
theme = "../../../usr/share/rofi/themes/Arc-Dark.rasi"

keys = [
    Key([], "XF86AudioRaiseVolume", lazy.spawn("pactl set-sink-volume @DEFAULT_SINK@ +5%")),
    Key([], "XF86AudioLowerVolume", lazy.spawn("pactl set-sink-volume @DEFAULT_SINK@ -5%")),
    Key([], "XF86AudioMute", lazy.spawn("pactl set-sink-mute @DEFAULT_SINK@ toggle")),
    Key([], "XF86MonBrightnessUp", lazy.spawn("brightnessctl set +10%")),
    Key([], "XF86MonBrightnessDown", lazy.spawn("brightnessctl set 10%-")),
    Key([mod], "e", lazy.spawn("thunderbird")),
    Key([mod], "a", lazy.spawn("thunar")),
    Key([mod], "s", lazy.spawn(f"rofi -show drun -theme {theme}")),
    Key([mod], "o", lazy.spawn("obsidian")),
    Key([mod, "shift"], "s", lazy.spawn("flameshot gui")),
    Key([], "print", lazy.spawn("flameshot gui")),
    Key([mod], "b", lazy.spawn(browser)),
    Key(["mod1"], "Tab", lazy.layout.next()),
    Key(["mod1", "shift"], "Tab", lazy.layout.prev()),
    Key([mod], "Return", lazy.spawn(terminal)),
    Key([mod], "Tab", lazy.next_layout()),
    Key([mod], "q", lazy.window.kill()),
    Key([mod], "f", lazy.window.toggle_fullscreen()),
    Key([mod], "t", lazy.window.toggle_floating()),
    Key([mod, "control"], "r", lazy.reload_config()),
    Key([mod], "l", lazy.shutdown()),
]