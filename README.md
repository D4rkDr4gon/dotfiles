# D4rkDr4g0n Dotfiles

![Distro](https://img.shields.io/badge/Distro-Arch%20%7C%20Kali-red?style=for-the-badge&logo=linux)
![WM](https://img.shields.io/badge/WM-Qtile-blue?style=for-the-badge&logo=python)
![Status](https://img.shields.io/badge/Status-Stable-success?style=for-the-badge)
![License](https://img.shields.io/badge/License-MIT-orange?style=for-the-badge)

**Lucciano Campassi** — *Ciberseguridad & Desarrollo*

Entorno de trabajo personalizado con estetica cyberpunk, optimizado para pentesting y desarrollo. Basado en Qtile + Polybar + Kitty + Zsh, con sistema de temas dinamicos y flujo de trabajo 100% controlado por teclado.

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
| [Qtile](docs/configuration/qtile.md) | Window manager, grupos, layouts, hooks |
| [Polybar](docs/configuration/polybar.md) | Barra de estado, modulos, colores |
| [Kitty](docs/configuration/kitty.md) | Terminal, colores, keybindings |
| [Zsh](docs/configuration/zsh.md) | Shell, aliases, plugins, prompt |
| [Rofi](docs/configuration/rofi.md) | Launcher, temas, scripts |
| [Picom](docs/configuration/picom.md) | Compositor, blur, animaciones |
| [Dunst](docs/configuration/dunst.md) | Notification daemon + center |
| [Editores](docs/configuration/editors.md) | Neovim (LazyVim) y Sublime Text |
| [Fastfetch](docs/configuration/fastfetch.md) | System info display |
| [Thunar](docs/configuration/thunar.md) | File manager, custom actions |
| [opencode](docs/configuration/opencode.md) | AI assistant, skills personalizadas |
| [Extras](docs/configuration/extras.md) | OneDrive, wallpapers, herramientas |

---

## Stack Tecnologico

```
WM:          Qtile (Python)
Barra:       Polybar
Terminal:    Kitty
Shell:       Zsh + powerlevel10k
Launcher:    Rofi (Android-style grid 5x4)
Compositor:  Picom (GLX + dual_kawase blur)
Notifications: Dunst + Rofi notification center
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
