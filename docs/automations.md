# Automatizaciones

## Scripts de Automatizacion (`automat/`)

### Utilidades del Sistema

| Script | Descripcion |
|--------|-------------|
| `display-monitors.sh` | Configura monitores via xrandr: laptop 1920x1080 + HDMI externo 1920x1080 lado a lado |
| `launch-logo.sh` | Muestra banner ASCII del dragon D4rkDr4g0n |
| `launchgemma.sh` | Lanza Ollama + Gemma 3 270M en una nueva ventana de Kitty |

### Vault (OneDrive/Obsidian)

| Script | Descripcion |
|--------|-------------|
| `vault-pull.sh` | Git pull --force en `~/OneDrive/vault` |
| `vault-push.sh` | Git add/commit/push con mensaje "D4 - YYYY-MM-DD" |

---

## Scripts de Instalacion (`automat/install/`)

Disenados para Arch Linux. Ejecutar en orden.

| Script | Instala |
|--------|---------|
| `setup-yay.sh` | AUR helper (yay) |
| `install-fonts.sh` | Hack Nerd Font, JetBrains Mono Nerd, Font Awesome, Noto Fonts |
| `install-zsh.sh` | Zsh + powerlevel10k + symlinks |
| `install-qtile.sh` | Qtile + dependencias Python + session file |
| `install-polybar.sh` | Polybar + stow symlinks |
| `install-picom.sh` | Picom compositor + stow |
| `install-kitty.sh` | Kitty terminal + stow |
| `install-rofi.sh` | Rofi launcher + stow |
| `install-neovim.sh` | Neovim + LazyVim starter |
| `install-tools.sh` | Obsidian, Flameshot, Firefox, CopyQ, Discord, Spotify, btop, Bitwarden, onedriver |
| `install-ollama.sh` | Ollama service + modelos (llama3.2, codellama, mistral) |
| `install-n8n.sh` | n8n workflow automation (AUR) |
| `setup-blackarch.sh` | Repositorios BlackArch (strap.sh + pacman.conf) |

### Orden Recomendado

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
