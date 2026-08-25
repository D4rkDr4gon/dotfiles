#!/bin/bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/lib/common.sh"

main() {
    check_arch
    header "ZSH + POWERLEVEL10K"

    install_pacman_pkg "zsh"

    # NOTA: zsh/modules/theme.zsh espera powerlevel10k en $HOME/powerlevel10k
    local p10k_dir="$HOME/powerlevel10k"
    if [ -d "$p10k_dir" ]; then
        cd "$p10k_dir" && git pull origin master && log "powerlevel10k actualizado"
    else
        git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$p10k_dir"
        log "powerlevel10k instalado"
    fi

    # zsh/modules/plugins.zsh espera estos dos plugins clonados en ~/.zsh/
    mkdir -p "$HOME/.zsh"
    [ -d "$HOME/.zsh/zsh-autosuggestions" ] || git clone --depth=1 https://github.com/zsh-users/zsh-autosuggestions.git "$HOME/.zsh/zsh-autosuggestions"
    [ -d "$HOME/.zsh/zsh-syntax-highlighting" ] || git clone --depth=1 https://github.com/zsh-users/zsh-syntax-highlighting.git "$HOME/.zsh/zsh-syntax-highlighting"

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
