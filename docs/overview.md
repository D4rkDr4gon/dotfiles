# Overview

## Core Philosophy

El entorno se sostiene sobre tres pilares fundamentales:

- **Keyboard-driven**: Control total del entorno via atajos de teclado. El mouse es opcional. Las combinaciones `mod4` (Super) gobiernan ventanas, workspaces, lanzadores y menus.
- **Estetica unificada**: Tema cyberpunk oscuro con acentos rojos, transparencias y blur. Consistente en todos los componentes. Funciona igual en X11 y Wayland.
- **Modularidad**: Cada componente es independiente y facil de modificar. El sistema de temas dinamicos permite cambiar la apariencia completa con un solo comando. Soporte dual-backend (X11/Wayland).

## Component Architecture

### Triple-Backend

El entorno soporta 3 modos de sesión, seleccionables desde LightDM:

| Backend | Sesión | WM | Barra | 
|---------|--------|----|-------|
| **X11** | Qtile | Qtile (X11) | Polybar |
| **Qtile Wayland** | Qtile (Wayland) | Qtile (Wayland) | Waybar |
| **Hyprland** | Hyprland | Hyprland | Waybar |

Componentes por sesión:

| Componente | X11 (Qtile) | Qtile Wayland | Hyprland |
|---|---|---|---|
| **Barra** | Polybar | Waybar | Waybar |
| **Compositor** | Picom (GLX + blur) | No necesario (wlroots) | No necesario (nativo) |
| **Wallpaper** | Nitrogen | Qtile `Screen(wallpaper=...)` | hyprpaper |
| **Lock** | betterlockscreen | gtklock | gtklock |
| **Screenshot** | Flameshot | grim + slurp | grim + slurp |
| **Monitores** | xrandr | wlr-randr | wlr-randr / hyprctl |

Ver [Wayland Architecture](configuration/wayland.md) y [Hyprland](configuration/hyprland.md) para más detalle.

```mermaid
graph TB
    subgraph Input["Input Layer"]
        KB[Keybindings<br/>mod4 + *]
        M[Mouse Bindings]
    end

    subgraph WM["Window Manager"]
        Q[Qtile config.py]
        QM[Qtile Modules<br/>groups.py, keys.py<br/>layouts.py, hooks.py]
        H[Hyprland hyprland.conf]
    end

    subgraph Bar["Status Bar"]
        PB[Polybar<br/>X11]
        WB[Waybar<br/>Wayland + Hyprland]
    end

    subgraph Shell["Terminal & Shell"]
        KT[Kitty<br/>kitty.conf + wayland flag]
        ZH[Zsh<br/>zshrc + modules/]
    end

    subgraph Launcher["Application Launcher"]
        RF[Rofi<br/>config.rasi + themes]
        RF_S[Rofi Scripts<br/>launcher, settings, actions<br/>(dual-WM)]
    end

    subgraph Theme["Theme Engine"]
        TS[theme-switch.sh]
        TJ[themes/*/theme.json]
    end

    KB --> Q
    KB --> H
    M --> Q
    Q --> QM
    Q --> DN
    Q --> KT
    H --> KT
    KT --> ZH
    Q --> RF
    H --> RF

    TS --> TJ
    TS --> PB
    TS --> WB
    TS --> KT
    TS --> ZH
    TS --> Q
    TS --> H
```

**Sources:** `qtile/config.py`, `hypr/hyprland.conf`, `polybar/config.ini`, `waybar/config.jsonc`, `kitty/kitty.conf`, `zsh/zshrc`, `scripts/theme-switch.sh`, `scripts/barupdate.sh`

## Component Table

| Componente | Proposito | Configuracion | Docs |
|------------|-----------|---------------|------|
| **Qtile** | Window Manager (tiling, X11 + Wayland) | `qtile/` | [docs](configuration/qtile.md) |
| **Hyprland** | Window Manager alternativo (Wayland nativo) | `hypr/` | [docs](configuration/hyprland.md) |
| **Polybar** | Barra de estado (X11) | `polybar/` | [docs](configuration/polybar.md) |
| **Waybar** | Barra de estado (Qtile Wayland + Hyprland) | `waybar/` | [docs](configuration/wayland.md) |
| **Kitty** | Terminal emulator (X11 + Wayland) | `kitty/` | [docs](configuration/kitty.md) |
| **Zsh** | Shell + prompt (powerlevel10k) | `zsh/` | [docs](configuration/zsh.md) |
| **Rofi** | Application launcher & menus (dual-WM) | `rofi/` | [docs](configuration/rofi.md) |
| **Picom** | Compositor (X11 only) | `picom/` | [docs](configuration/picom.md) |
| **Dunst** | Notification daemon | `dunst/` | [docs](configuration/dunst.md) |
| **Neovim** | Editor (LazyVim) | `lazy-nvim/` | [docs](configuration/editors.md) |
| **Sublime Text** | Editor alternativo | `sublime-text/` | [docs](configuration/editors.md) |
| **Thunar** | File manager | `Thunar/` | [docs](configuration/thunar.md) |
| **Fastfetch** | System info display | `fastfetch/` | [docs](configuration/fastfetch.md) |
| **OneDrive** | Cloud sync | `onedrive/` | [docs](configuration/extras.md) |
| **GTK3** | Tema GTK base + CSS dinámico (Thunar, apps GTK3) | `gtk-3.0/` | [docs](configuration/gtk.md) |
| **Lock Screen** | gtklock (Wayland) / betterlockscreen (X11) | `gtklock/` + `scripts/` | [docs](configuration/lock-screen.md) |
| **opencode** | AI assistant config + skills | `opencode/` | [docs](configuration/opencode.md) |
| **Screenshots** | grim+slurp (Wayland) / Flameshot (X11) | `scripts/screenshot.sh` | [docs](configuration/wayland.md) |

## Symlink Structure

Los archivos de configuracion se vinculan desde el repo a sus ubicaciones del sistema via symlinks, permitiendo gestion centralizada desde `~/dotfiles`:

| System Path | Repository Target |
|-------------|-------------------|
| `~/.zshrc` | `~/dotfiles/zsh/zshrc` |
| `~/.config/qtile` | `~/dotfiles/qtile/` |
| `~/.config/hypr` | `~/dotfiles/hypr/` |
| `~/.config/polybar` | `~/dotfiles/polybar/` |
| `~/.config/waybar` | `~/dotfiles/waybar/` |
| `~/.config/gtklock` | `~/dotfiles/gtklock/` |
| `~/.config/picom` | `~/dotfiles/picom/` |
| `~/.config/rofi` | `~/dotfiles/rofi/` |
| `~/.config/kitty` | `~/dotfiles/kitty/` |
| `~/.config/Thunar` | `~/dotfiles/Thunar/` |
| `~/.config/zsh` | `~/dotfiles/zsh/` |
| `~/.config/automat` | `~/dotfiles/automat/` |
| `~/.config/dunst` | `~/dotfiles/dunst/` |
| `~/.config/opencode` | `~/dotfiles/opencode/` |
| `~/.config/hypr` | `~/dotfiles/hypr/` |
| `~/.config/nvim` | `~/dotfiles/lazy-nvim/` |
| `~/.config/gtk-3.0/settings.ini` | `~/dotfiles/gtk-3.0/settings.ini` |
| `~/.config/gtklock` | `~/dotfiles/gtklock/` |

## Theme Data Flow

Cada tema define colores para todos los componentes. El sistema de temas genera configuraciones tanto para X11 (Polybar) como para Wayland (Waybar) simultáneamente:

```mermaid
graph LR
    TJ[theme.json] --> TS[theme-switch.sh]

    TS -->|sed + echo| PC[polybar/colors.ini<br/>primary, secondary<br/>background, foreground, chip]
    TS -->|cat + @define-color| WC[waybar/theme.css<br/>primary, secondary<br/>background rgba, chip]
    TS -->|printf| KC[kitty/colors.conf<br/>foreground, background<br/>cursor, selection, tabs]
    TS -->|source| ZC[~/.zsh_colors<br/>COLOR_PRIMARY, COLOR_ACCENT<br/>COLOR_BG, COLOR_FG]
    TS -->|cat + @define-color| GC[gtk-3.0/gtk.css<br/>theme_bg, theme_fg<br/>theme_primary, theme_secondary]
    TS -->|sed| OC[opencode.jsonc<br/>agent colors]
    TS -->|jq + cp| QT[qtile/current_theme.json<br/>theme activo]
    TS -->|sed| SC[qtile/modules/screens.py<br/>wallpaper path]

    PC --> PR[Polybar Reload]
    WC --> WR[Waybar Reload]
    KC --> KR[Kitty @ set-colors]
    ZC --> ZR[Zsh source]
    QT --> QS[Qtile set_wallpaper directo]
    SC --> QS
    QT --> HP[Hyprland hyprpaper<br/>hyprctl hyprpaper ...]
```

**Sources:** `scripts/theme-switch.sh:62-141`, `polybar/colors.ini`, `waybar/theme.css`, `kitty/colors.conf`, `zsh/modules/theme.zsh`, `gtk-3.0/`, `opencode/opencode.jsonc`, `qtile/current_theme.json`

## File Tree

```
dotfiles/
├── README.md
├── docs/
│   ├── overview.md
│   ├── installation.md
│   ├── keybindings.md
│   ├── themes.md
│   ├── automations.md
│   └── configuration/
│       ├── qtile.md, hyprland.md, polybar.md, wayland.md, kitty.md
│       ├── zsh.md, rofi.md, picom.md, dunst.md, editors.md
│       ├── fastfetch.md, thunar.md, gtk.md, opencode.md
│       ├── extras.md, lock-screen.md
│
├── qtile/
├── hypr/                       # Hyprland config (WM alternativo)
│   ├── hyprland.conf
│   ├── hyprpaper.conf
│   └── scripts/
│       ├── hypr-workspaces.py
│       └── hypr-workspace-switch.sh
├── polybar/
├── waybar/                    # Wayland bar (reemplaza Polybar en Wayland)
│   ├── config.jsonc
│   ├── style.css
│   ├── theme.css
│   ├── launch.sh
│   ├── modules/
│   └── scripts/
├── gtklock/                   # Wayland lock screen config (GTK-based)
│   ├── config.ini, style.css, layout.ui
├── kitty/
├── zsh/
├── rofi/
├── picom/
├── dunst/
├── lazy-nvim/
├── sublime-text/
├── Thunar/
├── fastfetch/
├── gtk-3.0/
│   └── settings.ini              # Tema GTK base (Matcha-dark-aliz, Papirus-Dark)
├── onedrive/
├── opencode/
├── themes/                    # 8 temas dinamicos
├── scripts/                   # theme-switch.sh, lock-screen.sh, barupdate.sh, screenshot.sh, vpn-replace.sh
├── automat/                   # Automatizacion + install scripts
└── recursos/                  # Wallpapers, ASCII, herramientas
```

## Navigation Guide

- [Instalacion](installation.md) — Deployment desde cero, flags, scripts individuales
- [Atajos de Teclado](keybindings.md) — Todos los shortcuts Qtile, Kitty, Thunar, Zsh
- [Temas](themes.md) — Sistema de temas dinamicos, creacion y personalizacion
- [Automatizaciones](automations.md) — Scripts de instalacion, vault, AI, utilities
- [Configuracion Qtile](configuration/qtile.md) — Window manager, grupos, layouts, hooks, dual-backend
- [Configuracion Hyprland](configuration/hyprland.md) — WM alternativo, keybindings, workspaces, window rules
- [Configuracion Polybar](configuration/polybar.md) — Barra de estado X11, modulos, colores
- [Wayland Architecture](configuration/wayland.md) — Migracion, triple-backend, Waybar, gtklock, grim+slurp
- [Configuracion Kitty](configuration/kitty.md) — Terminal, colores, keybindings, Wayland
- [Configuracion Zsh](configuration/zsh.md) — Shell, aliases, plugins, prompt
- [Configuracion Rofi](configuration/rofi.md) — Launcher, temas, scripts
- [Configuracion Picom](configuration/picom.md) — Compositor X11, blur, animaciones
- [Configuracion Dunst](configuration/dunst.md) — Notificaciones, notification center
- [Editores](configuration/editors.md) — Neovim (LazyVim) y Sublime Text
- [Fastfetch](configuration/fastfetch.md) — System info display
- [Thunar](configuration/thunar.md) — File manager, custom actions
- [GTK3](configuration/gtk.md) — Tema GTK base, CSS dinámico para Thunar y apps GTK
- [opencode](configuration/opencode.md) — AI assistant, skills personalizadas
- [Lock Screen](configuration/lock-screen.md) — gtklock / betterlockscreen, CSS custom, clock + banner
- [Extras](configuration/extras.md) — OneDrive, wallpapers, herramientas
