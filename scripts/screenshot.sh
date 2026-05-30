#!/usr/bin/env bash

if [ "$XDG_SESSION_TYPE" = "wayland" ]; then
    grim -g "$(slurp)" - | wl-copy
    notify-send "Screenshot" "Copied to clipboard" -t 2000
else
    flameshot gui
fi
