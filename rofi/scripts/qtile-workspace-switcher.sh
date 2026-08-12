#!/usr/bin/env bash

CHOICE=$(printf " Workspace 1\n Workspace 2\n Workspace 3\n Workspace 4\n Workspace 5\n Workspace 6\n" | rofi -dmenu -p "Go to workspace")

[ -z "$CHOICE" ] && exit 0

WS=$(echo "$CHOICE" | awk '{print $NF}')

qtile cmd-obj -o group "$WS" -f toscreen
