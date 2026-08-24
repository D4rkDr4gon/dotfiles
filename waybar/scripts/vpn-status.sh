#!/usr/bin/env bash
# Modulo waybar: estado de VPN (FortiClient + ProtonVPN/WireGuard).
# Delega toda la logica a vpn_tui.py --waybar-status (modo liviano, sin
# Textual, pensado para no colgar el polling de waybar).

python3 /home/lcampassi/dotfiles/recursos/vpn/vpn_tui.py --waybar-status
