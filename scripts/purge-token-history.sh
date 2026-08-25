#!/bin/bash
# Purga el token de Obsidian expuesto (7363b036...fadf8d) de TODO el historial
# de git, en todas las ramas. Requiere git-filter-repo.
#
# ADVERTENCIA:
#   - Reescribe TODOS los commit hashes del repo a partir de donde aparece
#     el token. Cualquier otro clone/fork queda desincronizado.
#   - Hay que forzar el push despues (git push --force --all y --tags).
#   - El repo es PUBLICO (github.com/D4rkDr4gon/dotfiles) y el token YA fue
#     scrapeado potencialmente por bots -- esto NO reemplaza rotar la key,
#     solo evita que siga visible en el historial de aca en mas.
#
# Uso:
#   1. Rotar la API key real en el plugin obsidian-local-rest-api primero.
#   2. Actualizar OBSIDIAN_API_KEY en ~/.zshenv con la key nueva.
#   3. Instalar git-filter-repo: sudo pacman -S git-filter-repo  (o pip install git-filter-repo)
#   4. Correr este script desde la raiz del repo: bash scripts/purge-token-history.sh
#   5. Revisar que todo compile/funcione, despues: git push --force --all && git push --force --tags
#   6. Avisar a cualquiera que tenga un clone que debe re-clonar (no pull/rebase).

set -euo pipefail

if ! command -v git-filter-repo &>/dev/null; then
    echo "ERROR: git-filter-repo no esta instalado."
    echo "  Arch: sudo pacman -S git-filter-repo"
    echo "  o:    pip install --user git-filter-repo"
    exit 1
fi

TOKEN="***TOKEN_REVOCADO***"

echo "Esto va a reescribir TODO el historial de git de este repo."
echo "Repo remoto: $(git remote get-url origin 2>/dev/null || echo '(sin remoto)')"
read -p "Escribi 'si' para confirmar: " confirm
[ "$confirm" = "si" ] || { echo "Cancelado."; exit 1; }

git filter-repo --replace-text <(echo "$TOKEN==>***ROTATED_TOKEN_REMOVED***") --force

echo ""
echo "Listo. Verificacion:"
if git log -p --all | grep -q "$TOKEN"; then
    echo "  ADVERTENCIA: el token todavia aparece en el historial."
else
    echo "  OK: el token ya no aparece en ningun commit."
fi

echo ""
echo "Proximo paso (no automatico, revisa antes):"
echo "  git push --force --all"
echo "  git push --force --tags"
