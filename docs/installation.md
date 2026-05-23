# Instalacion

## Prerrequisitos

- **Arch Linux** (o derivado como Kali)
- Conexion a internet
- `git` instalado
- `yay` (AUR helper) -- ver `setup-yay.sh`

## Instalacion Rapida

```bash
# 1. Clonar el repositorio
git clone https://github.com/D4rkDr4gon/dotfiles.git ~/dotfiles
cd ~/dotfiles

# 2. Ejecutar scripts de instalacion en orden
bash automat/install/setup-yay.sh          # AUR helper
bash automat/install/install-fonts.sh      # Fuentes Nerd Font
bash automat/install/install-zsh.sh        # Zsh + powerlevel10k
bash automat/install/install-qtile.sh      # Qtile WM
bash automat/install/install-polybar.sh    # Polybar
bash automat/install/install-picom.sh      # Picom compositor
bash automat/install/install-kitty.sh      # Kitty terminal
bash automat/install/install-rofi.sh       # Rofi launcher
bash automat/install/install-neovim.sh     # Neovim + LazyVim
bash automat/install/install-tools.sh      # Apps (Obsidian, Firefox, etc.)
bash automat/install/install-ollama.sh     # Ollama + modelos AI
bash automat/install/install-n8n.sh        # n8n automation

# 3. (Opcional) Repositorios de pentesting
bash automat/install/setup-blackarch.sh    # BlackArch repos
```

## Instalacion Manual

### Enlaces Simbolicos

Si preferis configurar manualmente:

```bash
# Shell
ln -sf ~/dotfiles/zsh/zshrc ~/.zshrc
ln -sf ~/dotfiles/zsh ~/.config/zsh

# WM y componentes
ln -sf ~/dotfiles/qtile ~/.config/qtile
ln -sf ~/dotfiles/polybar ~/.config/polybar
ln -sf ~/dotfiles/picom ~/.config/picom
ln -sf ~/dotfiles/rofi ~/.config/rofi
ln -sf ~/dotfiles/kitty ~/.config/kitty
ln -sf ~/dotfiles/Thunar ~/.config/Thunar
ln -sf ~/dotfiles/automat ~/.config/automat

# Neovim
ln -sf ~/dotfiles/lazy-nvim ~/.config/nvim

# Sublime Text (Linux)
ln -sf ~/dotfiles/sublime-text ~/.config/sublime-text

# OneDrive
ln -sf ~/dotfiles/onedrive ~/.config/onedrive
```

### Dependencias Principales

```bash
# Core
sudo pacman -S qtile polybar picom rofi kitty nitrogen brightnessctl pavucontrol

# Shell
sudo pacman -S zsh curl wget git
sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ~/powerlevel10k

# Apps
sudo pacman -S flameshot thunar obsidian firefox

# Fuentes
sudo pacman -S ttf-hack-nerd ttf-jetbrains-mono-nerd ttf-font-awesome noto-fonts noto-fonts-emoji
```

## Post-Instalacion

1. **Cambiar shell a Zsh**: `chsh -s $(which zsh)`
2. **Configurar monitores**: `sh ~/dotfiles/automat/display-monitors.sh`
3. **Seleccionar tema**: `theme at-at` o via Rofi Settings Menu
4. **Configurar OneDrive**: Editar `onedrive/config` con tu tenant
5. **Verificar**: `fastfetch` debe mostrar el logo y datos del sistema
