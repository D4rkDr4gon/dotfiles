#!/usr/bin/env bash
# TUI de gestion de agentes IA (Claude Code / opencode) — dashboard con
# medidores de barras (estilo btop).
#
# Se lanza desde el modulo waybar "custom/claude-agents" dentro de una
# ventanita flotante de Kitty, anclada arriba a la derecha
# (ver qtile/modules/hooks.py: float_widgets).
#
# Regla "Flat Minimal" (ver docs/design-system.md): sin cajas ni marcos.
# Antes este panel se dibujaba entero a mano con box-drawing (┌─┐│└─┘) —
# ahora es texto plano jerárquico (título en negrita, filas ícono/label,
# un separador sutil de 1 línea) igual que el resto del sistema.

CACHE="$HOME/.claude/usage-cache.json"
THEME_FILE="$HOME/dotfiles/qtile/current_theme.json"
CW=62   # ancho de referencia para el separador y el padding de filas

# --- Colores del tema activo -----------------------------------------------
# Antes solo se leía .primary; ahora se lee la paleta completa para que
# estados/superficies también sigan al tema (no solo el acento).
PRIMARY="#c62828"; FOREGROUND="#c5c8c6"; CHIP_BATTERY="#1a1515"
STATUS_OK="#5cb85c"; STATUS_WARN="#f9a825"; STATUS_ERROR="#ff1744"
if [ -f "$THEME_FILE" ]; then
    P=$(jq -r '.primary // empty' "$THEME_FILE" 2>/dev/null); [ -n "$P" ] && PRIMARY="$P"
    F=$(jq -r '.foreground // empty' "$THEME_FILE" 2>/dev/null); [ -n "$F" ] && FOREGROUND="$F"
    CB=$(jq -r '.chip_battery // empty' "$THEME_FILE" 2>/dev/null); [ -n "$CB" ] && CHIP_BATTERY="$CB"
    SO=$(jq -r '.status_ok // empty' "$THEME_FILE" 2>/dev/null); [ -n "$SO" ] && STATUS_OK="$SO"
    SW=$(jq -r '.status_warn // empty' "$THEME_FILE" 2>/dev/null); [ -n "$SW" ] && STATUS_WARN="$SW"
    SE=$(jq -r '.status_error // empty' "$THEME_FILE" 2>/dev/null); [ -n "$SE" ] && STATUS_ERROR="$SE"
fi

hex_to_ansi() {
    local hex="${1#\#}"
    local r=$((16#${hex:0:2})) g=$((16#${hex:2:2})) b=$((16#${hex:4:2}))
    printf '\033[38;2;%d;%d;%dm' "$r" "$g" "$b"
}

# Nota: estas variables deben quedar con el byte ESC real (comillas $'...'),
# no con el texto literal "\033[..." — de lo contrario se ven como texto.
C_PRIMARY=$(hex_to_ansi "$PRIMARY")
C_FOREGROUND=$(hex_to_ansi "$FOREGROUND")
C_SURFACE=$(hex_to_ansi "$CHIP_BATTERY")
GREEN=$(hex_to_ansi "$STATUS_OK")
YELLOW=$(hex_to_ansi "$STATUS_WARN")
RED=$(hex_to_ansi "$STATUS_ERROR")
RESET=$'\033[0m'
BOLD=$'\033[1m'
DIM=$'\033[2m'

# Envuelve texto en un color y lo cierra con reset.
paint() { printf '%s%s%s' "$1" "$2" "$RESET"; }

color_for_pct() {
    local pct="$1"
    if [ -z "$pct" ]; then
        printf '%s' "$DIM"
    elif [ "$pct" -ge 80 ] 2>/dev/null; then
        printf '%s' "$RED"
    elif [ "$pct" -ge 50 ] 2>/dev/null; then
        printf '%s' "$YELLOW"
    else
        printf '%s' "$GREEN"
    fi
}

# Repite un caracter (soporta multibyte, a diferencia de `tr`).
repeat() { printf '%*s' "$1" '' | sed "s/ /$2/g"; }

# Fila de contenido con margen izquierdo fijo (sin bordes laterales).
row() { printf '  %s\n' "$1"; }

blank_row() { row ""; }

header() {
    printf '\n  %s\n\n' "$(paint "$BOLD$C_PRIMARY" "AGENTES IA")"
}

# Separador sutil de 1 línea — superficie tenue, no el acento del tema
# (regla Flat Minimal: el acento nunca es una línea decorativa suelta).
divider() {
    printf '  %s\n' "$(paint "$C_SURFACE" "$(repeat "$CW" '─')")"
}

# Medidor tipo btop: etiqueta + barra de bloques + porcentaje + detalle.
meter() {
    local label="$1" pct="$2" detail="$3"
    local blocks=30 filled empty pctfmt c bar

    if [ -z "$pct" ]; then
        bar="$(paint "$DIM" "$(repeat "$blocks" '·')")"
        printf '%-5s %s   %s' "$label" "$bar" "$(paint "$DIM" "sin datos")"
        return
    fi

    pctfmt=$(printf '%.0f' "$pct")
    filled=$((pctfmt * blocks / 100))
    [ "$filled" -gt "$blocks" ] && filled=$blocks
    empty=$((blocks - filled))
    c=$(color_for_pct "$pctfmt")
    bar="$(paint "$c" "$(repeat "$filled" '█')")$(paint "$DIM" "$(repeat "$empty" '░')")"

    printf '%-5s %s %s' "$label" "$bar" "$(paint "$c" "$(printf '%3s%%' "$pctfmt")")"
    [ -n "$detail" ] && printf '  %s' "$(paint "$DIM" "$detail")"
}

fmt_reset() { date -d "@$1" '+%H:%M %a' 2>/dev/null; }

# Boton estilo "chip" para el footer, ej: [c] claude code
button() {
    local key="$1" label="$2"
    printf '%s[%s]%s %s' "$DIM" "$(paint "$BOLD$C_PRIMARY" "$key")" "$DIM$RESET" "$label"
}

render() {
    clear
    local five seven ctx five_reset seven_reset session_dir updated
    five=""; seven=""; ctx=""; five_reset=""; seven_reset=""; session_dir=""; updated=""
    if [ -f "$CACHE" ]; then
        five=$(jq -r '.five_hour_pct // empty' "$CACHE" 2>/dev/null)
        seven=$(jq -r '.seven_day_pct // empty' "$CACHE" 2>/dev/null)
        ctx=$(jq -r '.context_pct // empty' "$CACHE" 2>/dev/null)
        five_reset=$(jq -r '.five_hour_reset // empty' "$CACHE" 2>/dev/null)
        seven_reset=$(jq -r '.seven_day_reset // empty' "$CACHE" 2>/dev/null)
        session_dir=$(jq -r '.session_dir // empty' "$CACHE" 2>/dev/null)
        updated=$(jq -r '.updated_at // empty' "$CACHE" 2>/dev/null)
    fi

    local five_detail="" seven_detail="" ctx_label="contexto"
    [ -n "$five_reset" ] && five_detail="renueva $(fmt_reset "$five_reset")"
    [ -n "$seven_reset" ] && seven_detail="renueva $(fmt_reset "$seven_reset")"
    [ -n "$session_dir" ] && ctx_label="contexto · $session_dir"

    header
    row "$(paint "$BOLD$C_FOREGROUND" "suscripcion claude code")"
    row "$(meter "5h" "$five" "$five_detail")"
    row "$(meter "7d" "$seven" "$seven_detail")"
    blank_row
    row "$(paint "$BOLD$C_FOREGROUND" "$ctx_label")"
    row "$(meter "ctx" "$ctx" "ultima sesion")"
    blank_row
    if [ -n "$updated" ]; then
        row "$(paint "$DIM" "act. $updated")"
    else
        row "$(paint "$DIM" "sin datos aun — se registra al usar Claude Code")"
    fi
    divider
    row "$(button c 'claude code')  $(button o 'opencode')  $(button r 'refrescar')"
}

cleanup() { printf '%s' "$RESET"; clear; }
trap cleanup EXIT

while true; do
    render
    IFS= read -rsn1 key
    case "$key" in
        c|C) exec claude ;;
        o|O) exec opencode ;;
        r|R) continue ;;
        q|Q|$'\e') exit 0 ;;
        *) continue ;;
    esac
done
