#!/usr/bin/env bash

# Terminar instancias previas
killall -q polybar

# Esperar a que los procesos se cierren
while pgrep -u $UID -x polybar >/dev/null; do sleep 1; done

# Lanzar la barra "example"
polybar example &

