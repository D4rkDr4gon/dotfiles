#!/usr/bin/env bash

LOG="/tmp/lock-screen.log"
echo "--- $(date) ---" >> "$LOG"

if [ "$XDG_SESSION_TYPE" = "wayland" ]; then
  swaylock -f >> "$LOG" 2>&1
else
  "$(dirname "$0")/lock-screen" >> "$LOG" 2>&1
fi

echo "exit: $?" >> "$LOG"

notify-send -u normal -t 5000 "Bienvenido de nuevo! D4rkDr4g0n" "Todos los sistemas en linea a la espera de ordenes."
