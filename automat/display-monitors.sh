#!/bin/bash
if [ "$XDG_SESSION_TYPE" = "wayland" ]; then
  wlr-randr --output eDP --mode 1920x1080 --pos 0,0 \
    --output HDMI-A-0 --mode 1920x1080 --pos 1920,0
else
  xrandr --output eDP --primary --mode 1920x1080 --pos 0x0 \
    --output HDMI-A-0 --mode 1920x1080 --pos 1920x0
fi
