# Instalacion

## Una Linea Para Instalarlos A Todos

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/D4rkDr4g0n/dotfiles/main/install.sh)
```

O si ya clonaste el repo:

```bash
cd ~/dotfiles && bash install.sh
```

## Flags

| Flag | Efecto |
|------|--------|
| `--help` / `-h` | Muestra ayuda |
| `--no-ollama` | Salta descarga de modelos AI (~15GB) |
| `--no-blackarch` | Salta configuracion de BlackArch |
| `--no-aur` | Salta paquetes AUR |

Ejemplo con flags:

```bash
bash install.sh --no-ollama --no-blackarch
```

## Que instala?

- **WM + UI**: Qtile, Polybar, Picom, Rofi, Dunst, Nitrogen
- **Terminal**: Kitty, Zsh + powerlevel10k
- **Shell tools**: zoxide, fzf, fd, ripgrep, bat, lsd, yazi, fastfetch, btop
- **Drivers**: AMDGPU, Vulkan, Xorg
- **Audio**: PipeWire + WirePlumber
- **Networking**: NetworkManager, iwd, Proton VPN
- **Bluetooth**: Bluez + bluetui
- **Desarrollo**: Neovim + LazyVim, Node.js, Python, Lua, Git, GitHub CLI
- **Productividad**: Obsidian, Firefox, Thunar, Flameshot, CopyQ, Discord, Spotify, Bitwarden
- **AI**: Ollama + modelos (opcional)
- **Automation**: n8n
- **Fonts**: Hack Nerd Font, JetBrains Mono, Font Awesome, Noto
- **AUR**: yay + paquetes AUR

## Instalacion Manual (scripts individuales)

Si preferis instalar por partes, los scripts individuales estan en `automat/install/`:

```bash
cd ~/dotfiles
bash automat/install/setup-yay.sh              # AUR helper
bash automat/install/install-fonts.sh          # Fuentes
bash automat/install/install-zsh.sh            # Zsh + p10k
bash automat/install/install-qtile.sh          # Qtile
bash automat/install/install-polybar.sh        # Polybar
bash automat/install/install-picom.sh          # Compositor
bash automat/install/install-kitty.sh          # Terminal
bash automat/install/install-rofi.sh           # Launcher
bash automat/install/install-neovim.sh         # Neovim + LazyVim
bash automat/install/install-tools.sh          # Apps
bash automat/install/install-ollama.sh         # Ollama + modelos
bash automat/install/install-n8n.sh            # n8n
bash automat/install/setup-blackarch.sh        # BlackArch (opcional)
```

## Post-Instalacion

1. **Reinicia sesion** para usar Zsh
2. **Selecciona Qtile** en lightdm
3. **Aplica un tema**: `theme city-sci-fi`
4. **Abre Neovim** para instalar plugins: `nvim`
5. **Configura monitores**: `bash ~/dotfiles/automat/display-monitors.sh`
6. **Configura OneDrive**: Editar `onedrive/config`
7. **Verifica**: `fastfetch`

## Enlaces Simbolicos

Los symlinks se crean automaticamente con `install.sh`, pero podes hacerlo manual:

```bash
ln -sf ~/dotfiles/zsh/zshrc ~/.zshrc
for dir in qtile polybar picom rofi kitty Thunar zsh automat; do
    ln -sf ~/dotfiles/$dir ~/.config/$dir
done
ln -sf ~/dotfiles/lazy-nvim ~/.config/nvim
ln -sf ~/dotfiles/sublime-text ~/.config/sublime-text
```
