#===============================================================================
# Libreria comun para scripts de instalacion
#===============================================================================

RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; BLUE='\033[0;34m'; CYAN='\033[0;36m'; NC='\033[0m'

log()  { echo -e "${GREEN}[INFO]${NC} $1"; }
warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
error(){ echo -e "${RED}[ERROR]${NC} $1"; exit 1; }
info() { echo -e "${CYAN}[...]${NC} $1"; }
header() { echo -e "\n${BLUE}════════════════════════════════════════════════════════════${NC}"; echo -e "${BLUE}  $1${NC}"; echo -e "${BLUE}════════════════════════════════════════════════════════════${NC}"; }

check_arch() {
    if [ ! -f /etc/arch-release ]; then
        error "Este script es solo para Arch Linux"
    fi
}

detect_dotfiles_dir() {
    if [ -n "${DOTFILES_DIR:-}" ] && [ -d "$DOTFILES_DIR" ]; then
        echo "$DOTFILES_DIR"
    elif [ -d "$HOME/dotfiles/.git" ]; then
        echo "$HOME/dotfiles"
    elif [ -d "$HOME/.dotfiles/.git" ]; then
        echo "$HOME/.dotfiles"
    else
        local script_dir
        script_dir="$(cd "$(dirname "${BASH_SOURCE[1]:-$0}")/../../.." && pwd 2>/dev/null)"
        if [ -d "$script_dir/.git" ]; then
            echo "$script_dir"
        else
            echo "$HOME/dotfiles"
        fi
    fi
}

stow_config() {
    local dir="$1"
    local dotfiles_dir
    dotfiles_dir="$(detect_dotfiles_dir)"
    if ! command -v stow &>/dev/null; then
        sudo pacman -S --noconfirm stow
    fi
    if [ -d "$dotfiles_dir/$dir" ]; then
        cd "$dotfiles_dir"
        stow -t "$HOME/.config" "$dir"
        log "✓ Symlink creado: ~/.config/$dir"
    else
        warn "Directorio $dir no encontrado en $dotfiles_dir"
    fi
}

install_pacman_pkg() {
    local pkg="$1"
    if pacman -Q "$pkg" &>/dev/null; then
        log "✓ $pkg ya instalado"
    else
        info "Instalando $pkg..."
        sudo pacman -S --noconfirm "$pkg"
        log "✓ $pkg instalado"
    fi
}

install_yay_pkg() {
    local pkg="$1"
    if ! command -v yay &>/dev/null; then
        warn "yay no disponible, salteando $pkg"
        return 1
    fi
    if yay -Q "$pkg" &>/dev/null; then
        log "✓ $pkg ya instalado"
    else
        info "Instalando $pkg desde AUR..."
        yay -S --noconfirm "$pkg" && log "✓ $pkg instalado" || warn "Fallo al instalar $pkg"
    fi
}
