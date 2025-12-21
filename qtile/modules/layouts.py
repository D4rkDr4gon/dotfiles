from libqtile import layout
from libqtile.config import Match

layouts = [
    layout.Columns(border_focus_stack=["#d75f5f", "#8f3d3d"], border_width=4),
    layout.MonadTall(
        margin=8,
        border_width=2,
        border_focus="#d32f2f",
        border_normal="#1a1a1a"
    ),
    layout.Stack(
        num_stacks=2,
        margin=8,
        border_width=2,
        border_focus="#d32f2f",
        border_normal="#1a1a1a"
    ),
]

floating_layout = layout.Floating(
    float_rules=[
        *layout.Floating.default_float_rules,
        Match(wm_class="confirmreset"),
        Match(wm_class="makebranch"),
        Match(wm_class="maketag"),
        Match(wm_class="ssh-askpass"),
        Match(title="branchdialog"),
        Match(title="pinentry"),
    ]
)
