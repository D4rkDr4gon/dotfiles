#!/usr/bin/env bash

LOG="/tmp/lock-screen.log"
echo "--- $(date) ---" >> "$LOG"

# Read active wallpaper from current theme
THEME_FILE="$HOME/.config/qtile/current_theme.json"
WALLPAPER=""
if command -v jq &>/dev/null && [[ -f "$THEME_FILE" ]]; then
  WALLPAPER=$(jq -r '.wallpaper' "$THEME_FILE")
fi

if [ "$XDG_SESSION_TYPE" = "wayland" ]; then
  BANNER_FILE="$HOME/dotfiles/recursos/lock-banner.txt"
  TMPDIR="${TMPDIR:-/tmp}"
  RAW="$TMPDIR/lock-screen-raw.png"
  BLUR="$TMPDIR/lock-screen-blur.png"
  FINAL="$TMPDIR/lock-screen-final.png"

  if [[ -n "$WALLPAPER" && -f "$WALLPAPER" ]]; then
    # Get screen resolution from grim
    grim "$RAW" >> "$LOG" 2>&1 || {
      echo "grim failed, falling back to basic gtklock" >> "$LOG"
      gtklock >> "$LOG" 2>&1
      echo "exit: $?" >> "$LOG"
      notify-send -u normal -t 5000 "Bienvenido de nuevo! D4rkDr4g0n" "Todos los sistemas en linea a la espera de ordenes."
      exit 0
    }
    SCREEN_RES=$(magick identify -format "%wx%h" "$RAW" 2>/dev/null)
    rm -f "$RAW"

    if [[ -n "$SCREEN_RES" ]]; then
      convert "$WALLPAPER" -resize "${SCREEN_RES}^" -gravity center -extent "$SCREEN_RES" -blur 0x8 "$BLUR" >> "$LOG" 2>&1
    else
      grim "$RAW" >> "$LOG" 2>&1
      convert "$RAW" -blur 0x8 "$BLUR" >> "$LOG" 2>&1
      rm -f "$RAW"
    fi
  else
    grim "$RAW" >> "$LOG" 2>&1 || {
      echo "grim failed, falling back to basic gtklock" >> "$LOG"
      gtklock >> "$LOG" 2>&1
      echo "exit: $?" >> "$LOG"
      notify-send -u normal -t 5000 "Bienvenido de nuevo! D4rkDr4g0n" "Todos los sistemas en linea a la espera de ordenes."
      exit 0
    }
    convert "$RAW" -blur 0x8 "$BLUR" >> "$LOG" 2>&1
    rm -f "$RAW"
  fi

  convert -background none \
    -font "Hack-Nerd-Font-Mono" -pointsize 14 \
    -fill '#bbbbbb' -gravity west \
    "label:@$BANNER_FILE" \
    "$TMPDIR/lock-screen-banner.png" >> "$LOG" 2>&1

  composite -geometry +40+40 -gravity southeast \
    "$TMPDIR/lock-screen-banner.png" "$BLUR" \
    "$FINAL" >> "$LOG" 2>&1

  gtklock -b "$FINAL" >> "$LOG" 2>&1
else
  if command -v betterlockscreen &>/dev/null; then
    if [[ -n "$WALLPAPER" && -f "$WALLPAPER" ]]; then
      betterlockscreen -u "$WALLPAPER" >> "$LOG" 2>&1
    fi
    betterlockscreen -l dim >> "$LOG" 2>&1
  elif [[ -n "$WALLPAPER" && -f "$WALLPAPER" ]]; then
    i3lock -i "$WALLPAPER" -t >> "$LOG" 2>&1
  else
    i3lock -c 000000 >> "$LOG" 2>&1
  fi
fi

echo "exit: $?" >> "$LOG"

notify-send -u normal -t 5000 "Bienvenido de nuevo! D4rkDr4g0n" "Todos los sistemas en linea a la espera de ordenes."
