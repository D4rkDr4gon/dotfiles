#!/usr/bin/env bash

CHOICE=$(printf "⏾ Suspend\n Reboot\n⏻ Poweroff\n Logout" | rofi -dmenu -p "Actions")

[ -z "$CHOICE" ] && exit 0

case "$CHOICE" in
    "⏾ Suspend")
        suspend now
        ;;
    " Reboot")
        reboot now
        ;;
    "⏻ Poweroff")
        shutdown now
        ;;
    " Logout")
        qtile cmd-obj -o cmd -f shutdown
        ;;
esac