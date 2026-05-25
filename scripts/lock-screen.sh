#!/usr/bin/env bash

LOG="/tmp/lock-screen.log"
echo "--- $(date) ---" >> "$LOG"
"$(dirname "$0")/lock-screen" >> "$LOG" 2>&1
echo "exit: $?" >> "$LOG"

notify-send -u normal -t 5000 "Bienvenido de nuevo! D4rkDr4g0n" "Todos los sistemas en linea a la espera de ordenes."
