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
- `config.jsonc`: Mismos módulos (logo, workspaces, clock, brillo, claude-agents, pulseaudio, network, vpn, bluetooth, battery)
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

### Widgets TUI flotantes (popup arriba a la derecha)

Cuatro módulos de Waybar abren una TUI como ventana flotante "popup", anclada arriba a la derecha del monitor con foco, en vez de una ventana completa: **Agentes IA** (`custom/claude-agents`, junto a `custom/brillo`), **cliamp** (reproductor de música, en `pulseaudio`), **bluetui** (en `custom/bluetooth`) y **impala** (gestión de Wi-Fi, en `network` — reemplaza a `nmtui`, que no calzaba visualmente con el resto). El backend Wayland en uso día a día es **Hyprland** (no Qtile-Wayland), así que la posición/flotación real se resuelve ahí; las reglas de Qtile se mantienen por las dudas de volver a ese backend.

**Archivos involucrados:**
- `scripts/float-tui-launch.sh` — Lanzador **genérico**, lo usan los cuatro widgets. Uso: `float-tui-launch.sh <class> <titulo> <cols> <rows> <comando...>`. Comportamiento *toggle*: si la ventana de esa clase no existe la abre; si existe y está enfocada la cierra; si existe pero no tiene foco, la trae al frente. Lanza Kitty pidiéndole el tamaño **en celdas** (`-o initial_window_width=<cols>c -o initial_window_height=<rows>c` — calzar en celdas, no en píxeles fijos, evita que el contenido se recorte si cambia la fuente/DPI) y después usa `hyprctl` para reposicionarla en la esquina superior derecha del **monitor donde está el foco** (multi-monitor safe: calcula `monitor.x + monitor.width - ancho_real_ventana - 16px`, con 44px de margen superior para no tapar la barra). Reintenta el posicionamiento 3 veces con pequeños delays porque Hyprland centra las ventanas nuevas de forma asíncrona al mapearlas y puede pisar el primer movimiento. Se calcula por script porque el `move` de `windowrule` de Hyprland no resuelve bien expresiones tipo `100%-N`.
- `scripts/claude-agents-launch.sh` — Wrapper de una línea: llama a `float-tui-launch.sh claude-agents 'Agentes IA' 64 13 bash claude-agents-tui.sh` (64×13 calza exacto con el panel que dibuja `claude-agents-tui.sh`).
- `scripts/claude-agents-status.sh` — Se ejecuta cada 30s (`return-type: json`). Lee `~/.claude/usage-cache.json` y muestra un ícono Nerd Font (`󰚩`) + el % de uso de la ventana de 5h de la suscripción. Clase CSS `warning`/`critical` según el %, igual que el criterio de colores del statusline (`~/.claude/statusline-command.sh`).
- `scripts/claude-agents-tui.sh` — Dashboard estilo btop (panel con bordes finos, medidores de barras de bloques) con el uso de la suscripción de **Claude Code** (5h/7d) y el **contexto de la última sesión** (con el nombre de carpeta/proyecto, tomado de `session_dir` en el cache, para que quede claro a qué sesión corresponde). Atajos: `c` Claude Code, `o` opencode, `r` refrescar, `q`/`Esc` cerrar. Sin dependencias externas (solo bash + `jq` + `sed`). Toma el color primario desde `qtile/current_theme.json` (`.primary`) para integrarse con el tema activo. La última línea del panel (`bottom_border`) se imprime **sin** salto de línea final a propósito: en una terminal de exactamente 13 filas, ese `\n` sobrante fuerza un scroll de 1 y el borde superior desaparece de la vista.
- `~/.claude/statusline-command.sh` — Además de renderizar el statusline de Claude Code, escribe `~/.claude/usage-cache.json` (`five_hour_pct`, `seven_day_pct`, resets, `context_pct`, `session_dir`, `updated_at`) en cada invocación, que es lo que consume `claude-agents-tui.sh`/`claude-agents-status.sh`. El % se actualiza solo mientras se usa Claude Code (no hay polling activo por fuera de una sesión).
- `hypr/hyprland.conf` — Un `windowrule` por clase (`claude-agents`, `cliamp`, `bluetui`, `impala`): `float on`, `pin on` (visible en todos los workspaces) y `opacity 0.97 override`. El tamaño y la posición NO se fijan acá (ver por qué arriba) — los resuelve `float-tui-launch.sh`.
- `qtile/modules/layouts.py` / `qtile/modules/hooks.py` — Equivalente para el backend Qtile-Wayland (no usado actualmente, se mantiene por paridad), solo para `claude-agents`: `Match(wm_class="claude-agents")` en `floating_layout` + hook `float_widgets` con `FLOAT_GEOMETRY`.

**Tamaños usados** (columnas × filas): Agentes IA 64×13 (fijo, calza con la TUI propia), cliamp 100×32, bluetui 90×28, impala 90×28.

**Comportamiento:** click abre la TUI correspondiente como ventana flotante en la esquina superior derecha del monitor activo (no ventana completa); un segundo click la cierra; si perdió el foco, la trae al frente.

**Pendiente:** `impala` (TUI de Wi-Fi, mismo autor que `bluetui` → mismo estilo visual) todavía no está instalado. Instalar con `sudo pacman -S impala`.

**Para agregar otro widget TUI flotante:** alcanza con (1) sumar un `windowrule` de 3 líneas en `hyprland.conf` para la clase elegida, y (2) apuntar el `on-click` del módulo a `bash float-tui-launch.sh <clase> <título> <cols> <rows> <comando>` — no hace falta tocar el lanzador genérico.

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
