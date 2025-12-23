#!/usr/bin/env sh


# Termina las instancias de la barra que ya están en ejecución

killall -q polybar


# Espera hasta que los procesos se hayan cerrado

while pgrep -u $UID -x polybar >/dev/null; do sleep 1; done


# Lanza la barra


if type "xrandr"; then

  for m in $(xrandr --query | grep " connected" | cut -d" " -f1); do

    MONITOR=$m polybar --reload example &
  done

else

  polybar --reload example &
fi