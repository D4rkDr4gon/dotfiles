#!/usr/bin/env bash
# Widget "Agentes IA": delega en el lanzador generico de TUIs flotantes
# (ver float-tui-launch.sh) con el tamaño exacto que dibuja
# claude-agents-tui.sh (64 columnas x 13 filas).
exec bash "$HOME/.config/waybar/scripts/float-tui-launch.sh" \
    claude-agents 'Agentes IA' 64 13 \
    bash "$HOME/.config/waybar/scripts/claude-agents-tui.sh"
