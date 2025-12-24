#!/usr/bin/env bash

CHOICE=$(printf "PRINCIPAL\nSECUNDARIO\nDEV\nGENERAL\nEXTRAS" | rofi -dmenu -p "Go to workspace")

[ -z "$CHOICE" ] && exit 0

qtile cmd-obj -o group "$CHOICE" -f toscreen