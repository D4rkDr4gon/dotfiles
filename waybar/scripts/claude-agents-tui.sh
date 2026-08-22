#!/usr/bin/env bash
# TUI de gestion de agentes IA (Claude Code / opencode) — estilo dashboard
# (paneles finos + medidores de barras, en la linea de btop).
#
# Se lanza desde el modulo waybar "custom/claude-agents" dentro de una
# ventanita flotante de Kitty, anclada arriba a la derecha
# (ver qtile/modules/hooks.py: float_widgets).

CACHE="$HOME/.claude/usage-cache.json"
THEME_FILE="$HOME/dotfiles/qtile/current_theme.json"
CW=62   # ancho de contenido del panel (entre los bordes izq/der)

# --- Color primario del tema activo ---------------------------------------
PRIMARY="#c62828"
if [ -f "$THEME_FILE" ]; then
    P=$(jq -r '.primary // empty' "$THEME_FILE" 2>/dev/null)
    [ -n "$P" ] && PRIMARY="$P"
fi

hex_to_ansi() {
    local hex="${1#\#}"
    local r=$((16#${hex:0:2})) g=$((16#${hex:2:2})) b=$((16#${hex:4:2}))
    printf '\033[38;2;%d;%d;%dm' "$r" "$g" "$b"
}

# Nota: estas variables deben quedar con el byte ESC real (comillas $'...'),
# no con el texto literal "\033[..." — de lo contrario se ven como texto.
C_PRIMARY=$(hex_to_ansi "$PRIMARY")
RESET=$'\033[0m'
BOLD=$'\033[1m'
DIM=$'\033[2m'
GREEN=$'\033[32m'
YELLOW=$'\033[33m'
RED=$'\033[31m'

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

strip_ansi() { printf '%s' "$1" | sed -r 's/\x1B\[[0-9;]*[a-zA-Z]//g'; }

# Imprime una fila de contenido dentro del panel, con padding correcto
# aunque el contenido traiga codigos ANSI.
row() {
    local content="$1"
    local visible pad
    visible=$(strip_ansi "$content")
    pad=$((CW - 2 - ${#visible}))
    [ "$pad" -lt 0 ] && pad=0
    printf '%s│%s %s%*s %s│%s\n' "$C_PRIMARY" "$RESET" "$content" "$pad" '' "$C_PRIMARY" "$RESET"
}

blank_row() { row ""; }

top_border() {
    local label=" AGENTES IA "
    local dashes=$((CW - ${#label} - 1))
    [ "$dashes" -lt 0 ] && dashes=0
    printf '%s┌─%s%s┐%s\n' "$C_PRIMARY$BOLD" "$label" "$(repeat "$dashes" '─')" "$RESET"
}

mid_border() {
    printf '%s├%s┤%s\n' "$C_PRIMARY" "$(repeat "$CW" '─')" "$RESET"
}

bottom_border() {
    # Sin \n final a propósito: en una terminal de exactamente 13 filas,
    # el \n de la última línea fuerza un scroll de 1 (el cursor pasa de la
    # última fila a una que no existe) y eso empuja el top_border fuera de
    # vista. Sin el salto de línea el cursor queda sobre esta misma fila.
    printf '%s└%s┘%s' "$C_PRIMARY" "$(repeat "$CW" '─')" "$RESET"
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

    top_border
    blank_row
    row "$(paint "$BOLD" "suscripcion claude code")"
    row "$(meter "5h" "$five" "$five_detail")"
    row "$(meter "7d" "$seven" "$seven_detail")"
    blank_row
    row "$(paint "$BOLD" "$ctx_label")"
    row "$(meter "ctx" "$ctx" "ultima sesion")"
    blank_row
    if [ -n "$updated" ]; then
        row "$(paint "$DIM" "act. $updated")"
    else
        row "$(paint "$DIM" "sin datos aun — se registra al usar Claude Code")"
    fi
    mid_border
    row "$(button c 'claude code')  $(button o 'opencode')  $(button r 'refrescar')"
    bottom_border
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
