#!/bin/bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/lib/common.sh"

DEPS=(git ripgrep fd wl-clipboard xsel nodejs npm python python-pip lua luarocks)

main() {
    check_arch
    header "NEOVIM + LAZYVIM"
    install_pacman_pkg "neovim"
    for dep in "${DEPS[@]}"; do install_pacman_pkg "$dep"; done

    if [ -d "$HOME/.config/nvim" ] && [ ! -L "$HOME/.config/nvim" ]; then
        mv "$HOME/.config/nvim" "$HOME/.config/nvim.backup.$(date +%Y%m%d_%H%M%S)"
    fi

    local dotfiles_dir
    dotfiles_dir="$(detect_dotfiles_dir)"
    if [ -d "$dotfiles_dir/lazy-nvim" ]; then
        rm -rf "$HOME/.config/nvim"
        cd "$dotfiles_dir" && stow -t "$HOME/.config" lazy-nvim
        log "Config personalizada de LazyVim enlazada"
    else
        git clone https://github.com/LazyVim/starter "$HOME/.config/nvim"
        rm -rf "$HOME/.config/nvim/.git"
        log "LazyVim starter instalado"
    fi

    npm install -g tree-sitter-cli 2>/dev/null || warn "tree-sitter-cli no instalado"
    pip3 install --user pynvim 2>/dev/null || warn "pynvim no instalado"
    log "Neovim listo. Abri nvim para instalar plugins."
}
main "$@"
