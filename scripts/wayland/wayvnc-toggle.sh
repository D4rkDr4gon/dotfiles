#!/bin/bash
# =============================================================================
# wayvnc-toggle.sh — Levanta/baja wayvnc bajo demanda para usar la tablet
#                     (Xiaomi Redmi Pad SE) como monitor secundario táctil.
# =============================================================================
# Uso:
#   wayvnc-toggle.sh on    -> crea output headless virtual "VNC-1" extendido,
#                              lo mueve a la derecha del monitor físico,
#                              arranca wayvnc bindeado a la IP de la LAN
#   wayvnc-toggle.sh off   -> mata wayvnc y destruye el output headless
#   wayvnc-toggle.sh status
#
# Requiere: wayvnc, hyprctl, jq
# =============================================================================
set -u

CONFIG="$HOME/dotfiles/wayvnc/config"
PIDFILE="${XDG_RUNTIME_DIR:-/tmp}/wayvnc.pid"
LOGFILE="$HOME/.local/state/wayvnc.log"
IFACE="wlan0"
OUTPUT_NAME="HEADLESS-1"   # nombre lógico que asigna Hyprland al crear el headless
VNC_OUTPUT_ALIAS="VNC-1"   # nombre visible que le damos
RES="2000x1200"            # resolución aprox. Redmi Pad SE 8.7" (ajustar si hace falta)
mkdir -p "$(dirname "$LOGFILE")"

get_lan_ip() {
    ip -4 -br addr show "$IFACE" 2>/dev/null | awk '{print $3}' | cut -d/ -f1
}

status() {
    if [ -f "$PIDFILE" ] && kill -0 "$(cat "$PIDFILE")" 2>/dev/null; then
        echo "wayvnc activo (PID $(cat "$PIDFILE")) en $(get_lan_ip):5900"
        return 0
    else
        echo "wayvnc inactivo"
        return 1
    fi
}

start() {
    if status >/dev/null 2>&1; then
        echo "wayvnc ya está corriendo."
        status
        return 0
    fi

    local ip
    ip=$(get_lan_ip)
    if [ -z "$ip" ]; then
        echo "ERROR: no se detectó IP en $IFACE. ¿Estás conectado a la LAN/WiFi?" >&2
        return 1
    fi

    # Crear output headless dedicado (monitor extendido virtual para la tablet)
    if ! hyprctl monitors | grep -q "$OUTPUT_NAME"; then
        hyprctl output create headless "$OUTPUT_NAME" >/dev/null
        sleep 0.5
    fi
    # Setear resolución y posicionarlo a la derecha del monitor principal (eDP-1)
    hyprctl keyword monitor "$OUTPUT_NAME,$RES@60,auto-right,1" >/dev/null

    echo "Iniciando wayvnc en $ip:5900 (output $OUTPUT_NAME)..."
    nohup wayvnc -C "$CONFIG" -o "$OUTPUT_NAME" "$ip" 5900 \
        >>"$LOGFILE" 2>&1 &
    echo $! > "$PIDFILE"
    sleep 1

    if kill -0 "$(cat "$PIDFILE")" 2>/dev/null; then
        echo "wayvnc arriba. Conectate desde la tablet a: $ip:5900"
        echo "Usuario: lcampassi | Password: ver ~/dotfiles/wayvnc/config"
    else
        echo "ERROR: wayvnc no arrancó, revisá $LOGFILE" >&2
        rm -f "$PIDFILE"
        return 1
    fi
}

stop() {
    if [ -f "$PIDFILE" ]; then
        kill "$(cat "$PIDFILE")" 2>/dev/null
        rm -f "$PIDFILE"
    else
        pkill -x wayvnc 2>/dev/null
    fi

    # Destruir el output headless para que el compositor vuelva al estado normal
    if hyprctl monitors | grep -q "$OUTPUT_NAME"; then
        hyprctl output remove "$OUTPUT_NAME" >/dev/null 2>&1
    fi
    echo "wayvnc detenido y output headless removido."
}

case "${1:-}" in
    on|start)   start ;;
    off|stop)   stop ;;
    status)     status ;;
    *)          echo "Uso: $0 {on|off|status}" ; exit 1 ;;
esac
