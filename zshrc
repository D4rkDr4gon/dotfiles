# Configuración para historial persistente y compartido en Zsh
HISTSIZE=100000
SAVEHIST=100000
HISTFILE=~/.zsh_history

setopt append_history   # Añadir en lugar de sobrescribir
setopt share_history    # Compartir historial entre sesiones concurrentes
setopt inc_append_history # Añadir al archivo inmediatamente
setopt extended_history # Guardar timestamps de comandos
setopt hist_ignore_dups # Ignorar duplicados


# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi


# Extract nmap information
function extractPorts(){
	ports="$(cat $1 | grep -oP '\d{1,5}/open' | awk '{print $1}' FS='/' | xargs | tr ' ' ',')"
	ip_address="$(cat $1 | grep -oP '\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}' | sort -u | head -n 1)"
	echo -e "\n[*] Extracting information...\n" > extractPorts.tmp
	echo -e "\t[*] IP Address: $ip_address"  >> extractPorts.tmp
	echo -e "\t[*] Open ports: $ports\n"  >> extractPorts.tmp
	echo $ports | tr -d '\n' | xclip -sel clip
	echo -e "[*] Ports copied to clipboard\n"  >> extractPorts.tmp
	cat extractPorts.tmp; rm extractPorts.tmp
}

# plugins
source /home/lcampassi/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh
source /home/lcampassi/.zsh/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

alias ll='/usr/bin/lsd -la --group-dirs=first'
alias la='/usr/bin/lsd -a --group-dirs=first'
alias l='/usr/bin/lsd --group-dirs=first'
alias lla='/usr/bin/lsd -lha --group-dirs=first'
alias ls='/usr/bin/lsd --group-dirs=first'
alias cat='/usr/bin/bat'
alias catn='/usr/bin/cat'
alias catnl='/usr/bin/bat --paging=never'
alias fastfetch='fastfetch --logo /home/lcampassi/.config/fastfetch/png/logo.png'
alias polybarupdate='/home/lcampassi/.config/polybar/launch.sh'
alias top='btop'
alias zshconfig="nvim ~/.zshrc"
alias vi="nvim"
alias launchgemma="bash /home/lcampasssi/.config/automat/launchgemma.sh"
alias logo="sh /home/lcampassi/dotfile/automat/launch-logo.sh"

# on zsh start
autoload -U colors && colors

echo -e "$fg[red]
    ====================================================================================
    ██████╗  █████╗ ██████╗ ██╗  ██╗██████╗ ██████╗  █████╗  ██████╗  ██████╗ ███╗   ██╗
    ██╔══██╗██╔══██╗██╔══██╗██║ ██╔╝██╔══██╗██╔══██╗██╔══██╗██╔════╝ ██╔═══██╗████╗  ██║
    ██║  ██║███████║██████╔╝█████╔╝ ██║  ██║██████╔╝███████║██║  ███╗██║   ██║██╔██╗ ██║
    ██║  ██║██╔══██║██╔══██╗██╔═██╗ ██║  ██║██╔══██╗██╔══██║██║   ██║██║   ██║██║╚██╗██║
    ██████╔╝██║  ██║██║  ██║██║  ██╗██████╔╝██║  ██║██║  ██║╚██████╔╝╚██████╔╝██║ ╚████║
    ╚═════╝ ╚═╝  ╚═╝╚═╝  ╚═╝╚═╝  ╚═╝╚═════╝ ╚═╝  ╚═╝╚═╝  ╚═╝ ╚═════╝  ╚═════╝ ╚═╝  ╚═══╝
    ----------- $reset_color >>> Lucciano Campassi - Cybersecurity Specialist <<< $fg[red] -----------------
    ====================================================================================
$reset_color"

# cat /home/lcampassi/dotfiles/recursos/tux.txt

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source /home/lcampassi/.p10k.zsh
source /home/lcampassi/powerlevel10k/powerlevel10k.zsh-theme

# opencode
export PATH=/home/lcampassi/.opencode/bin:$PATH
