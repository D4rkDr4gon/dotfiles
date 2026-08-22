from libqtile import layout
from libqtile.config import Match
import json
import os

def load_theme_colors():
    theme_file = os.path.expanduser("~/.config/qtile/current_theme.json")
    if os.path.exists(theme_file):
        with open(theme_file) as f:
            theme = json.load(f)
            return theme.get("primary", "#d32f2f"), theme.get("secondary", "#a12020")
    return "#d32f2f", "#a12020"

accent, accent_alt = load_theme_colors()

layouts = [
    layout.Columns(
        margin=4,
        border_width=2,
        border_focus=accent,
        border_normal="#1a1a1a",
        border_focus_stack=[accent, accent_alt],
    ),
    layout.MonadTall(
        margin=8,
        border_width=2,
        border_focus=accent,
        border_normal="#1a1a1a"
    ),
    layout.Stack(
        num_stacks=2,
        margin=8,
        border_width=2,
        border_focus=accent,
        border_normal="#1a1a1a"
    ),
]

floating_layout = layout.Floating(
    border_focus=accent,
    border_normal="#1a1a1a",
    border_width=1,
    float_rules=[
        *layout.Floating.default_float_rules,
        Match(wm_class="confirmreset"),
        Match(wm_class="makebranch"),
        Match(wm_class="maketag"),
        Match(wm_class="ssh-askpass"),
        Match(title="branchdialog"),
        Match(title="pinentry"),
        Match(wm_class="claude-agents"),
    ]
)
