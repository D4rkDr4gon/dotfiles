#!/usr/bin/env bash

VPN_NAME="ARCH-CH-US-3"

if nmcli connection show --active 2>/dev/null | grep -q "$VPN_NAME"; then
    nmcli connection down "$VPN_NAME"
else
    nmcli connection up "$VPN_NAME"
fi
