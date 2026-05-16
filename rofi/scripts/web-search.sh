#!/usr/bin/env bash

query=$(rofi -dmenu -p "🌐 Search" -theme /home/lcampassi/.config/rofi/theme.rasi \
    -theme-str 'entry { placeholder: "Google search..."; }')

[ -z "$query" ] && exit 0

encoded=$(echo "$query" | sed 's/ /+/g')
firefox "https://www.google.com/search?q=$encoded"
