#!/bin/bash
#===============================================================================
# D4rkDr4g0n Dotfiles - Instalador Unificado
# Una linea para instalarlos a todos:
#   bash <(curl -fsSL https://raw.githubusercontent.com/D4rkDr4g0n/dotfiles/main/install.sh)
#===============================================================================

set -euo pipefail

RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; BLUE='\033[0;34m'; CYAN='\033[0;36m'; NC='\033[0m'
log()  { echo -e "${GREEN}[INFO]${NC} $1"; }
warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
error(){ echo -e "${RED}[ERROR]${NC} $1"; exit 1; }
info() { echo -e "${CYAN}[...]${NC} $1"; }
header(){ echo -e "\n${BLUE}════════════════════════════════════════════════════════════${NC}"; echo -e "${BLUE}  $1${NC}"; echo -e "${BLUE}════════════════════════════════════════════════════════════${NC}"; }

DOTFILES_REPO="https://github.com/D4rkDr4g0n/dotfiles.git"

#===============================================================================
# DETECCION
#===============================================================================
detect_system() {
    header "DETECTANDO SISTEMA"
    if [ ! -f /etc/arch-release ]; then
        error "Este instalador es solo para Arch Linux"
    fi
    log "Arch Linux detectado"
    if [ "$EUID" -eq 0 ]; then
        error "NO ejecutes este script como root. El script usa sudo cuando es necesario."
    fi
    log "Usuario: $(whoami)"
    log "Kernel: $(uname -r)"
}

auto_detect_dotfiles() {
    if [ -d "$HOME/dotfiles/.git" ]; then
        DOTFILES_DIR="$HOME/dotfiles"
    elif [ -d "$HOME/.dotfiles/.git" ]; then
        DOTFILES_DIR="$HOME/.dotfiles"
    elif [ -d "$(dirname "$0")/.git" ]; then
        DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"
    else
        DOTFILES_DIR="$HOME/dotfiles"
    fi
    log "Dotfiles detectados en: $DOTFILES_DIR"
}

#===============================================================================
# YAY (AUR helper)
#===============================================================================
install_yay() {
    header "INSTALANDO YAY (AUR HELPER)"
    if command -v yay &>/dev/null; then
        log "yay ya instalado: $(yay --version | head -1)"
        return 0
    fi
    info "Preparando compilacion de yay..."
    local tmpdir
    tmpdir=$(mktemp -d)
    sudo pacman -S --noconfirm --needed git base-devel
    git clone https://aur.archlinux.org/yay.git "$tmpdir/yay"
    cd "$tmpdir/yay"
    makepkg -si --noconfirm
    cd "$HOME"
    rm -rf "$tmpdir"
    if command -v yay &>/dev/null; then
        log "yay instalado correctamente"
    else
        error "Fallo la instalacion de yay"
    fi
}

#===============================================================================
# PAQUETES
#===============================================================================
PACKAGES_OFFICIAL=(
    # WM y UI
    qtile python-pip python-xcffib python-cairocffi python-dbus-next python-psutil python-iwlib
    polybar picom rofi dunst nitrogen
    # Terminal y shell
    kitty zsh zoxide fzf fd ripgrep bat lsd jq yazi fastfetch btop
    # Xorg y drivers
    xorg-server xorg-xinit xf86-video-amdgpu xf86-video-ati vulkan-radeon
    # Display manager
    lightdm lightdm-gtk-greeter
    # Audio
    pipewire pipewire-pulse pipewire-alsa pipewire-jack wireplumber pavucontrol alsa-utils
    # Networking
    networkmanager nm-connection-editor iwd wireless_tools
    # Bluetooth
    bluez bluez-utils
    # Desarrollo
    git github-cli neovim python python-pip nodejs npm lua luarocks
    # Productividad
    obsidian flameshot firefox copyq discord btop thunar
    # Utilidades
    brightnessctl acpid curl wget openssh
    # Fonts
    ttf-hack-nerd ttf-jetbrains-mono-nerd ttf-font-awesome noto-fonts noto-fonts-emoji
    # Python extras para Qtile
    qtile-extras python-cffi python-wheel python-setuptools python-netaddr python-requests python-yaml python-toml python-click python-dateutil python-mpd2
    # LSPs y desarrollo
    ripgrep fd wl-clipboard xsel
    # Sistema
    stow timeshift smartmontools
)

PACKAGES_AUR=(
    spotify
    sigma-file-manager-bin
    bitwarden
    onedriver
    onlyoffice-bin
    sublime-text-4
    proton-vpn-cli
    proton-mail
    n8n
    betterlockscreen
    i3lock-color
    proton-drive-sync-bin
    libfprint-2-tod1-goodix
    libfprint-tod
    onedrive-abraunegg
)

WAYLAND_PKGS=(
    waybar swaybg swaylock
    wayland wlroots0.19 wlr-randr grim slurp swayidle
)

install_official_packages() {
    header "INSTALANDO PAQUETES OFICIALES"
    local missing=()
    for pkg in "${PACKAGES_OFFICIAL[@]}"; do
        if ! pacman -Q "$pkg" &>/dev/null; then
            missing+=("$pkg")
        fi
    done
    if [ ${#missing[@]} -eq 0 ]; then
        log "Todos los paquetes oficiales ya estan instalados"
        return 0
    fi
    info "Instalando ${#missing[@]} paquetes oficiales faltantes..."
    sudo pacman -S --noconfirm --needed "${missing[@]}"
    log "Paquetes oficiales instalados"
}

install_aur_packages() {
    header "INSTALANDO PAQUETES AUR"
    local missing=()
    for pkg in "${PACKAGES_AUR[@]}"; do
        if ! yay -Q "$pkg" &>/dev/null; then
            missing+=("$pkg")
        fi
    done
    if [ ${#missing[@]} -eq 0 ]; then
        log "Todos los paquetes AUR ya estan instalados"
        return 0
    fi
    info "Instalando ${#missing[@]} paquetes AUR faltantes..."
    yay -S --noconfirm --needed "${missing[@]}"
    log "Paquetes AUR instalados"
}

#===============================================================================
# SYMLINKS (Stow)
#===============================================================================
create_symlinks() {
    header "CREANDO SYMLINKS"
    cd "$DOTFILES_DIR"

    local base_dirs=(qtile polybar picom rofi kitty dunst fastfetch Thunar zsh automat onedrive opencode lazy-nvim)
    local stow_dirs=("${base_dirs[@]}")

    if ! $skip_wayland; then
        stow_dirs+=(waybar swaylock)
    fi

    for dir in "${stow_dirs[@]}"; do
        if [ -d "$dir" ]; then
            info "Stow: $dir -> ~/.config/$dir"
            stow -t "$HOME/.config" "$dir" 2>/dev/null || warn "No se pudo stow $dir (puede ya existir)"
        else
            warn "Directorio $dir no encontrado, saltando"
        fi
    done

    # zshrc special case (va en $HOME, no en .config)
    if [ -f "zsh/zshrc" ]; then
        info "Symlink: ~/.zshrc -> $DOTFILES_DIR/zsh/zshrc"
        ln -sf "$DOTFILES_DIR/zsh/zshrc" "$HOME/.zshrc"
    fi

    # Sublime Text
    if [ -d "sublime-text" ]; then
        info "Symlink: ~/.config/sublime-text -> $DOTFILES_DIR/sublime-text"
        ln -sfT "$DOTFILES_DIR/sublime-text" "$HOME/.config/sublime-text"
    fi

    log "Symlinks creados"
}

#===============================================================================
# ZSH + POWERLEVEL10K
#===============================================================================
setup_zsh() {
    header "CONFIGURANDO ZSH + POWERLEVEL10K"

    local p10k_dir="$HOME/.local/share/zsh/powerlevel10k"
    if [ -d "$p10k_dir" ]; then
        log "powerlevel10k ya instalado"
    else
        info "Clonando powerlevel10k..."
        mkdir -p "$HOME/.local/share/zsh"
        git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$p10k_dir"
        log "powerlevel10k instalado"
    fi

    if [ "$SHELL" != "/bin/zsh" ] && [ "$SHELL" != "/usr/bin/zsh" ]; then
        info "Cambiando shell a zsh..."
        if chsh -s /bin/zsh; then
            log "Shell cambiado a zsh (reinicia sesion para efecto completo)"
        else
            warn "No se pudo cambiar el shell. Hacelo manual: chsh -s /bin/zsh"
        fi
    else
        log "Shell ya es zsh"
    fi
}

#===============================================================================
# NEOVIM + LAZYVIM
#===============================================================================
setup_neovim() {
    header "CONFIGURANDO NEOVIM + LAZYVIM"

    if [ -d "$HOME/.config/nvim" ] && [ ! -L "$HOME/.config/nvim" ]; then
        info "Backup de config existente..."
        mv "$HOME/.config/nvim" "$HOME/.config/nvim.backup.$(date +%Y%m%d_%H%M%S)"
    fi

    if [ -d "$DOTFILES_DIR/lazy-nvim" ]; then
        info "Usando config personalizada de LazyVim..."
        rm -rf "$HOME/.config/nvim"
        stow -t "$HOME/.config" lazy-nvim 2>/dev/null
        log "Config de Neovim enlazada"
    else
        info "Clonando LazyVim starter..."
        git clone https://github.com/LazyVim/starter "$HOME/.config/nvim"
        rm -rf "$HOME/.config/nvim/.git"
        log "LazyVim starter instalado"
    fi
}

#===============================================================================
# OLLAMA
#===============================================================================
setup_ollama() {
    header "CONFIGURANDO OLLAMA"

    if ! pacman -Q ollama &>/dev/null; then
        info "Instalando Ollama..."
        sudo pacman -S --noconfirm ollama
    fi

    if ! systemctl is-enabled ollama &>/dev/null; then
        sudo systemctl enable ollama
    fi
    if ! systemctl is-active ollama &>/dev/null; then
        sudo systemctl start ollama
    fi
    log "Servicio Ollama activo"
}

pull_ollama_models() {
    warn "DESCARGAR MODELOS DE OLLAMA? (~15GB)"
    echo -n "   [s/N]: "; read -r resp
    case "$resp" in
        s|S|y|Y)
            local models=("llama3.2" "codellama" "mistral" "neural-chat" "qwen:7b")
            for model in "${models[@]}"; do
                info "Descargando $model..."
                ollama pull "$model" 2>/dev/null && log "$model listo" || warn "Fallo $model"
            done
            ;;
        *)
            log "Modelos no descargados. Para hacerlo despues: ollama pull <modelo>"
            ;;
    esac
}

#===============================================================================
# SERVICIOS DEL SISTEMA
#===============================================================================
enable_services() {
    header "HABILITANDO SERVICIOS DEL SISTEMA"

    local services=(
        "lightdm.service"
        "NetworkManager.service"
        "bluetooth.service"
        "systemd-resolved.service"
        "systemd-timesyncd.service"
        "ollama.service"
    )

    for svc in "${services[@]}"; do
        if systemctl is-enabled "$svc" &>/dev/null; then
            log "$svc ya habilitado"
        else
            info "Habilitando $svc..."
            sudo systemctl enable "$svc" 2>/dev/null || warn "No se pudo habilitar $svc"
        fi
    done

    # PipeWire
    if command -v pipewire &>/dev/null; then
        systemctl --user enable pipewire pipewire-pulse wireplumber 2>/dev/null || true
    fi

    log "Servicios configurados"
}

#===============================================================================
# DIRECTORIOS
#===============================================================================
create_directories() {
    header "CREANDO DIRECTORIOS"
    mkdir -p "$HOME/Pictures/Screenshots"
    mkdir -p "$HOME/Downloads/TEMP"
    mkdir -p "$HOME/Documents/Projects"
    log "Directorios creados"
}

#===============================================================================
# OPCIONAL: BLACKARCH
#===============================================================================
setup_blackarch() {
    echo ""
    warn "CONFIGURAR REPOSITORIOS BLACKARCH? (pentesting)"
    echo -n "   [s/N]: "; read -r resp
    case "$resp" in
        s|S|y|Y)
            header "CONFIGURANDO BLACKARCH"
            if pacman -Q blackarch-keyring &>/dev/null; then
                log "BlackArch ya configurado"
                return 0
            fi
            local strap="$HOME/Downloads/strap.sh"
            curl -s "https://blackarch.org/strap.sh" -o "$strap"
            chmod +x "$strap"
            sudo "$strap"
            sudo pacman -Syy
            log "BlackArch configurado"
            ;;
        *)
            log "BlackArch omitido"
            ;;
    esac
}

#===============================================================================
# POST-INSTALL
#===============================================================================
post_install() {
    header "POST-INSTALACION"

    # Activar firewall con UFW si no existe
    if command -v ufw &>/dev/null; then
        sudo ufw enable 2>/dev/null || true
    fi

    # Agregar usuario a grupos comunes
    sudo usermod -aG docker "$(whoami)" 2>/dev/null || true
    sudo usermod -aG video "$(whoami)" 2>/dev/null || true

    # Permitir lightdm sin password (fingerprint)
    if command -v fprintd-enroll &>/dev/null; then
        info "Para configurar huella digital: fprintd-enroll"
    fi

    log "Post-instalacion completa"
}

#===============================================================================
# RESUMEN FINAL
#===============================================================================
show_summary() {
    header "INSTALACION COMPLETA"
    echo -e "${GREEN}  ✓ Paquetes oficiales instalados${NC}"
    echo -e "${GREEN}  ✓ Paquetes AUR instalados${NC}"
    echo -e "${GREEN}  ✓ Symlinks creados${NC}"
    echo -e "${GREEN}  ✓ Zsh + powerlevel10k configurado${NC}"
    echo -e "${GREEN}  ✓ Neovim configurado${NC}"
    echo -e "${GREEN}  ✓ Servicios habilitados${NC}"
    echo ""
    echo -e "${YELLOW}  PROXIMOS PASOS:${NC}"
    echo "  1. Reinicia sesion para usar Zsh"
    echo "  2. Selecciona Qtile (X11) o Qtile (Wayland) en lightdm"
    echo "  3. Aplica un tema: theme city-sci-fi"
    echo "  4. Abri Neovim para instalar plugins (nvim)"
    echo "  5. Configura monitores: bash ~/dotfiles/automat/display-monitors.sh"
    echo "  6. Para session Wayland: instala paquetes extra con install-wayland.sh"
    echo ""
    echo -e "${CYAN}  Para aplicar un tema: theme at-at${NC}"
    echo -e "${CYAN}  Para abrir menu: Super + Espacio${NC}"
    echo -e "${CYAN}  Para abrir terminal: Super + Enter${NC}"
}

#===============================================================================
# MAIN
#===============================================================================
main() {
    echo -e "${RED}"
    echo "  ____  _   __ _  ____ _   __     ____             _    "
    echo " |  _ \| | / /| \| |  _ \ \ / /   |  _ \ ___  __ _(_)_ __  "
    echo " | | | | |/ / | .\` | |_) \ V /    | |_) / _ \/ _\` | | '_ \ "
    echo " | |_| | |\ \ | |\`  |  _ < | |    |  _ <  __/ (_| | | | | |"
    echo " |____/|_| \_\|_| \_|_| \_\|_|    |_| \_\___|\__, |_|_| |_|"
    echo "                                              |___/         "
    echo -e "${NC}"
    echo -e "${BLUE}  D4rkDr4g0n Dotfiles - Instalador Unificado${NC}"
    echo -e "${BLUE}  Una linea para gobernarlos a todos${NC}"
    echo ""

    for arg in "$@"; do
        case "$arg" in
            --help|-h)
                echo "Uso: bash install.sh [--help|--no-ollama|--no-blackarch|--no-aur|--no-wayland]"
                echo ""
                echo "  Sin flags: Instalacion completa (interactiva para opcionales)"
                echo "  --no-ollama:   Salta descarga de modelos AI"
                echo "  --no-blackarch: Salta configuracion de BlackArch"
                echo "  --no-aur:      Salta paquetes AUR"
                echo "  --no-wayland:  Salta paquetes y symlinks de Wayland (solo X11)"
                exit 0
                ;;
        esac
    done

    # Wayland (se puede saltar con --no-wayland)
    skip_wayland=false
    for arg in "$@"; do [ "$arg" = "--no-wayland" ] && skip_wayland=true; done

    detect_system
    auto_detect_dotfiles

    # Clonar si no existe
    if [ ! -d "$DOTFILES_DIR/.git" ]; then
        header "CLONANDO DOTFILES"
        git clone "$DOTFILES_REPO" "$DOTFILES_DIR"
        log "Repositorio clonado en: $DOTFILES_DIR"
    fi

    install_yay
    install_official_packages

    # Wayland packages (se pueden saltar con --no-wayland)
    if ! $skip_wayland; then
        header "INSTALANDO PAQUETES WAYLAND"
        for pkg in "${WAYLAND_PKGS[@]}"; do
            if ! pacman -Q "$pkg" &>/dev/null; then
                sudo pacman -S --noconfirm "$pkg"
            fi
        done
        log "Paquetes Wayland instalados"
    fi

    # AUR (se puede saltar con --no-aur)
    local skip_aur=false
    for arg in "$@"; do [ "$arg" = "--no-aur" ] && skip_aur=true; done
    if ! $skip_aur; then
        install_aur_packages
    fi

    create_symlinks
    setup_zsh
    setup_neovim
    setup_ollama
    enable_services
    create_directories
    post_install

    # Ollama models (opcional)
    local skip_ollama=false
    for arg in "$@"; do [ "$arg" = "--no-ollama" ] && skip_ollama=true; done
    if ! $skip_ollama; then
        pull_ollama_models
    fi

    # BlackArch (opcional)
    local skip_blackarch=false
    for arg in "$@"; do [ "$arg" = "--no-blackarch" ] && skip_blackarch=true; done
    if ! $skip_blackarch; then
        setup_blackarch
    fi

    show_summary

    echo ""
    echo -e "${GREEN}  Hecho. Disfruta tu sistema D4rkDr4g0n.${NC}"
    echo -e "${RED}        ___${NC}"
    echo -e "${RED}      /\\  \\${NC}"
    echo -e "${RED}     /::\\  \\${NC}"
    echo -e "${RED}    /:/\\:\\__\\${NC}"
    echo -e "${RED}   /:/ /:/ _/_${NC}"
    echo -e "${RED}  /:/ /:/ /\\  \\${NC}"
    echo -e "${RED}  \\__\\/__/  \\__\\${NC}"
}

main "$@"
