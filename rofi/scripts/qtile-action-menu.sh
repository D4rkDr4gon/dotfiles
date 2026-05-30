#!/usr/bin/env bash

CHOICE=$(printf "Lock\0icon\x1fsystem-lock-screen\nReboot\0icon\x1fsystem-reboot\nPoweroff\0icon\x1fsystem-shutdown\nLogout\0icon\x1fapplication-exit" |
  rofi -dmenu -p "Actions" -show-icons -theme /home/lcampassi/.config/rofi/theme-action.rasi)

[ -z "$CHOICE" ] && exit 0

case "$CHOICE" in
"Lock")
  bash ~/dotfiles/scripts/lock-screen.sh
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
