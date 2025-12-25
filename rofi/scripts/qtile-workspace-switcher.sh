#!/usr/bin/env bash

CHOICE=$(printf "NET \nMEDIA 󱍙\nDEV \nSYS \nWEB 󰈹\nCHAT 󰭻\n" | rofi -dmenu -p "Go to workspace")

[ -z "$CHOICE" ] && exit 0

qtile cmd-obj -o group "$CHOICE" -f toscreen