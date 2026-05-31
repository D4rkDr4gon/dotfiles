# Wayland -- Migración y Arquitectura

## Overview

Qtile 0.36+ soporta Wayland nativamente a través de wlroots. El entorno está configurado para funcionar en ambos backends (X11 y Wayland) sin perder estética ni funcionalidad.

La selección del backend se hace desde LightDM:
- **Qtile** → X11 (sesión tradicional)
- **Qtile (Wayland)** → Wayland

## Dual-Backend Architecture

```mermaid
graph TB
    subgraph Entry["Session Selection (LightDM)"]
        X11[Qtile → X11 Session]
        WL[Qtile (Wayland) → Wayland Session]
    end

    subgraph Config["Shared Qtile Config"]
        KY[keys.py, groups.py, layouts.py, mouse.py]
        SC[screens.py]
    end

    subgraph X11Stack["X11 Backend"]
        X_PB[Polybar]
        X_PC[Picom compositor]
        X_NT[Nitrogen wallpaper]
        X_XS[xset DPMS]
        X_FL[Flameshot]
        X_LC[betterlockscreen]
        X_XR[xrandr]
    end

    subgraph WLStack["Wayland Backend"]
        W_WB[Waybar]
        W_SB[swaybg / Qtile wallpaper]
        W_ID[swayidle]
        W_GS[grim + slurp]
        W_SL[swaylock]
        W_WR[wlr-randr]
    end

    subgraph Shared["Shared (both backends)"]
        S_DN[Dunst]
        S_KT[Kitty + wayland flag]
        S_RF[Rofi 2.0+ native Wayland]
        S_ZSH[Zsh, Neovim, Thunar, Firefox]
        S_TH[Theme system]
    end

    X11 --> X11Stack
    WL --> WLStack
    X11 --> Shared
    WL --> Shared
    Config --> X11
    Config --> WL
```

## Componente por Backend

| Componente | X11 | Wayland |
|---|---|---|
| **Barra** | Polybar | Waybar (misma estética: 98% width, 28px, radius 10) |
| **Compositor** | Picom (GLX, blur dual_kawase) | No necesario (wlroots maneja compositing) |
| **Wallpaper** | Nitrogen | Qtile `Screen(wallpaper=...)` |
| **Lock screen** | betterlockscreen / i3lock-color | swaylock (blur + clock) |
| **Screenshots** | Flameshot | grim + slurp (copia a clipboard) |
| **Monitores** | xrandr | wlr-randr |
| **Idle/DPMS** | xset | swayidle (opcional) |
| **Portapapeles** | copyq | wl-clipboard (wl-copy/wl-paste) |

## Hooks (Autostart)

En `qtile/modules/hooks.py`, el autostart detecta automáticamente el backend:

```python
is_wayland = 'WAYLAND_DISPLAY' in os.environ

if is_wayland:
    # Inicia Waybar + Dunst
else:
    # xset + Nitrogen + Polybar + Picom + Dunst
```

## Scripts con Detección de Backend

| Script | X11 | Wayland |
|---|---|---|
| `display-monitors.sh` | `xrandr` | `wlr-randr` |
| `lock-screen.sh` | `lock-screen` (C binary) | `swaylock -f` |
| `screenshot.sh` | `flameshot gui` | `grim -g "$(slurp)" - \| wl-copy` |
| `barupdate.sh` | `polybar/launch.sh` | `waybar/launch.sh` |
| `theme-switch.sh` | Polybar reload | Waybar reload + theme.css |

## Waybar

Waybar reemplaza a Polybar en Wayland. Configurado para verse idéntico:
- `config.jsonc`: Mismos módulos (logo, workspaces, clock, brillo, pulseaudio, network, vpn, bluetooth, battery)
- `style.css`: Misma apariencia (98% width, 28px height, radius 10px, colores del tema activo)
- `theme.css`: Generado por `theme-switch.sh` con `@define-color` (importado por style.css)

### Custom Logo

El módulo `custom/logo` (primer módulo a la izquierda) muestra una imagen personalizada en lugar del ícono Nerd Font de Arch Linux.

**Archivos involucrados:**
- `logo.png` — Imagen (cara/avatar) que se muestra como logo; ubicada en el mismo directorio que el resto de la config de Waybar.
- `config.jsonc` — El `format` se dejó vacío (`"  "`) ya que la imagen se renderiza vía CSS.
- `style.css` — `#custom-logo` usa `background-image: url("logo.png")` con `background-size: contain`, `background-position: center` y `background-repeat: no-repeat`. Tamaño mínimo de 28×28px para coincidir con la altura de la barra.

**Comportamiento:**
- Misma funcionalidad que antes: `on-click` ejecuta el menú de settings de Rofi.
- La imagen se carga desde la ruta relativa al directorio de configuración de Waybar (`~/.config/waybar/`).

Los scripts de VPN y Bluetooth son compartidos con Polybar (no usan X11).

## Paquetes Wayland

```
waybar          wlr-randr       swaybg          grim
slurp           swaylock        swayidle        wl-clipboard
```

Rofi 2.0+ ya soporta Wayland nativamente (no requiere paquete separado).

## Resolución de Problemas

| Síntoma | Posible Causa | Solución |
|---|---|---|
| Waybar no aparece | No está en el autostart | Verificar `hooks.py` |
| Rofi no funciona | Versión antigua | `rofi -v` debe ser ≥ 2.0 |
| Flameshot no funciona en Wayland | Usar grim+slurp | Ya configurado en `screenshot.sh` |
| Wallpaper no se ve | Qtile wallpaper en Wayland | Agregar `swaybg` al autostart |
| Workspaces no se ven en Waybar | Protocolo wlr-workspace | Verificar que Qtile lo soporte |
