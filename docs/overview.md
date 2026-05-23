# Overview

## Filosofia

Estos dotfiles estan disenados con tres pilares fundamentales:

- **Keyboard-driven**: Todo el entorno se controla con atajos de teclado. El mouse es opcional.
- **Estetica unificada**: Tema cyberpunk oscuro con acentos rojos, transparencias y blur, consistente en todos los componentes.
- **Modularidad**: Cada componente es independiente y facil de modificar. El sistema de temas dinamicos permite cambiar la apariencia completa con un solo comando.

## Componentes

| Componente | Proposito | Configuracion |
|------------|-----------|---------------|
| **Qtile** | Window Manager (tiling) | `qtile/` |
| **Polybar** | Barra de estado | `polybar/` |
| **Kitty** | Terminal emulator | `kitty/` |
| **Zsh** | Shell + prompt (powerlevel10k) | `zsh/` |
| **Rofi** | Application launcher & menus | `rofi/` |
| **Picom** | Compositor (blur, transparencias) | `picom/` |
| **Neovim** | Editor (LazyVim distro) | `lazy-nvim/` |
| **Sublime Text** | Editor alternativo | `sublime-text/` |
| **Thunar** | File manager | `Thunar/` |
| **Fastfetch** | System info display | `fastfetch/` |
| **OneDrive** | Cloud sync | `onedrive/` |
| **opencode** | AI assistant config + skills | `opencode/` |

## File Tree

```
dotfiles/
├── README.md
├── docs/                          # Documentacion
│   ├── overview.md
│   ├── installation.md
│   ├── keybindings.md
│   ├── themes.md
│   ├── automations.md
│   └── configuration/
│       ├── qtile.md
│       ├── polybar.md
│       ├── kitty.md
│       ├── zsh.md
│       ├── rofi.md
│       ├── picom.md
│       ├── editors.md
│       ├── fastfetch.md
│       ├── thunar.md
│       ├── opencode.md
│       └── extras.md
│
├── qtile/                         # Qtile WM
│   ├── config.py                  # Entry point principal
│   ├── current_theme.json         # Tema activo
│   └── modules/
│       ├── groups.py              # Workspaces (NOTES, FILES, DEV, SYS, WEB)
│       ├── keys.py                # Keybindings
│       ├── layouts.py             # Layouts: Columns, MonadTall, Stack
│       ├── mouse.py               # Mouse bindings
│       ├── screens.py             # Pantallas y wallpapers
│       └── hooks.py               # Autostart y eventos
│
├── polybar/                       # Status bar
│   ├── config.ini                 # Barra principal
│   ├── colors.ini                 # Colores (dinamico por tema)
│   ├── launch.sh                  # Script de inicio
│   └── modules/
    │       ├── battery.ini
    │       ├── bluetooth.ini
    │       ├── bluetooth_status.sh
    │       ├── brillo.ini
    │       ├── date.ini
    │       ├── logo.ini
    │       ├── pulseaudio.ini
    │       ├── vpn.ini
    │       ├── vpn_status.sh
    │       ├── vpn_toggle.sh
    │       ├── wlan.ini
    │       └── xworkspaces.ini
│
├── kitty/                         # Terminal
│   ├── kitty.conf                 # Config principal
│   └── colors.conf                # Colores (dinamico por tema)
│
├── zsh/                           # Shell
│   ├── zshrc                      # Entry point
│   └── modules/
│       ├── aliases.zsh
│       ├── history.zsh
│       ├── paths.zsh
│       ├── plugins.zsh
│       ├── startup.zsh
│       ├── theme.zsh
│       └── tools.zsh
│
├── rofi/                          # Launcher
│   ├── config.rasi                # Config modo d-run/run/window
│   ├── theme.rasi                 # Tema visual
│   ├── favoritos.txt              # Apps favoritas
│   └── scripts/
│       ├── launcher.sh            # App launcher custom
│       ├── emoji.sh               # Emoji picker
│       ├── qtile-action-menu.sh   # Suspend/Reboot/Poweroff/Logout
│       ├── qtile-workspace-switcher.sh
│       ├── settings-menu.sh       # Menu central de config
│       └── web-search.sh          # Busqueda en Google
│
├── picom/                         # Compositor
│   └── picom.conf
│
├── lazy-nvim/                     # Neovim (LazyVim)
│   ├── init.lua
│   ├── lazy-lock.json
│   └── lua/
│       ├── config/
│       │   ├── init.lua
│       │   ├── lazy.lua
│       │   ├── options.lua
│       │   ├── keymaps.lua
│       │   ├── autocmds.lua
│       │   ├── colors.lua
│       │   └── highlights.lua
│       └── plugins/
│           ├── colorscheme.lua
│           └── example.lua
│
├── sublime-text/                  # Sublime Text
│   └── Packages/User/
│       ├── Preferences.sublime-settings
│       ├── Package Control.sublime-settings
│       └── Kali-Red-Hack.sublime-color-scheme
│
├── Thunar/                        # File manager
│   ├── accels.scm                 # Keyboard shortcuts
│   └── uca.xml                    # Custom actions
│
├── fastfetch/                     # System info
│   ├── config.jsonc
│   ├── ascii/                     # ASCII logos
│   └── png/                       # PNG logos
│
├── onedrive/                      # Cloud sync
│   ├── config
│   └── sync_list
│
├── opencode/                      # AI assistant (opencode)
│   ├── opencode.jsonc             # Configuracion global
│   ├── .gitignore                 # Ignora node_modules, lock files
│   ├── package.json               # Plugin dependencies
│   └── node_modules/              # Runtime (gitignored)
│
├── themes/                        # Temas dinamicos (8)
│   ├── at-at/
│   ├── city/
│   ├── city-sci-fi/
│   ├── creativity-room/
│   ├── data-center/
│   ├── hacker/
│   ├── hacker-setup/
│   └── kali-red/
│
├── scripts/                       # Scripts utilitarios
│   ├── theme-switch.sh            # Switch de temas
│   └── vpn-replace.sh             # Reemplazar config de Wireguard VPN
│
├── automat/                       # Automatizacion
│   ├── display-monitors.sh
│   ├── launch-logo.sh
│   ├── launchgemma.sh
│   ├── vault-pull.sh
│   ├── vault-push.sh
│   └── install/                   # Scripts de instalacion
│       ├── install-fonts.sh
│       ├── install-kitty.sh
│       ├── install-n8n.sh
│       ├── install-neovim.sh
│       ├── install-ollama.sh
│       ├── install-picom.sh
│       ├── install-polybar.sh
│       ├── install-qtile.sh
│       ├── install-rofi.sh
│       ├── install-tools.sh
│       ├── install-zsh.sh
│       ├── setup-blackarch.sh
│       └── setup-yay.sh
│
└── recursos/                      # Recursos
    ├── wallpapers/                # 18+ wallpapers
    ├── finnancials/
    │   └── gastos.py             # TUI expense manager
    ├── logo-bloqueo.png
    ├── logo.txt
    └── tux.txt
```

## Estructura de Enlaces Simbolicos

Los archivos de configuracion se vinculan desde el repo a sus ubicaciones del sistema:

```bash
~/.zshrc              -> ~/dotfiles/zsh/zshrc
~/.config/qtile       -> ~/dotfiles/qtile/
~/.config/polybar     -> ~/dotfiles/polybar/
~/.config/picom       -> ~/dotfiles/picom/
~/.config/rofi        -> ~/dotfiles/rofi/
~/.config/kitty       -> ~/dotfiles/kitty/
~/.config/Thunar      -> ~/dotfiles/Thunar/
~/.config/zsh         -> ~/dotfiles/zsh/
~/.config/automat     -> ~/dotfiles/automat/
~/.config/opencode    -> ~/dotfiles/opencode/
```

## Sistema de Temas Dinamicos

Cada tema define colores para todos los componentes. Al cambiar de tema (via `theme <nombre>` o Rofi), se actualizan automaticamente:

- Polybar (`colors.ini`)
- Kitty (`colors.conf`)
- Zsh (`~/.zsh_colors`)
- Qtile (wallpaper)
- Fastfetch (colores)

## Atajos de Navegacion

- [Instalacion](installation.md)
- [Atajos de Teclado](keybindings.md)
- [Temas](themes.md)
- [Automatizaciones](automations.md)
- [Configuracion Qtile](configuration/qtile.md)
- [Configuracion Polybar](configuration/polybar.md)
- [Configuracion Kitty](configuration/kitty.md)
- [Configuracion Zsh](configuration/zsh.md)
- [Configuracion Rofi](configuration/rofi.md)
- [Configuracion Picom](configuration/picom.md)
- [Editores](configuration/editors.md)
- [Fastfetch](configuration/fastfetch.md)
- [Thunar](configuration/thunar.md)
- [opencode](configuration/opencode.md)
- [Extras](configuration/extras.md)
