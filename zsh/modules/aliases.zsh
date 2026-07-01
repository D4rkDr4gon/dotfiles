# ====== THEME ======

alias theme='/home/lcampassi/dotfiles/scripts/theme-switch.sh'

# ====== ALIAS ======

# Monitors and resolution
alias display-monitors="sh /home/lcampassi/dotfiles/automat/display-monitors.sh"

# vim
alias vi="nvim"

# bat
alias cat='/usr/bin/bat'
alias catn='/usr/bin/cat'
alias catnl='/usr/bin/bat --paging=never'

# Apps
alias fastfetch='fastfetch --logo /home/lcampassi/.config/fastfetch/png/logo.png'
alias polybarupdate='/home/lcampassi/.config/polybar/launch.sh'
alias barupdate='/home/lcampassi/dotfiles/scripts/barupdate.sh'
alias zshconfig="nvim ~/.zshrc"
alias logo="sh /home/lcampassi/dotfiles/automat/launch-logo.sh"
alias threatdeck="~/.cargo/bin/ThreatDeck"

# Repo lazygit
alias portfolio="cd /files/my-web/ && lazygit"
alias vault="cd /files/Personal-Vault/ && lazygit"
alias dotfiles="cd /home/lcampassi/dotfiles/ && lazygit"
alias airepo="cd /home/lcampassi/MY-AGENT-SKILLS/ && lazygit"

# AI & Automation
alias launchgemma="sh /home/lcampasssi/.config/automat/launchgemma.sh"
alias n8nstart="sudo systemctl start n8n"
alias n8nstop="sudo systemctl stop n8n"

# System
alias top='btop'
alias venv='uv venv'
alias ischarging="cat /sys/class/power_supply/BAT0/status"

# Terminal
alias c="clear"
alias q="exit"

# Networks
alias hosts="sudo nvim /etc/hosts"
alias vpnup="nmcli connection up ARCH-CH-US-3"
alias vpndown="nmcli connection down ARCH-CH-US-3"
alias vpnreplace="sh /home/lcampassi/dotfiles/scripts/vpn-replace.sh"

# Lab manager (Wazuh + TheHive)
alias labo='/home/lcampassi/dotfiles/automat/labo.sh'

# Navigation
alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."
alias .....="cd ../../../.."
alias ll='/usr/bin/lsd -la --group-dirs=first'
alias la='/usr/bin/lsd -a --group-dirs=first'
alias l='/usr/bin/lsd --group-dirs=first'
alias lla='/usr/bin/lsd -lha --group-dirs=first'
alias ls='/usr/bin/lsd --group-dirs=first'

# ====== OBSIDIAN ID REGISTRY ======
alias next-id='python3 /files/Personal-Vault/Manuales/05-PRACTICAL-RESOURCES/01-SCRIPTS/PYTHON/next-id.py'
