#!/bin/bash
#
# vpn-replace.sh — Reemplaza configuracion de Wireguard VPN en dotfiles
#
# Uso:
#   ./vpn-replace.sh <nuevo-archivo.conf>
#
# Descripcion:
#   Importa un archivo .conf de Wireguard a NetworkManager,
#   elimina la conexion anterior, y actualiza los alias vpnup/vpndown
#   en los dotfiles para que apunten a la nueva conexion.
#
# Ejemplo:
#   ./vpn-replace.sh ~/dotfiles/recursos/PROTON/ARCH_LINUX-CH-US-3.conf
#

set -euo pipefail

OLD_CONN="wg-US-FREE-74"
ALIASES_FILE="$HOME/dotfiles/zsh/modules/aliases.zsh"
KEYBINDINGS_FILE="$HOME/dotfiles/docs/keybindings.md"
ZSH_DOCS_FILE="$HOME/dotfiles/docs/configuration/zsh.md"
PROTON_DIR="$HOME/dotfiles/recursos/PROTON"

if [ $# -ne 1 ]; then
    echo "Error: Debes pasar el archivo .conf como parametro."
    echo "Uso: $0 <archivo.conf>"
    exit 1
fi

NEW_CONF="$1"

if [ ! -f "$NEW_CONF" ]; then
    echo "Error: El archivo '$NEW_CONF' no existe."
    exit 1
fi

NEW_CONN=$(basename "$NEW_CONF" .conf)

echo "==> Nueva conexion: $NEW_CONN"
echo "==> Archivo fuente: $NEW_CONF"

# --- 1. Copiar a PROTON dir ---
echo "==> Copiando a $PROTON_DIR/"
cp "$NEW_CONF" "$PROTON_DIR/"

# --- 2. Importar a NetworkManager ---
echo "==> Importando a NetworkManager..."
sudo nmcli connection import type wireguard file "$NEW_CONF"

# --- 3. Eliminar conexion anterior ---
if nmcli connection show "$OLD_CONN" &>/dev/null; then
    echo "==> Eliminando conexion anterior: $OLD_CONN"
    sudo nmcli connection delete "$OLD_CONN"
else
    echo "==> Conexion anterior '$OLD_CONN' no encontrada, omitiendo."
fi

# --- 4. Actualizar aliases ---
echo "==> Actualizando aliases en $ALIASES_FILE..."
sed -i "s/$OLD_CONN/$NEW_CONN/g" "$ALIASES_FILE"

# --- 5. Actualizar documentacion ---
if [ -f "$KEYBINDINGS_FILE" ]; then
    echo "==> Actualizando $KEYBINDINGS_FILE..."
    sed -i "s/$OLD_CONN/$NEW_CONN/g" "$KEYBINDINGS_FILE"
fi

if [ -f "$ZSH_DOCS_FILE" ]; then
    echo "==> Actualizando $ZSH_DOCS_FILE..."
    sed -i "s/$OLD_CONN/$NEW_CONN/g" "$ZSH_DOCS_FILE"
fi

echo ""
echo "=== Hecho ==="
echo "VPN '$NEW_CONN' configurada y activa."
echo "Usa: vpnup   (para conectar)"
echo "     vpndown (para desconectar)"
