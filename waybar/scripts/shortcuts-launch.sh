#!/usr/bin/env bash
# Cheatsheet de shortcuts (Hyprland/kitty/herdr/Qtile/Obsidian, ver + editar):
# delega en el lanzador genérico de TUIs flotantes (float-tui-launch.sh)
# con el tamaño que necesita la tabla de shortcuts_tui.py.
exec bash "$HOME/.config/waybar/scripts/float-tui-launch.sh" \
    shortcuts 'Shortcuts' 110 34 \
    python3 "$HOME/dotfiles/recursos/shortcuts/shortcuts_tui.py"
