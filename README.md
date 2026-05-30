# D4rkDr4g0n Dotfiles

![Distro](https://img.shields.io/badge/Distro-Arch%20%7C%20Kali-red?style=for-the-badge&logo=linux)
![WM](https://img.shields.io/badge/WM-Qtile-blue?style=for-the-badge&logo=python)
![Display Server](https://img.shields.io/badge/X11%20%7C%20Wayland-dual-brightgreen?style=for-the-badge)
![License](https://img.shields.io/badge/License-MIT-orange?style=for-the-badge)

**Lucciano Campassi** — *Ciberseguridad & Desarrollo*

Entorno de trabajo personalizado con estetica cyberpunk, optimizado para pentesting y desarrollo. Basado en Qtile (X11 + Wayland) + Polybar/Waybar + Kitty + Zsh, con sistema de temas dinamicos y flujo de trabajo 100% controlado por teclado.

---

## Quick Start

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/D4rkDr4g0n/dotfiles/main/install.sh)
```

---

## Documentacion

| Seccion | Descripcion |
|---------|-------------|
| [Overview](docs/overview.md) | Arquitectura general, componentes, file tree completo |
| [Instalacion](docs/installation.md) | Guia de instalacion desde cero, flags, entity mapping |
| [Atajos de Teclado](docs/keybindings.md) | Todos los shortcuts, aliases y bindings |
| [Sistema de Temas](docs/themes.md) | Temas dinamicos, pipeline, data flow architecture |
| [Automatizaciones](docs/automations.md) | Scripts de instalacion, vault, AI, workflow utilities |

### Configuracion por Componente

| Componente | Descripcion |
|------------|-------------|
| [Qtile](docs/configuration/qtile.md) | Window manager, grupos, layouts, hooks, dual-backend |
| [Polybar](docs/configuration/polybar.md) | Barra de estado X11, modulos, colores |
| [Wayland](docs/configuration/wayland.md) | Migración Wayland, Waybar, swaylock, grim+slurp |
| [Kitty](docs/configuration/kitty.md) | Terminal, colores, keybindings, Wayland |
| [Zsh](docs/configuration/zsh.md) | Shell, aliases, plugins, prompt |
| [Rofi](docs/configuration/rofi.md) | Launcher, temas, scripts |
| [Picom](docs/configuration/picom.md) | Compositor X11, blur, animaciones |
| [Dunst](docs/configuration/dunst.md) | Notification daemon + center |
| [Editores](docs/configuration/editors.md) | Neovim (LazyVim) y Sublime Text |
| [Fastfetch](docs/configuration/fastfetch.md) | System info display |
| [Thunar](docs/configuration/thunar.md) | File manager, custom actions |
| [Lock Screen](docs/configuration/lock-screen.md) | swaylock / betterlockscreen |
| [opencode](docs/configuration/opencode.md) | AI assistant, skills personalizadas |
| [Extras](docs/configuration/extras.md) | OneDrive, wallpapers, herramientas |

---

## Stack Tecnologico

```
WM:          Qtile (Python) — X11 + Wayland
Barra:       Polybar (X11) / Waybar (Wayland)
Terminal:    Kitty (X11 + Wayland nativo)
Shell:       Zsh + powerlevel10k
Launcher:    Rofi (X11 + Wayland nativo)
Compositor:  Picom (X11) / wlroots (Wayland)
Notifications: Dunst + Rofi notification center
Lock Screen: betterlockscreen (X11) / swaylock (Wayland)
Screenshots: Flameshot (X11) / grim+slurp (Wayland)
Editores:    Neovim (LazyVim) / Sublime Text
File Mgr:    Thunar
Info:        Fastfetch
AI:          opencode (skills personalizadas)
Cloud:       OneDrive
Automation:  n8n
```

---

## Licencia

Distribuido bajo licencia **MIT**. Ver [LICENSE](LICENSE) para mas informacion.

---

Desarrollado por **D4rkDr4g0n** — Lucciano Campassi
