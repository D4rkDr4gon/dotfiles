from libqtile.config import Key
from libqtile.lazy import lazy
from libqtile.utils import guess_terminal

# Variables
# mod4 => Windows/super mod1=ALT mod5=ALTGR

mod = "mod4"
terminal = "kitty"
browser = "firefox"
# theme = "../../../usr/share/rofi/themes/Arc-Dark.rasi"

# Configuring a key "Key(<key press>, <key press>, command, desc="description of command"),"

keys = [
    
    # Volume control
    Key([], "XF86AudioRaiseVolume", lazy.spawn("pactl set-sink-volume @DEFAULT_SINK@ +5%"), desc="Volume up"),
    Key([], "XF86AudioLowerVolume", lazy.spawn("pactl set-sink-volume @DEFAULT_SINK@ -5%"), desc="Volume down"),
    Key([], "XF86AudioMute", lazy.spawn("pactl set-sink-mute @DEFAULT_SINK@ toggle"), desc="Mute/Unmute audio"),
    Key([], "XF86AudioMicMute", lazy.spawn("pactl set-source-mute @DEFAULT_SOURCE@ toggle"), desc="Mute/Unmute micro"),
    
    # Brightness controls
    Key([], "XF86MonBrightnessUp", lazy.spawn("brightnessctl set +10%"), desc="Brightness up"),
    Key([], "XF86MonBrightnessDown", lazy.spawn("brightnessctl set 10%-"), desc="Brightness down"),
    
    # Open Apps
    Key([mod], "p", lazy.spawn("bitwarden"), desc="opens bitwarden password manager"),
    Key([mod], "e", lazy.spawn("thunderbird"), desc="opens email"),
    Key([mod], "a", lazy.spawn("thunar"), desc="opens file system"),
    Key([mod], "s", lazy.spawn(f"rofi -show drun"), desc="opens app manager"),
    Key([mod], "o", lazy.spawn("obsidian"), desc="opens notes"),
    Key([mod], "b", lazy.spawn(browser), desc="opens browser"),
    Key([mod], "Return", lazy.spawn(terminal), desc="opens terminal"),
    
    # Take screenshots
    Key([mod, "shift"], "s", lazy.spawn("flameshot gui"), desc="take screenshoot"),
    Key([], "print", lazy.spawn("flameshot gui"), desc="take screenshoot"),
    
    # Move between tabs and workspaces in qtile
    Key(["mod1"], "Tab", lazy.layout.next(), desc="move between tabs"),
    Key([mod], "Tab", lazy.next_layout(), desc="move between workspaces"),
    Key([mod], "q", lazy.window.kill(), desc="close focussed tab"),
    Key([mod], "f", lazy.window.toggle_fullscreen(), desc="fullscreen of focussed tab"),
    Key([mod], "t", lazy.window.toggle_floating(), desc="floating focussed tab"),
    
    # Moving out of range in Columns layout will create new column.
    Key([mod, "shift"], "Left", lazy.layout.shuffle_left(), desc="Move window to the left"),
    Key([mod, "shift"], "Right", lazy.layout.shuffle_right(), desc="Move window to the right"),
    Key([mod, "shift"], "Down", lazy.layout.shuffle_down(), desc="Move window down"),
    Key([mod, "shift"], "Up", lazy.layout.shuffle_up(), desc="Move window up"),
    # Grow windows. If current window is on the edge of screen and direction
    
    # will be to screen edge - window would shrink.
    Key([mod, "control"], "Left", lazy.layout.grow_left(), desc="Grow window to the left"),
    Key([mod, "control"], "Right", lazy.layout.grow_right(), desc="Grow window to the right"),
    Key([mod, "control"], "Down", lazy.layout.grow_down(), desc="Grow window down"),
    Key([mod, "control"], "Up", lazy.layout.grow_up(), desc="Grow window up"),
    Key([mod], "n", lazy.layout.normalize(), desc="Reset all window sizes"),
    
    # Actions for qtile
    Key([mod, "control"], "r", lazy.reload_config(), desc="reloads qtiles's configuration"),
    Key([mod], "l", lazy.shutdown(), desc="blocks PC"),
]