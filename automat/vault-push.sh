#!/bin/bash
set -e

# NOTA: VAULT_DIR = carpeta raiz de tu vault de Obsidian (repo git).
# Definila en ~/.zshenv; el valor de abajo es solo el default de referencia
# de la maquina original.
cd "${VAULT_DIR:-/files/Personal-Vault}"
DATE=$(date +%Y-%m-%d)
echo "Staging all changes..."
git add -A
echo "Committing..."
git commit -m "D4 - $DATE"
echo "Pushing (force)..."
git push --force
echo "✓ Push completo."
