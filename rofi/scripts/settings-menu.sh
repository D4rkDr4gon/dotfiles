#!/usr/bin/env bash

SETTINGS_DIR="$(cd "$(dirname "$0")" && pwd)"
THEMES_DIR="$HOME/dotfiles/themes"
WALLPAPER_DIR="$HOME/dotfiles/recursos/wallpapers"
THEME_SWITCH="$HOME/dotfiles/scripts/theme-switch.sh"

show_main_menu() {
    printf "  Themes\n  Workspaces\n󰏓  Apps\n  Search\n  Backgrounds\n" \
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
            notify-send "Theme" "Switched to ${names[$i]}" -t 2000
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
    local wallpaper_files=()
    local wallpaper_names=()

    for f in "$WALLPAPER_DIR"/*.{jpg,jpeg,png}; do
        [[ -f "$f" ]] || continue
        local base
        base=$(basename "$f")
        wallpaper_files+=("$f")
        wallpaper_names+=("${base%.*}")
    done

    local selection
    selection=$(printf '%s\n' "${wallpaper_names[@]}" | rofi -dmenu -p "Backgrounds" \
        -theme "$HOME/.config/rofi/theme.rasi" \
        -theme-str 'entry { placeholder: "Select a wallpaper..."; }')

    [[ -z "$selection" ]] && exit 0

    for i in "${!wallpaper_names[@]}"; do
        if [[ "${wallpaper_names[$i]}" == "$selection" ]]; then
            local path="${wallpaper_files[$i]}"
            sed -i "s|wallpaper = \".*\"|wallpaper = \"$path\"|" "$HOME/dotfiles/qtile/modules/screens.py"
            nitrogen --set-zoom-fill "$path"
            qtile cmd-obj -o cmd -f reload_config 2>/dev/null || true
            notify-send "Wallpaper" "Changed to ${wallpaper_names[$i]}" -t 2000
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
        *)
            exit 0
            ;;
    esac
}

main
