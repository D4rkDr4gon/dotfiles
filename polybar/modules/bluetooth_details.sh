#!/bin/bash

CONNECTED_DEVICES=$(bluetoothctl devices Connected | grep Device | cut -d ' ' -f 2)

if [ -n "$CONNECTED_DEVICES" ]; then
    # Muestra el alias del primer dispositivo conectado
    ALIAS=$(bluetoothctl info $CONNECTED_DEVICES | grep "Alias" | cut -d ' ' -f 2-)
    echo "$ALIAS"
else
    # Si no hay nada, no muestra nada (para que no se duplique la X)
    echo ""
fi
