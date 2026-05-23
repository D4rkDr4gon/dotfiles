#!/usr/bin/env bash

query=$(rofi -dmenu -p "🌐 Search" -theme /home/lcampassi/.config/rofi/theme.rasi \
    -theme-str 'entry { placeholder: "Google search..."; }')

[ -z "$query" ] && exit 0

encoded=$(echo "$query" | sed 's/ /+/g')

qtile cmd-obj -o group "WEB 󰈹" -f toscreen
firefox "https://www.google.com/search?q=$encoded" &

for i in {1..10}; do
    wmctrl -a firefox 2>/dev/null && break
    sleep 0.1
done
