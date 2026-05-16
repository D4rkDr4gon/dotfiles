#!/usr/bin/env bash

generate_app_list() {
    for dir in /usr/share/applications ~/.local/share/applications; do
        [ -d "$dir" ] || continue
        for f in "$dir"/*.desktop; do
            [ -f "$f" ] || continue
            grep -q '^NoDisplay=true' "$f" && continue
            name=$(grep -m1 '^Name=' "$f" | cut -d= -f2)
            icon=$(grep -m1 '^Icon=' "$f" | cut -d= -f2)
            if [ -n "$icon" ]; then
                echo -e "$name\0icon\x1f$icon"
            else
                echo "$name"
            fi
        done
    done | sort -fu
}

selection=$(generate_app_list | rofi -dmenu -p "" -theme ~/.config/rofi/theme.rasi \
    -theme-str 'entry { placeholder: "Search apps or type g <query> for web..."; }')

[ -z "$selection" ] && exit 0

if [[ "$selection" == g\ * ]]; then
    search="${selection#g }"
    [ -z "$search" ] && exit 0
    encoded=$(echo "$search" | sed 's/ /+/g')
    firefox "https://www.google.com/search?q=$encoded"
    exit 0
fi

for dir in /usr/share/applications ~/.local/share/applications; do
    for f in "$dir"/*.desktop; do
        app_name=$(grep -m1 '^Name=' "$f" | cut -d= -f2)
        if [ "$app_name" = "$selection" ]; then
            base=$(basename "$f" .desktop)
            gtk-launch "$base" &
            exit 0
        fi
    done
done

eval "$selection" &
