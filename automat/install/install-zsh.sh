#!/bin/bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/lib/common.sh"

main() {
    check_arch
    header "ZSH + POWERLEVEL10K"

    install_pacman_pkg "zsh"

    local p10k_dir="$HOME/.local/share/zsh/powerlevel10k"
    mkdir -p "$HOME/.local/share/zsh"
    if [ -d "$p10k_dir" ]; then
        cd "$p10k_dir" && git pull origin master && log "powerlevel10k actualizado"
    else
        git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$p10k_dir"
        log "powerlevel10k instalado"
    fi

    # Stow zsh config directory
    local dotfiles_dir
    dotfiles_dir="$(detect_dotfiles_dir)"
    if [ -d "$dotfiles_dir/zsh" ]; then
        cd "$dotfiles_dir"
        stow -t "$HOME/.config" zsh
        ln -sf "$dotfiles_dir/zsh/zshrc" "$HOME/.zshrc"
        log "Symlinks de zsh creados"
    fi

    if [ "$SHELL" != "/bin/zsh" ] && [ "$SHELL" != "/usr/bin/zsh" ]; then
        chsh -s /bin/zsh && log "Shell cambiado a zsh" || warn "Cambiar shell manual: chsh -s /bin/zsh"
    else
        log "Shell ya es zsh"
    fi
    log "Zsh + powerlevel10k listo"
}
main "$@"
