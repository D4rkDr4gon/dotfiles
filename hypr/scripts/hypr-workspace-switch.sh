#!/usr/bin/env bash
# Workspace switcher for Hyprland + Waybar scroll
# Usage: hypr-workspace-switch.sh next|prev

ACTION="$1"

case "$ACTION" in
    next)
        hyprctl dispatch workspace +1
        ;;
    prev)
        hyprctl dispatch workspace -1
        ;;
    *)
        echo "Usage: $0 {next|prev}"
        exit 1
        ;;
esac
