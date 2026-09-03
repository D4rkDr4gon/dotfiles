#!/usr/bin/env bash

set -e

THEMES_DIR="$HOME/dotfiles/themes"
CURRENT_THEME_FILE="$HOME/.config/qtile/current_theme.json"
POLYBAR_COLORS="$HOME/.config/polybar/colors.ini"
WAYBAR_COLORS="$HOME/.config/waybar/theme.css"
KITTY_COLORS="$HOME/.config/kitty/colors.conf"
ZSH_COLORS="$HOME/.zsh_colors"
BANNER_COLOR="$HOME/.zsh_banner_color"
FASTFETCH_COLORS="$HOME/.config/fastfetch/colors.json"
GTK_CSS="$HOME/.config/gtk-3.0/gtk.css"
OPENCODE_CONFIG="$HOME/.config/opencode/opencode.jsonc"
QTILE_SCREENS="$HOME/dotfiles/qtile/modules/screens.py"
HERDR_CONFIG="$HOME/dotfiles/herdr/config.toml"

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

    # feh solo sirve en X11, en Wayland ignora
    if [ "$XDG_SESSION_TYPE" != "wayland" ] && ! command -v feh &>/dev/null; then
        echo "⚠️  feh no está instalado. El cambio de wallpaper será más lento."
        echo "   Instalalo con: sudo pacman -S feh"
    fi
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
    local status_ok=$(jq -r '.status_ok' "$theme_dir/theme.json")
    local status_warn=$(jq -r '.status_warn' "$theme_dir/theme.json")
    local status_error=$(jq -r '.status_error' "$theme_dir/theme.json")

    # Extraer RGB para Waybar (necesita formato rgba)
    local bg_hex="${background#\#}"
    local bg_r=$((16#${bg_hex:0:2}))
    local bg_g=$((16#${bg_hex:2:2}))
    local bg_b=$((16#${bg_hex:4:2}))

    cat > "$POLYBAR_COLORS" << EOF
[colors]
primary = $primary
secondary = $secondary
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

    cat > "$KITTY_COLORS" << EOF
foreground $foreground
background $background
cursor $primary
cursor_text_color $background
selection_background $secondary
selection_foreground #ffffff

# {{{ Tab bar
active_tab_foreground #ffffff
active_tab_background $secondary
inactive_tab_foreground #888888
inactive_tab_background #1a1a1a
tab_bar_background $background
tab_bar_margin_color $background
# }}}

# {{{ URL & visual feedback
url_color $primary
url_style curly
active_border_color $primary
inactive_border_color #444444
bell_border_color $secondary
# }}}

# {{{ Status bar (kitty)
statusbar_fg $foreground
statusbar_bg $background
# }}}
EOF

    # Extraer colores en formato rgb
    local primary_hex="${primary#\#}"
    local primary_r=$((16#${primary_hex:0:2}))
    local primary_g=$((16#${primary_hex:2:2}))
    local primary_b=$((16#${primary_hex:4:2}))

    local secondary_hex="${secondary#\#}"
    local secondary_r=$((16#${secondary_hex:0:2}))
    local secondary_g=$((16#${secondary_hex:2:2}))
    local secondary_b=$((16#${secondary_hex:4:2}))

    cat > "$GTK_CSS" << EOF
/* ==========================================
   Temas dinámicos - Generado por theme-switch.sh
   Aplica a Thunar y aplicaciones GTK3
   ========================================== */

@define-color theme_bg $background;
@define-color theme_fg $foreground;
@define-color theme_primary $primary;
@define-color theme_secondary $secondary;
@define-color theme_selected_bg $primary;
@define-color theme_selected_fg #ffffff;

/* ── Thunar ──────────────────────────────── */
.thunar {
  background-color: @theme_bg;
  color: @theme_fg;
}

.thunar .sidebar {
  background-color: shade(@theme_bg, 0.95);
  border-right: 1px solid shade(@theme_bg, 1.3);
}

.thunar .sidebar .view {
  background-color: shade(@theme_bg, 0.95);
  color: @theme_fg;
}

.thunar .sidebar .view:selected {
  background-color: @theme_primary;
  color: @theme_selected_fg;
}

.thunar .sidebar .view:selected:backdrop {
  background-color: shade(@theme_primary, 1.3);
}

.thunar .standard-view {
  background-color: @theme_bg;
}

.thunar .standard-view .view {
  background-color: @theme_bg;
  color: @theme_fg;
}

.thunar .standard-view .view:selected {
  background-color: @theme_primary;
  color: @theme_selected_fg;
}

.thunar .standard-view .view:selected:backdrop {
  background-color: shade(@theme_primary, 1.3);
}

.thunar .standard-view .view:active {
  background-color: shade(@theme_primary, 1.2);
}

.thunar .location-bar {
  background-color: shade(@theme_bg, 1.1);
  border-bottom: 1px solid shade(@theme_bg, 1.3);
}

.thunar .path-bar button {
  background-color: shade(@theme_bg, 1.2);
  color: @theme_fg;
  border: 1px solid shade(@theme_bg, 1.5);
}

.thunar .path-bar button:hover {
  background-color: shade(@theme_primary, 2.0);
}

.thunar .path-bar button:checked {
  background-color: @theme_primary;
  color: @theme_selected_fg;
}

/* ── Columnas de detalles ───────────────── */
treeview {
  background-color: @theme_bg;
  color: @theme_fg;
}

treeview:selected {
  background-color: @theme_primary;
  color: @theme_selected_fg;
}

treeview:selected:backdrop {
  background-color: shade(@theme_primary, 1.3);
}

treeview header button {
  background-color: shade(@theme_bg, 1.1);
  color: @theme_fg;
  border: 1px solid shade(@theme_bg, 1.3);
}

treeview header button:hover {
  background-color: shade(@theme_bg, 1.3);
}

/* ── Toolbar ─────────────────────────────── */
.thunar toolbar {
  background-color: shade(@theme_bg, 1.1);
  border-bottom: 1px solid shade(@theme_bg, 1.3);
}

.thunar toolbar button {
  background-color: transparent;
  color: @theme_fg;
}

.thunar toolbar button:hover {
  background-color: shade(@theme_bg, 1.5);
}

/* ── Scrollbars ──────────────────────────── */
scrollbar {
  background-color: shade(@theme_bg, 1.1);
}

scrollbar slider {
  background-color: @theme_primary;
  border-radius: 6px;
  min-width: 8px;
  min-height: 8px;
}

scrollbar slider:hover {
  background-color: @theme_secondary;
}

scrollbar slider:active {
  background-color: @theme_secondary;
}

/* ── Entries (búsqueda, location) ────────── */
entry {
  background-color: shade(@theme_bg, 1.3);
  color: @theme_fg;
  border: 1px solid shade(@theme_bg, 1.5);
}

entry:focus {
  border-color: @theme_primary;
}

/* ── Menús ───────────────────────────────── */
menu {
  background-color: shade(@theme_bg, 1.1);
  color: @theme_fg;
}

menu menuitem:hover {
  background-color: @theme_primary;
  color: @theme_selected_fg;
}

/* ── Notificaciones ──────────────────────── */
tooltip {
  background-color: shade(@theme_bg, 1.3);
  color: @theme_fg;
  border: 1px solid @theme_primary;
}
EOF

    cat > "$ZSH_COLORS" << EOF
export COLOR_PRIMARY="$primary"
export COLOR_ACCENT="$secondary"
export COLOR_BG="$background"
export COLOR_FG="$foreground"
EOF

    local hex="${primary#\#}"
    local r=$((16#${hex:0:2}))
    local g=$((16#${hex:2:2}))
    local b=$((16#${hex:4:2}))
    printf '\033[38;2;%d;%d;%dm' "$r" "$g" "$b" > "$BANNER_COLOR"

    cat > "$WAYBAR_COLORS" << EOF
@define-color primary $primary;
@define-color secondary $secondary;
@define-color background rgba($bg_r, $bg_g, $bg_b, 0.95);
@define-color foreground $foreground;
@define-color foreground-alt #8a8a8a;
@define-color chip-battery $chip_battery;
@define-color chip-bluetooth $chip_bluetooth;
@define-color chip-wlan $chip_wlan;
@define-color chip-audio $chip_audio;
@define-color alert #ff4444;
@define-color disabled #555555;
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

    # Actualizar colores de agentes en opencode.jsonc
    if [[ -f "$OPENCODE_CONFIG" ]]; then
        sed -i '/"build": { "color": /s/"color": "[^"]*"/"color": "'"$primary"'"/' "$OPENCODE_CONFIG"
        sed -i '/"plan": { "color": /s/"color": "[^"]*"/"color": "'"$secondary"'"/' "$OPENCODE_CONFIG"
        sed -i '/"general": { "color": /s/"color": "[^"]*"/"color": "'"$foreground"'"/' "$OPENCODE_CONFIG"
        sed -i '/"explore": { "color": /s/"color": "[^"]*"/"color": "'"$primary"'"/' "$OPENCODE_CONFIG"
        echo "  → opencode agent colors updated"
    fi

    # Actualizar [theme.custom] en herdr/config.toml (overrides sobre el
    # tema base "terminal"). herdr no soporta un theme.name dinámico por
    # nombre de tema propio, así que solo pisamos los colores de override.
    # green/red/yellow salen de los colores de estado semánticos de cada
    # theme.json (status_ok/status_warn/status_error), no de una paleta
    # fija — así combinan con el tema activo en vez de quedar hardcodeados.
    if [[ -f "$HERDR_CONFIG" ]]; then
        sed -i \
            -e "s|^sidebar_bg = .*|sidebar_bg = \"$background\"|" \
            -e "s|^active_row_bg = .*|active_row_bg = \"$chip_bluetooth\"|" \
            -e "s|^selection_bg = .*|selection_bg = \"$secondary\"|" \
            -e "s|^accent = .*|accent = \"$primary\"|" \
            -e "s|^blue = .*|blue = \"$chip_audio\"|" \
            -e "s|^green = .*|green = \"$status_ok\"|" \
            -e "s|^red = .*|red = \"$status_error\"|" \
            -e "s|^yellow = .*|yellow = \"$status_warn\"|" \
            "$HERDR_CONFIG"
        echo "  → herdr theme.custom updated"
    fi

    cp "$theme_dir/theme.json" "$CURRENT_THEME_FILE"
}

_set_wallpaper_direct() {
    local wallpaper="$1"
    if [[ ! -f "$wallpaper" ]]; then
        return 1
    fi

    # Hyprland: wallpaper via hyprpaper IPC
    if [ -n "$HYPRLAND_INSTANCE_SIGNATURE" ]; then
        if ! pgrep -x hyprpaper &>/dev/null; then
            hyprpaper &
            sleep 0.3
        fi
        hyprctl hyprpaper wallpaper ",$wallpaper" 2>/dev/null || true
        return 0
    fi

    # En X11: feh usa _XROOTPMAP_ID, es directo al server X11 (~50ms)
    # En Wayland: feh no funciona, así que lo saltamos
    if [ "$XDG_SESSION_TYPE" != "wayland" ] && command -v feh &>/dev/null; then
        feh --bg-fill "$wallpaper" 2>/dev/null && return 0
    fi

    # Wayland o sin feh: Qtile set_wallpaper directo sin reload_config
    # Qtile Wayland usa Cairo + wlr-layer-shell para pintar el wallpaper
    if pgrep -x qtile &>/dev/null; then
        qtile cmd-obj -o screen 0 -f set_wallpaper -a "$wallpaper" -a "fill" 2>/dev/null
        qtile cmd-obj -o screen 1 -f set_wallpaper -a "$wallpaper" -a "fill" 2>/dev/null
    fi
}

reload_components() {
    if command -v herdr &>/dev/null; then
        herdr server reload-config &>/dev/null || true
    fi

    if command -v kitty &>/dev/null; then
        if [[ -f "$KITTY_COLORS" ]]; then
            kitty @ set-colors --all -c "$KITTY_COLORS" 2>/dev/null || true
        fi
    fi

    if [ "$XDG_SESSION_TYPE" = "wayland" ]; then
        bash "$HOME/.config/waybar/launch.sh" 2>/dev/null || true
    fi

    # Forzar refresh de Thunar si está abierto
    if pgrep -x thunar &>/dev/null; then
        thunar -q 2>/dev/null || true
    fi

    # Recargar Hyprland wallpaper si es necesario
    if [ -n "$HYPRLAND_INSTANCE_SIGNATURE" ]; then
        # Releer hyprpaper.conf y recargar
        if pgrep -x hyprpaper &>/dev/null; then
            pkill hyprpaper 2>/dev/null || true
            sleep 0.1
        fi
        hyprpaper &
        sleep 0.2
        local wallpaper
        wallpaper=$(jq -r '.wallpaper // empty' "$CURRENT_THEME_FILE" 2>/dev/null)
        if [[ -n "$wallpaper" && -f "$wallpaper" ]]; then
            hyprctl hyprpaper wallpaper ",$wallpaper" 2>/dev/null || true
        fi
    fi
}

apply_theme() {
    local theme_name=$1
    local theme_dir=$(load_theme "$theme_name")
    local display_name=$(jq -r '.name' "$theme_dir/theme.json")

    echo "Aplicando tema: $display_name"

    apply_theme_config "$theme_name" "$theme_dir"

    # Wallpaper directo (feh si está instalado, fallback a Qtile set_wallpaper)
    local wallpaper=$(jq -r '.wallpaper' "$theme_dir/theme.json")
    if [[ -n "$wallpaper" && -f "$wallpaper" ]]; then
        _set_wallpaper_direct "$wallpaper"
    fi

    reload_components

    if [ "$XDG_SESSION_TYPE" != "wayland" ]; then
        bash ~/.config/polybar/launch.sh 2>/dev/null || true
    fi
    notify-send "Tema aplicado" "$display_name" -i dialog-information 2>/dev/null || true

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