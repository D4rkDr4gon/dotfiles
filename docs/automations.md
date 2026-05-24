# Automatizaciones

## Scripts de Automatizacion (`automat/`)

### Utilidades del Sistema

| Script | Descripcion |
|--------|-------------|
| `display-monitors.sh` | Configura monitores via xrandr |
| `launch-logo.sh` | Muestra banner ASCII del dragon D4rkDr4g0n |
| `launchgemma.sh` | Lanza Ollama + Gemma 3 en una nueva ventana de Kitty |

### Vault (OneDrive/Obsidian)

| Script | Descripcion |
|--------|-------------|
| `vault-pull.sh` | Git pull en `~/OneDrive/vault` |
| `vault-push.sh` | Git add/commit/push "D4 - YYYY-MM-DD" |

---

## Scripts de Instalacion (`automat/install/`)

### Libreria Compartida

Todos los scripts usan `lib/common.sh` para funciones compartidas (colores, logs, deteccion de Arch).

### Instalador Unificado

El archivo `install.sh` en la raiz del repo es el instalador principal:

```bash
# Una linea:
bash <(curl -fsSL https://raw.githubusercontent.com/D4rkDr4g0n/dotfiles/main/install.sh)

# O local:
cd ~/dotfiles && bash install.sh
```

### Scripts Individuales

| Script | Instala |
|--------|---------|
| `setup-yay.sh` | AUR helper (yay) - ahora con compilacion automatica |
| `install-fonts.sh` | Hack Nerd Font, JetBrains Mono Nerd, Font Awesome, Noto |
| `install-zsh.sh` | Zsh + powerlevel10k + symlinks |
| `install-qtile.sh` | Qtile + dependencias Python + session file |
| `install-polybar.sh` | Polybar + stow symlinks |
| `install-picom.sh` | Picom compositor + stow |
| `install-kitty.sh` | Kitty terminal + stow |
| `install-rofi.sh` | Rofi + sigma-file-manager |
| `install-neovim.sh` | Neovim + LazyVim starter |
| `install-tools.sh` | Obsidian, Flameshot, Firefox, CopyQ, Discord, Spotify |
| `install-ollama.sh` | Ollama service + scripts de utilidad |
| `ollama-pull.sh` | Descarga modelos Ollama (~15GB) |
| `install-n8n.sh` | n8n workflow automation + systemd user service |
| `setup-blackarch.sh` | Repositorios BlackArch (ahora automatizado) |

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

### Cambios Recientes

- **Unificacion**: Nuevo `install.sh` que instala todo con un solo comando
- **yay**: Ahora compila automaticamente (ya no requiere `makepkg -si` manual)
- **BlackArch**: Ahora ejecuta `strap.sh` automaticamente (con confirmacion)
- **n8n**: Ahora crea servicio de systemd user
- **Boilerplate eliminado**: Funciones comunes en `lib/common.sh`
- **Paths relativos**: Ya no usa `/home/lcampassi/dotfiles` hardcodeado
- **Bugfix**: `install-zsh.sh` ahora usa `stow -t ~/.config zsh` en vez de `stow -t \$HOME zshrc`
