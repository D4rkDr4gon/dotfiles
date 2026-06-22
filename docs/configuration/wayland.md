# Wayland -- Migración y Arquitectura

## Overview

El entorno soporta **3 modos de sesión** desde LightDM:

| Sesión | Backend | WM |
|--------|---------|----|
| **Qtile** | X11 | Qtile |
| **Qtile (Wayland)** | Wayland | Qtile |
| **Hyprland** | Wayland | Hyprland |

Qtile 0.36+ soporta Wayland nativamente a través de wlroots. Hyprland es un compositor Wayland nativo con animaciones y alto rendimiento. Ambos WMs comparten la misma barra (Waybar), launcher (Rofi), notificaciones (Dunst) y herramientas (grim+slurp, gtklock).

Ver [Hyprland](hyprland.md) para la configuración detallada de Hyprland.

## Triple-Backend Architecture

```mermaid
graph TB
    subgraph Entry["Session Selection (LightDM)"]
        X11[Qtile → X11 Session]
        WL[Qtile (Wayland) → Wayland Session]
        HP[Hyprland → Wayland Session]
    end

    subgraph Config["Qtile Config"]
        KY[keys.py, groups.py, layouts.py, mouse.py]
        SC[screens.py]
    end

    subgraph HyprConfig["Hyprland Config"]
        HC[hyprland.conf]
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

    subgraph WLStack["Qtile Wayland Backend"]
        W_WB[Waybar]
        W_SB[swaybg / Qtile wallpaper]
        W_GS[grim + slurp]
        W_LC[gtklock]
        W_WR[wlr-randr]
    end

    subgraph HyprStack["Hyprland Backend"]
        H_WB[Waybar]
        H_WP[hyprpaper wallpaper]
        H_GS[grim + slurp]
        H_LC[gtklock]
        H_WR[wlr-randr]
    end

    subgraph Shared["Shared (all backends)"]
        S_DN[Dunst]
        S_KT[Kitty + wayland flag]
        S_RF[Rofi 2.0+ native Wayland]
        S_ZSH[Zsh, Neovim, Thunar, Firefox]
        S_TH[Theme system]
    end

    X11 --> X11Stack
    WL --> WLStack
    HP --> HyprStack
    X11 --> Shared
    WL --> Shared
    HP --> Shared
    Config --> X11
    Config --> WL
    HyprConfig --> HP
```

## Componente por Backend

| Componente | X11 (Qtile) | Qtile Wayland | Hyprland |
|---|---|---|---|---|
| **Barra** | Polybar | Waybar | Waybar |
| **Compositor** | Picom (GLX, blur) | No necesario | No necesario (nativo) |
| **Wallpaper** | Nitrogen | Qtile `Screen(wallpaper=...)` | hyprpaper |
| **Lock screen** | betterlockscreen | gtklock | gtklock |
| **Screenshots** | Flameshot | grim + slurp | grim + slurp |
| **Monitores** | xrandr | wlr-randr | wlr-randr |
| **Idle/DPMS** | xset | swayidle | hypridle |
| **Portapapeles** | copyq | wl-clipboard | wl-clipboard |

## Hooks (Autostart)

En `qtile/modules/hooks.py` (Qtile) y `hypr/hyprland.conf` (Hyprland):

**Qtile (hooks.py):**
```python
is_wayland = 'WAYLAND_DISPLAY' in os.environ
if is_wayland:
    # Inicia Waybar + Dunst
else:
    # xset + Nitrogen + Polybar + Picom + Dunst
```

**Hyprland (hyprland.conf):**
```conf
exec-once = waybar
exec-once = dunst
exec-once = hyprpaper
```

## Scripts con Detección de Backend

| Script | X11 (Qtile) | Qtile Wayland | Hyprland |
|---|---|---|---|---|
| `display-monitors.sh` | `xrandr` | `wlr-randr` | `wlr-randr` |
| `lock-screen.sh` | `lock-screen` (C binary) | `gtklock` | `gtklock` |
| `screenshot.sh` | `flameshot gui` | `grim + slurp` | `grim + slurp` |
| `barupdate.sh` | `polybar/launch.sh` | `waybar/launch.sh` | `waybar/launch.sh` |
| `theme-switch.sh` | Polybar reload | Waybar + Qtile set_wallpaper | Waybar + hyprpaper |

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
