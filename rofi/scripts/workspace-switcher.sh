#!/usr/bin/env bash
# Workspace Switcher — Dual-WM (Qtile + Hyprland)
# Reemplaza a qtile-workspace-switcher.sh con soporte para ambos WMs

CHOICE=$(printf "NOTES    \nFILES    󱍙\nDEV      \nSYS      \nWEB      󰈹\n" | rofi -dmenu -p "Go to workspace")

[ -z "$CHOICE" ] && exit 0

WS_NAME=$(echo "$CHOICE" | awk '{print $NF}' | xargs)

if [ -n "$HYPRLAND_INSTANCE_SIGNATURE" ]; then
  # Mapa nombre → número de workspace
  case "$WS_NAME" in
    "")  hyprctl dispatch workspace 1 ;;
    "󱍙") hyprctl dispatch workspace 2 ;;
    "") hyprctl dispatch workspace 3 ;;
    "") hyprctl dispatch workspace 4 ;;
    "󰈹") hyprctl dispatch workspace 5 ;;
  esac
else
  qtile cmd-obj -o group " $WS_NAME " -f toscreen
fi
