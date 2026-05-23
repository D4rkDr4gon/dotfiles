#!/usr/bin/env bash

CHOICE=$(printf "Suspend\0icon\x1fsystem-suspend\nReboot\0icon\x1fsystem-reboot\nPoweroff\0icon\x1fsystem-shutdown\nLogout\0icon\x1fapplication-exit" |
  rofi -dmenu -p "Actions" -show-icons -theme /home/lcampassi/.config/rofi/theme-action.rasi)

[ -z "$CHOICE" ] && exit 0

case "$CHOICE" in
"Suspend")
  systemctl suspend
  ;;
"Reboot")
  reboot now
  ;;
"Poweroff")
  shutdown now
  ;;
"Logout")
  qtile cmd-obj -o cmd -f shutdown
  ;;
esac
