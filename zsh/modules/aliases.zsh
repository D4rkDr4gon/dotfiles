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
alias zshconfig="nvim ~/.zshrc"
alias logo="sh /home/lcampassi/dotfiles/automat/launch-logo.sh"

# AI & Automation
alias launchgemma="sh /home/lcampasssi/.config/automat/launchgemma.sh"
alias n8nstart="sudo systemctl start n8n"
alias n8nstop="sudo systemctl stop n8n"

# System
alias top='btop'

# Terminal
alias c="clear"
alias q="exit"

# Networks
alias hosts="sudo nvim /etc/hosts"
alias vpnup="nmcli connection up wg-US-FREE-74"
alias vpndown="nmcli connection down wg-US-FREE-74"

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
