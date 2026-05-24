#!/bin/bash
# Notification Center - Rofi + Dunst
# Muestra el historial de notificaciones de Dunst en Rofi.
# Al seleccionar una, la cierra del historial.

ROFI_THEME="$HOME/.config/rofi/theme.rasi"

COUNT=$(dunstctl count history 2>/dev/null)

if [ "$COUNT" -eq 0 ] 2>/dev/null; then
    rofi -e "No notifications" -theme "$ROFI_THEME"
    exit 0
fi

entries=()
ids=()

while IFS=$'\t' read -r id summary body; do
    entries+=("$summary ${body:+— $body}")
    ids+=("$id")
done < <(dunstctl history | jq -r '
    .data[][] |
    [.id.data, .summary.data, .body.data] |
    @tsv
' 2>/dev/null)

if [ ${#entries[@]} -eq 0 ]; then
    rofi -e "No notifications" -theme "$ROFI_THEME"
    exit 0
fi

selected=$(printf '%s\n' "${entries[@]}" | rofi -dmenu -i \
    -p "Notifications ($COUNT)" \
    -theme "$ROFI_THEME" \
    -no-custom \
    -format i)

if [[ -n "$selected" && "$selected" =~ ^[0-9]+$ ]] && [ "$selected" -lt "${#ids[@]}" ]; then
    dunstctl close "${ids[$selected]}"
fi
