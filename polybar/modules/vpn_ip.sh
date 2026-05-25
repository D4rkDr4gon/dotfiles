#!/usr/bin/env bash

IP=$(curl -s ifconfig.me 2>/dev/null || curl -s icanhazip.com 2>/dev/null)

if [[ -n "$IP" ]]; then
  notify-send -i network-vpn "VPN - IP Pública" "Tu IP es: $IP"
else
  notify-send -i network-error "VPN - IP Pública" "No se pudo obtener la IP"
fi
