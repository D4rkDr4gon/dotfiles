#!/usr/bin/env bash

CHOICE=$(printf "NOTES  \nFILES  󱍙\nDEV    \nSYS    \nWEB    󰈹\n" | rofi -dmenu -p "Go to workspace")

[ -z "$CHOICE" ] && exit 0

qtile cmd-obj -o group "$(echo "$CHOICE" | awk '{print $NF}')" -f toscreen