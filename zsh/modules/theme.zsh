# ====== THEME COLORS ======

if [[ -f ~/.zsh_colors ]]; then
    source ~/.zsh_colors
fi

# ====== POWERLEVEL10K ======

# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi
# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
# NOTA: install.sh clona powerlevel10k en $HOME/.local/share/zsh/powerlevel10k
source "$HOME/.local/share/zsh/powerlevel10k/powerlevel10k.zsh-theme"