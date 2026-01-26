# ====== ZSH HISTORY ======

# Configuración para historial persistente y compartido en Zsh
HISTSIZE=100000
SAVEHIST=100000
HISTFILE=~/.zsh_history

setopt append_history   # Añadir en lugar de sobrescribir
setopt share_history    # Compartir historial entre sesiones concurrentes
setopt inc_append_history # Añadir al archivo inmediatamente
setopt extended_history # Guardar timestamps de comandos
setopt hist_ignore_dups # Ignorar duplicados