# Instalacion

## One Line Install

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/D4rkDr4g0n/dotfiles/main/install.sh)
```

O si ya clonaste el repo:

```bash
cd ~/dotfiles && bash install.sh
```

## Installation Pipeline

El `install.sh` orquesta todos los scripts individuales en un orden especifico. Cada script depende del anterior (ej: fonts antes que kitty, yay antes que AUR packages):

```mermaid
graph LR
    IS[install.sh] --> LIB[lib/common.sh]
    IS --> SY[setup-yay.sh<br/>AUR helper]
    SY --> FZ[install-fonts.sh<br/>Hack, JetBrains, Font Awesome]
    FZ --> ZS[install-zsh.sh<br/>Zsh + p10k + symlinks]
    ZS --> QT[install-qtile.sh<br/>Ctile + Python deps]
    QT --> PB[install-polybar.sh<br/>Polybar + stow]
    QT --> PC[install-picom.sh<br/>Picom + stow]
    QT --> KT[install-kitty.sh<br/>Kitty + stow]
    QT --> RF[install-rofi.sh<br/>Rofi + stow]
    QT --> NV[install-neovim.sh<br/>Neovim + LazyVim]
    QT --> TL[install-tools.sh<br/>Obsidian, Firefox, Flameshot<br/>CopyQ, Discord, Spotify]
    TL --> OL[install-ollama.sh<br/>Ollama + modelos AI]
    TL --> N8[install-n8n.sh<br/>n8n systemd service]
    PC --> BA[setup-blackarch.sh<br/>BlackArch repos<br/>(opcional)]
```

**Sources:** `install.sh`, `automat/install/lib/common.sh`

## Flags

| Flag | Efecto |
|------|--------|
| `--help` / `-h` | Muestra ayuda |
| `--no-ollama` | Salta descarga de modelos AI (~15GB) |
| `--no-blackarch` | Salta configuracion de BlackArch |
| `--no-aur` | Salta paquetes AUR |

Ejemplo:

```bash
bash install.sh --no-ollama --no-blackarch
```

## Que Instala?

| Categoria | Paquetes |
|-----------|----------|
| **WM + UI** | Ctile, Polybar, Picom, Rofi, Dunst, Nitrogen |
| **Terminal** | Kitty, Zsh + powerlevel10k |
| **Shell Tools** | zoxide, fzf, fd, ripgrep, bat, lsd, yazi, fastfetch, btop |
| **Drivers** | AMDGPU, Vulkan, Xorg |
| **Audio** | PipeWire + WirePlumber |
| **Networking** | NetworkManager, iwd, Proton VPN |
| **Bluetooth** | Bluez + bluetui |
| **Desarrollo** | Neovim + LazyVim, Node.js, Python, Lua, Git, GitHub CLI |
| **Productividad** | Obsidian, Firefox, Thunar, Flameshot, CopyQ, Discord, Spotify, Bitwarden |
| **AI** | Ollama + modelos (opcional) |
| **Automation** | n8n |
| **Fonts** | Hack Nerd Font, JetBrains Mono, Font Awesome, Noto |
| **AUR** | yay + paquetes AUR |

## Entity Mapping: Installation Scripts

| Script | Rol | Dependencias | Destino |
|--------|-----|--------------|---------|
| `setup-yay.sh` | AUR helper | — | yay |
| `install-fonts.sh` | Nerd Fonts, Awesome, Noto | — | `/usr/share/fonts/` |
| `install-zsh.sh` | Shell + powerlevel10k | fonts | `~/.config/zsh/` |
| `install-qtile.sh` | Window Manager | — | `~/.config/qtile/` |
| `install-polybar.sh` | Status bar | — | `~/.config/polybar/` |
| `install-picom.sh` | Compositor | — | `~/.config/picom/` |
| `install-kitty.sh` | Terminal | — | `~/.config/kitty/` |
| `install-rofi.sh` | Launcher | — | `~/.config/rofi/` |
| `install-neovim.sh` | Editor (LazyVim) | — | `~/.config/nvim/` |
| `install-tools.sh` | Apps de productividad | yay | — |
| `install-ollama.sh` | AI models | — | Systemd service |
| `install-n8n.sh` | Workflow automation | — | Systemd user service |
| `setup-blackarch.sh` | BlackArch repos | — | `/etc/pacman.conf` |

## Instalacion Manual

Si preferis instalar por partes, los scripts individuales estan en `automat/install/`:

```bash
cd ~/dotfiles
bash automat/install/setup-yay.sh
bash automat/install/install-fonts.sh
bash automat/install/install-zsh.sh
bash automat/install/install-qtile.sh
bash automat/install/install-polybar.sh
bash automat/install/install-picom.sh
bash automat/install/install-kitty.sh
bash automat/install/install-rofi.sh
bash automat/install/install-neovim.sh
bash automat/install/install-tools.sh
bash automat/install/install-ollama.sh
bash automat/install/install-n8n.sh
bash automat/install/setup-blackarch.sh  # opcional
```

## Post-Instalacion

1. **Reinicia sesion** para usar Zsh como shell default
2. **Selecciona Ctile** en lightdm
3. **Aplica un tema**: `theme city-sci-fi`
4. **Abre Neovim** para instalar plugins: `nvim` + `Lazy!`
5. **Configura monitores**: `bash ~/dotfiles/automat/display-monitors.sh`
6. **Configura OneDrive**: Editar `onedrive/config` con tu tenant
7. **Verifica**: `fastfetch`

## Symlinks Manuales

Los symlinks se crean automaticamente con `install.sh`, pero podes hacerlo manual:

```bash
ln -sf ~/dotfiles/zsh/zshrc ~/.zshrc
for dir in qtile polybar picom rofi kitty Thunar zsh automat dunst opencode; do
    ln -sf ~/dotfiles/$dir ~/.config/$dir
done
ln -sf ~/dotfiles/lazy-nvim ~/.config/nvim
```
