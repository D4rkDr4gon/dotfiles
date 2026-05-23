#!/usr/bin/env bash

VPN_NAME="ARCH-CH-US-3"

if nmcli connection show --active 2>/dev/null | grep -q "$VPN_NAME"; then
    echo "󰦝"
else
    echo "󰦞"
fi
