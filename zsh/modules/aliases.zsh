# ====== THEME ======

alias theme="$DOTFILES/scripts/theme-switch.sh"

# ====== ALIAS ======

# Monitors and resolution
alias display-monitors="sh $DOTFILES/automat/display-monitors.sh"

# vim
alias vi="nvim"

# bat
alias cat='/usr/bin/bat'
alias catn='/usr/bin/cat'
alias catnl='/usr/bin/bat --paging=never'

# Apps
alias fastfetch="fastfetch --logo $HOME/.config/fastfetch/png/logo.png"
alias polybarupdate="$HOME/.config/polybar/launch.sh"
alias barupdate="$DOTFILES/scripts/barupdate.sh"
alias zshconfig="nvim ~/.zshrc"
alias logo="sh $DOTFILES/automat/launch-logo.sh"
alias threatdeck="~/.cargo/bin/ThreatDeck"

# Repo lazygit
# NOTA: estas rutas son especificas de la maquina de origen (fuera de $HOME).
# PORTFOLIO_DIR: repo del portfolio/web personal.
# VAULT_DIR: carpeta raiz de tu vault de Obsidian (el que sea que uses vos).
# Definilas en ~/.zshenv con la ruta real de tu sistema; el valor de acá abajo
# es solo el default de referencia de la maquina original, no un requisito.
alias portfolio="cd \"${PORTFOLIO_DIR:-/files/my-web}\" && lazygit"
alias vault="cd \"${VAULT_DIR:-/files/Personal-Vault}\" && lazygit"
alias dotfiles="cd $DOTFILES && lazygit"
alias airepo="cd $HOME/MY-AGENT-SKILLS/ && lazygit"

# AI & Automation
alias launchgemma="sh $DOTFILES/automat/launchgemma.sh"
alias n8nstart="sudo systemctl start n8n"
alias n8nstop="sudo systemctl stop n8n"

# System
alias top='btop'
alias venv='uv venv'
alias ischarging="cat /sys/class/power_supply/BAT0/status"
alias usbup="sudo mount /dev/sda1 /mnt/usb"
alias usbdown="sudo umount /dev/sda1"

# Terminal
alias c="clear"
alias q="exit"

# Networks
# NOTA: el nombre del perfil VPN es especifico de tu instalacion.
# Definir VPN_PROFILE en ~/.zshenv con el nombre real de tu perfil NetworkManager.
alias hosts="sudo nvim /etc/hosts"
alias vpnup="nmcli connection up \"${VPN_PROFILE:-ARCH-CH-US-3}\""
alias vpndown="nmcli connection down \"${VPN_PROFILE:-ARCH-CH-US-3}\""
alias vpnreplace="sh $DOTFILES/scripts/vpn-replace.sh"

# Lab manager (Wazuh + TheHive)
alias labo="$DOTFILES/automat/labo.sh"

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

# ====== VNC tablet (monitor secundario tactil intermitente) ======
alias vnc-on="wayvnc-toggle on"
alias vnc-off="wayvnc-toggle off"
alias vnc-status="wayvnc-toggle status"
alias monitorup="wayvnc-toggle on"
alias monitordown="wayvnc-toggle off"

# ====== OBSIDIAN ID REGISTRY ======
# NOTA: script dentro del vault de Obsidian (VAULT_DIR, ver alias "vault"
# arriba) que genera el proximo ID de nota. La subcarpeta de abajo
# (BIBLIOTECA-DE-BABEL/...) es la estructura de la maquina original; si tu
# vault organiza los scripts distinto, ajusta esta ruta a la tuya.
alias next-id="python3 \"${VAULT_DIR:-/files/Personal-Vault}/BIBLIOTECA-DE-BABEL/05-PRACTICAL-RESOURCES/01-SCRIPTS/PYTHON/next-id.py\""
