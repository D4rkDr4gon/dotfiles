#!/usr/bin/env bash

set -e

THEMES_DIR="$HOME/dotfiles/themes"
CURRENT_THEME_FILE="$HOME/.config/qtile/current_theme.json"
POLYBAR_COLORS="$HOME/.config/polybar/colors.ini"
ROFI_THEME="$HOME/.config/rofi/theme.rasi"
KITTY_COLORS="$HOME/.config/kitty/colors.conf"
ZSH_COLORS="$HOME/.zsh_colors"
FASTFETCH_COLORS="$HOME/.config/fastfetch/colors.json"
QTILE_SCREENS="$HOME/dotfiles/qtile/modules/screens.py"
ROFI_DIR="$HOME/dotfiles/rofi"

usage() {
    echo "Uso: theme <tema|comando>"
    echo ""
    echo "Comandos:"
    echo "  --list          Listar temas disponibles"
    echo "  <nombre>        Aplicar tema (e.g., theme kali-red)"
    echo ""
    exit 1
}

list_themes() {
    echo "Temas disponibles:"
    for theme_dir in "$THEMES_DIR"/*/; do
        theme_name=$(basename "$theme_dir")
        if [[ -f "$theme_dir/theme.json" ]]; then
            display_name=$(jq -r '.name' "$theme_dir/theme.json" 2>/dev/null || echo "$theme_name")
            echo "  - $theme_name ($display_name)"
        fi
    done
    exit 0
}

check_deps() {
    for cmd in jq; do
        if ! command -v "$cmd" &>/dev/null; then
            echo "Error: $cmd no está instalado"
            exit 1
        fi
    done
}

load_theme() {
    local theme_name=$1
    local theme_dir="$THEMES_DIR/$theme_name"

    if [[ ! -d "$theme_dir" ]]; then
        echo "Error: Tema '$theme_name' no encontrado"
        exit 1
    fi

    if [[ ! -f "$theme_dir/theme.json" ]]; then
        echo "Error: theme.json no encontrado en $theme_dir"
        exit 1
    fi

    echo "$theme_dir"
}

apply_theme_config() {
    local theme_name=$1
    local theme_dir=$2

    local wallpaper=$(jq -r '.wallpaper' "$theme_dir/theme.json")
    local primary=$(jq -r '.primary' "$theme_dir/theme.json")
    local secondary=$(jq -r '.secondary' "$theme_dir/theme.json")
    local background=$(jq -r '.background' "$theme_dir/theme.json")
    local foreground=$(jq -r '.foreground' "$theme_dir/theme.json")
    local chip_battery=$(jq -r '.chip_battery' "$theme_dir/theme.json")
    local chip_bluetooth=$(jq -r '.chip_bluetooth' "$theme_dir/theme.json")
    local chip_wlan=$(jq -r '.chip_wlan' "$theme_dir/theme.json")
    local chip_audio=$(jq -r '.chip_audio' "$theme_dir/theme.json")

    cat > "$POLYBAR_COLORS" << EOF
[colors]
primary = $primary
background = $background
background-alt = #1a1a1a

foreground = $foreground
foreground-alt = #8a8a8a

chip-battery   = $chip_battery
chip-bluetooth = $chip_bluetooth
chip-wlan      = $chip_wlan
chip-audio     = $chip_audio
chip-workspace = $primary
chip-bright    = $secondary

alert = #ff4444
disabled = #555555
EOF

    cat > "$ROFI_THEME" << EOF
/**
 * Tema: $(jq -r '.name' "$theme_dir/theme.json")
 */

* {
    bg:          $background;
    bg-alt:      #1a1a1a;
    fg:          $foreground;
    accent:      $primary;
    accent-alt:  $secondary;

    background-color:   transparent;
    text-color:         @fg;
    font:               "Hack Regular 11";
}

window {
    background-color:   @bg;
    border:             1px;
    border-color:       @accent-alt;
    border-radius:      2px;
    width:              900px;
    padding:            8px;
}

mainbox {
    children:           [ inputbar, listview ];
}

inputbar {
    background-color:   @bg-alt;
    border-radius:      2px;
    padding:            10px;
    margin:             0 0 5px 0;
    children:           [ prompt, entry ];
}

prompt {
    text-color:         @accent;
    font:               "Hack Bold 11";
    padding:            0 10px;
}

entry {
    placeholder:        "Search applications...";
    placeholder-color:  #444444;
}

listview {
    lines:              5;
    columns:            1;
    fixed-height:       0;
    scrollbar:          false;
    spacing:            2px;
}

element {
    padding:            5px 15px;
    border-radius:      1px;
}

element selected {
    background-color:   @accent;
    text-color:         #ffffff;
}

element-text {
    vertical-align:     0.5;
    text-color:         inherit;
}

element-icon {
    size:               18px;
    padding:            0 12px 0 0;
}
EOF

    cat > "$KITTY_COLORS" << EOF
foreground $foreground
background $background
cursor $primary
selection_background $secondary
selection_foreground #ffffff
active_tab_foreground #ffffff
active_tab_background $primary
inactive_tab_foreground #888888
inactive_tab_background #1a1a1a
EOF

    cat > "$ZSH_COLORS" << EOF
export COLOR_PRIMARY="$primary"
export COLOR_ACCENT="$secondary"
export COLOR_BG="$background"
export COLOR_FG="$foreground"
EOF

    cat > "$FASTFETCH_COLORS" << EOF
{
  "primary": "$primary",
  "secondary": "$secondary",
  "background": "$background",
  "foreground": "$foreground"
}
EOF

    sed -i "s|wallpaper = \".*\"|wallpaper = \"$wallpaper\"|" "$QTILE_SCREENS"

    cp "$theme_dir/theme.json" "$CURRENT_THEME_FILE"
}

reload_components() {
    if command -v polybar &>/dev/null; then
        polybarupdate 2>/dev/null || polybar-msg cmd restart 2>/dev/null || true
    fi

    if command -v kitty &>/dev/null; then
        if [[ -f "$KITTY_COLORS" ]]; then
            kitty @ set-colors --all -c "$KITTY_COLORS" 2>/dev/null || true
        fi
    fi

    if pgrep -x qtile &>/dev/null; then
        qtile cmd-obj -o cmd -f reload_config 2>/dev/null || true
    fi
}

apply_theme() {
    local theme_name=$1
    local theme_dir=$(load_theme "$theme_name")

    echo "Aplicando tema: $(jq -r '.name' "$theme_dir/theme.json")"

    apply_theme_config "$theme_name" "$theme_dir"
    reload_components

    echo "✓ Tema '$theme_name' aplicado"
}

if [[ $# -eq 0 ]]; then
    usage
fi

if [[ "$1" == "--list" ]]; then
    list_themes
fi

check_deps
apply_theme "$1"