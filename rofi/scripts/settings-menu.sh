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
    local entries=()
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
        entries+=("$name")
        names+=("$name")
        dirs+=("$dir_name")
    done

    local selection
    selection=$(printf '%s\n' "${entries[@]}" | rofi -dmenu -p "Themes" \
        -theme "$HOME/.config/rofi/theme.rasi" \
        -theme-str 'entry { placeholder: "Select a theme..."; }')

    [[ -z "$selection" ]] && exit 0

    for i in "${!names[@]}"; do
        if [[ "${names[$i]}" == "$selection" ]]; then
            bash "$THEME_SWITCH" "${dirs[$i]}"
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
            qtile cmd-obj -o cmd -f reload_config 2>/dev/null || true
            notify-send "Wallpaper" "Changed to $selection" -t 2000
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
