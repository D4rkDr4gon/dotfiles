#!/bin/bash
set -e

cd ~/OneDrive/vault
DATE=$(date +%Y-%m-%d)
echo "Staging all changes..."
git add -A
echo "Committing..."
git commit -m "D4 - $DATE"
echo "Pushing (force)..."
git push --force
echo "✓ Push completo."
