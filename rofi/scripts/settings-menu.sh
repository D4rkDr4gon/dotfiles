#!/usr/bin/env bash

SETTINGS_DIR="$(cd "$(dirname "$0")" && pwd)"
THEMES_DIR="$HOME/dotfiles/themes"
WALLPAPER_DIR="$HOME/dotfiles/recursos/wallpapers"
THEME_SWITCH="$HOME/dotfiles/scripts/theme-switch.sh"

show_main_menu() {
    printf "  Themes\n  Workspaces\n󰏓  Apps\n  Search\n  Backgrounds\n  Notifications\n" \
        | rofi -dmenu -p "Settings" -theme "$HOME/.config/rofi/theme.rasi" \
            -theme-str 'entry { placeholder: "Choose an option..."; }'
}

list_themes() {
    local names=()
    local dirs=()

    for theme_dir in "$THEMES_DIR"/*/; do
        [[ -d "$theme_dir" ]] || continue
        local json="$theme_dir/theme.json"
        [[ -f "$json" ]] || continue
        local name
        name=$(jq -r '.name // "unknown"' "$json" 2>/dev/null)
        local dir_name
        dir_name=$(basename "$theme_dir")
        names+=("$name")
        dirs+=("$dir_name")
    done

    while true; do
        local selection
        selection=$(printf '%s\n' "${names[@]}" | rofi -dmenu -p "Themes" \
            -theme "$HOME/.config/rofi/theme.rasi" \
            -theme-str 'entry { placeholder: "Select a theme..."; }')

        [[ -z "$selection" ]] && exit 0

        local selected_dir=""
        local selected_name="$selection"
        for i in "${!names[@]}"; do
            if [[ "${names[$i]}" == "$selection" ]]; then
                selected_dir="${dirs[$i]}"
                break
            fi
        done
        [[ -z "$selected_dir" ]] && exit 0

        local preview_path="$THEMES_DIR/$selected_dir/preview.png"
        local has_preview=false
        [[ -f "$preview_path" ]] && has_preview=true

        local action
        if $has_preview; then
            local tmpdir
            tmpdir=$(mktemp -d)
            local thumbnail="$tmpdir/preview.jpg"
            convert "$preview_path" -resize 800x400^ -gravity north -extent 800x400 "$thumbnail" 2>/dev/null

            action=$(printf "✓  Apply\n←  Go Back\n" | rofi -dmenu -p "$selected_name" \
                -theme "$HOME/.config/rofi/theme.rasi" \
                -theme-str 'window { background-image: url("'"$thumbnail"'"); background-color: rgba(0,0,0,0.15); width: 800; }' \
                -theme-str 'mainbox { padding: 400px 0 0; background-color: transparent; }' \
                -theme-str 'inputbar { enabled: false; }' \
                -theme-str 'listview { background-color: rgba(10,10,10,0.75); margin: 0 12px 12px; border-radius: 16px; lines: 2; fixed-height: false; }' \
                -theme-str 'element { padding: 12px 16px; border-radius: 12px; }' \
                -theme-str 'element selected { background-color: rgba(51,51,51,0.95); }')

            rm -rf "$tmpdir"
        else
            action=$(printf "✓  Apply\n←  Go Back\n" | rofi -dmenu -p "$selected_name" \
                -theme "$HOME/.config/rofi/theme.rasi" \
                -theme-str 'entry { placeholder: "No preview available. Apply?"; }')
        fi

        if [[ "$action" == "✓  Apply" ]]; then
            bash "$THEME_SWITCH" "$selected_dir"
            exit 0
        fi
    done
}

list_workspaces() {
    bash "$SETTINGS_DIR/qtile-workspace-switcher.sh"
}

web_search() {
    bash "$SETTINGS_DIR/web-search.sh"
}

list_backgrounds() {
    local wallpaper_dir="$WALLPAPER_DIR"

    local files=()
    local names=()
    for f in "$wallpaper_dir"/*.{jpg,jpeg,png}; do
        [[ -f "$f" ]] || continue
        local base
        base=$(basename "$f")
        files+=("$f")
        names+=("${base%.*}")
    done

    while true; do
        local selection
        selection=$(printf '%s\n' "${names[@]}" | rofi -dmenu -p "Backgrounds" \
            -theme "$HOME/.config/rofi/theme.rasi" \
            -theme-str 'entry { placeholder: "Select a wallpaper..."; }')

        [[ -z "$selection" ]] && exit 0

        local selected_path=""
        for i in "${!names[@]}"; do
            if [[ "${names[$i]}" == "$selection" ]]; then
                selected_path="${files[$i]}"
                break
            fi
        done
        [[ -z "$selected_path" ]] && exit 0

        local tmpdir
        tmpdir=$(mktemp -d)
        local thumbnail="$tmpdir/preview.jpg"
        convert "$selected_path" -resize 800x400^ -gravity center -extent 800x400 "$thumbnail" 2>/dev/null

        local action
        action=$(printf "✓  Apply\n←  Go Back\n" | rofi -dmenu -p "" \
            -theme "$HOME/.config/rofi/theme.rasi" \
            -theme-str 'window { background-image: url("'"$thumbnail"'"); background-color: rgba(0,0,0,0.15); width: 800; }' \
            -theme-str 'mainbox { padding: 400px 0 0; background-color: transparent; }' \
            -theme-str 'inputbar { enabled: false; }' \
            -theme-str 'listview { background-color: rgba(10,10,10,0.75); margin: 0 12px 12px; border-radius: 16px; lines: 2; fixed-height: false; }' \
            -theme-str 'element { padding: 12px 16px; border-radius: 12px; }' \
            -theme-str 'element selected { background-color: rgba(51,51,51,0.95); }')

        rm -rf "$tmpdir"

        if [[ "$action" == "✓  Apply" ]]; then
            sed -i "s|wallpaper = \".*\"|wallpaper = \"$selected_path\"|" \
                "$HOME/dotfiles/qtile/modules/screens.py"

            CURRENT_THEME="$HOME/.config/qtile/current_theme.json"
            if command -v jq &>/dev/null && [[ -f "$CURRENT_THEME" ]]; then
                jq --arg wp "$selected_path" '.wallpaper = $wp' "$CURRENT_THEME" > /tmp/current_theme.json && \
                    mv /tmp/current_theme.json "$CURRENT_THEME"
            fi

            if command -v betterlockscreen &>/dev/null; then
                betterlockscreen -u "$selected_path" >> /tmp/betterlockscreen.log 2>&1 || true
            fi

            qtile cmd-obj -o cmd -f reload_config 2>/dev/null || true
            bash /home/lcampassi/dotfiles/scripts/barupdate.sh 2>/dev/null || true
            notify-send "Fondo de pantalla" "Cambiado a $selection" -t 2000
            exit 0
        fi
    done
}

main() {
    local choice
    choice=$(show_main_menu)
    [[ -z "$choice" ]] && exit 0

    case "$choice" in
        "  Themes"|Themes)
            list_themes
            ;;
        "  Workspaces"|Workspaces)
            list_workspaces
            ;;
        "󰏓  Apps"|Apps)
            rofi -show drun
            ;;
        "  Search"|Search)
            web_search
            ;;
        "  Backgrounds"|Backgrounds)
            list_backgrounds
            ;;
        "  Notifications"|Notifications)
            bash "$SETTINGS_DIR/notification-center.sh"
            ;;
        *)
            exit 0
            ;;
    esac
}

main
