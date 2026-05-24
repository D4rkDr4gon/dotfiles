#!/bin/bash
set -e

cd /files/Personal-Vault
echo "Pulling (force)..."
git pull --force
echo "✓ Pull completo."
