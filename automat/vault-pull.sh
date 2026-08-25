#!/bin/bash
set -e

# NOTA: VAULT_DIR = carpeta raiz de tu vault de Obsidian (repo git).
# Definila en ~/.zshenv; el valor de abajo es solo el default de referencia
# de la maquina original.
cd "${VAULT_DIR:-/files/Personal-Vault}"
echo "Pulling (force)..."
git pull --force
echo "✓ Pull completo."
