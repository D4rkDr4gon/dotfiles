# Sistema de Temas

## Architecture

El sistema de temas permite cambiar la apariencia completa del entorno con un solo comando. Cada tema es un directorio con un `theme.json` que define colores y wallpaper. El `theme-switch.sh` actua como orquestrador central: parsea el JSON, genera archivos de configuracion especificos por componente, y dispara recargas en vivo sin necesidad de logout.

Soporta tanto el backend X11 (Polybar) como Wayland (Waybar) simultáneamente. El cambio de wallpaper está optimizado usando `feh` (X11, ~50ms) en lugar de recargar todo el config de Qtile.

## Theme Data Distribution Map

```mermaid
graph TB
    subgraph Source["Source"]
        TJ[themes/&lt;name&gt;/theme.json]
    end

    subgraph Pipeline["theme-switch.sh"]
        TS[Parse theme.json]
        TS -->|jq| VC[Validate colors]
        VC -->|apply_theme_config| GEN[Generate configs]
        GEN -->|_set_wallpaper_direct| WP[Set Wallpaper Direct]
        WP -->|reload_components| REL[Live Reload]
    end

    subgraph Targets["Component Configs"]
        PC[polybar/colors.ini<br/>primary, secondary<br/>background, foreground, chip-*]
        WC[waybar/theme.css<br/>@define-color vars]
        KC[kitty/colors.conf<br/>foreground, background<br/>cursor, selection, tabs]
        ZC[~/.zsh_colors<br/>COLOR_PRIMARY, COLOR_ACCENT<br/>COLOR_BG, COLOR_FG]
        QT[qtile/current_theme.json<br/>Active theme state]
        SC[qtile/modules/screens.py<br/>Wallpaper path]
        GC[gtk-3.0/gtk.css<br/>@define-color CSS vars<br/>Thunar + GTK3 apps]
        OC[opencode.jsonc<br/>Agent colors]
        HC[~/.config/hyprfm/themes/dotfiles.toml<br/>crust/mantle/base/surface/overlay<br/>text/subtext/muted, accent, success/warning/error]
    end

    subgraph Reload["Live Reload"]
        WPW[Wallpaper: feh --bg-fill<br/>~50ms en X11<br/>o Qtile set_wallpaper directo]
        PR[Polybar: launch.sh]
        WR[Waybar: launch.sh]
        KR[Kitty: kitty @ set-colors]
        ZR[Zsh: source on next session]
        TH[Thunar: thunar -q<br/>re-abrir para nuevo estilo]
    end

    TJ --> TS
    GEN --> PC
    GEN --> WC
    GEN --> KC
    GEN --> ZC
    GEN --> QT
    GEN --> SC
    GEN --> GC
    GEN --> OC
    GEN --> HC
    SC --> WPW
    PC --> PR
    WC --> WR
    KC --> KR
    ZC --> ZR
    GC --> TH
```

**Sources:** `scripts/theme-switch.sh`, `gtk-3.0/gtk.css`, `opencode/opencode.jsonc`

## Pipeline Overview

`theme-switch.sh` sigue una ruta de ejecucion lineal:

1. **Dependency Check**: Verifica que `jq` este instalado; advierte si `feh` no está presente (recomendado para wallpaper rápido)
2. **Theme Validation**: Confirma que el directorio del tema y `theme.json` existan
3. **Config Generation** (`apply_theme_config`): Extrae hex codes y escribe en formatos especificos por componente
4. **Wallpaper Direct** (`_set_wallpaper_direct`): Aplica el wallpaper de forma directa sin recargar Qtile (usa `feh` si está instalado, o `qtile cmd-obj set_wallpaper` como fallback)
5. **Live Reload** (`reload_components`): Notifica a cada componente para que aplique los cambios (kitty colors, waybar/polybar, thunar)

## Configuration Generation

| Componente | Target File | Formato | Variables Inyectadas |
|------------|-------------|---------|---------------------|
| Polybar | `polybar/colors.ini` | INI | `primary`, `secondary`, `background`, `foreground`, `chip-*` |
| Waybar | `waybar/theme.css` | GTK @define-color | `primary`, `secondary`, `background rgba`, `chip-*` |
| Kitty | `kitty/colors.conf` | Key-Value | `foreground`, `background`, `cursor`, `cursor_text_color`, `selection`, `tabs`, `url_color`, `borders`, `statusbar` |
| Zsh | `~/.zsh_colors` | Shell Export | `COLOR_PRIMARY`, `COLOR_ACCENT`, `COLOR_BG`, `COLOR_FG` |
| Fastfetch | `fastfetch/colors.json` | JSON | `primary`, `secondary`, `background`, `foreground` |
| GTK3 | `gtk-3.0/gtk.css` | CSS @define-color | `theme_bg`, `theme_fg`, `theme_primary`, `theme_secondary`, `theme_selected_bg`, `theme_selected_fg` |
| opencode | `opencode.jsonc` | JSON (sed) | `build` → primary, `plan` → secondary, `general` → foreground, `explore` → primary |
| Qtile | `qtile/modules/screens.py` | Python (sed) | `wallpaper` path |
| HyprFM | `~/.config/hyprfm/themes/dotfiles.toml` | TOML | `base` = `background` (idéntico a kitty); `crust`/`mantle`/`surface`/`overlay` derivados de `background` mezclado con negro/blanco (`hex_blend`); `text`, `subtext`/`muted` (blend con foreground), `accent` = `primary`, `success`/`warning`/`error` = `status_ok`/`status_warn`/`status_error` |

## Live Component Reloading

Una vez escritos los archivos, los cambios se aplican sin logout:

1. **Wallpaper** (X11): `_set_wallpaper_direct()` intenta `feh --bg-fill` primero (~50ms). Si `feh` no está instalado, usa `qtile cmd-obj -o screen N -f set_wallpaper` como fallback (solo aplica wallpaper, sin recargar todo el config de Qtile)
2. **Wallpaper** (Qtile Wayland): `_set_wallpaper_direct()` usa `qtile cmd-obj -o screen N -f set_wallpaper` directamente. Qtile Wayland lo implementa con Cairo + wlr-layer-shell — pinta el wallpaper en vivo, no requiere `reload_config` (~200ms)
3. **Wallpaper** (Hyprland): `_set_wallpaper_direct()` usa `hyprctl hyprpaper wallpaper` via hyprpaper IPC. `reload_components()` reinicia hyprpaper si es necesario. Ambas rutas leen el wallpaper desde `current_theme.json` (fuente única)
4. **Kitty**: Usa `kitty @ set-colors` para actualizar todas las terminales activas al instante
5. **Polybar** (X11): Ejecuta `launch.sh` para matar y reiniciar la barra con el nuevo `colors.ini`
6. **Waybar** (Wayland): Detecta `XDG_SESSION_TYPE=wayland` y ejecuta `launch.sh` con el nuevo `theme.css`
6. **Zsh**: Las sesiones futuras hacen source de `~/.zsh_colors` via `zsh/modules/theme.zsh`
7. **Thunar**: Si está abierto, se cierra con `thunar -q` para que al re-abrirlo tome los nuevos estilos GTK CSS
8. **opencode**: Los colores de agentes en `opencode.jsonc` se actualizan via `sed` (no requiere recarga)
9. **HyprFM**: No se recarga en caliente — hay que cerrarlo y re-abrirlo (ver nota de CWD más abajo) para que tome el `dotfiles.toml` actualizado

**Nota:** GTK CSS (`gtk-3.0/gtk.css`) no se recarga en caliente — Thunar debe cerrarse y re-abrirse. `theme-switch.sh` lo maneja automáticamente si el proceso está activo.

**Nota HyprFM — self-heal de `config.toml`:** HyprFM trae de fábrica `theme = 'catppuccin-mocha'` en su propio `~/.config/hyprfm/config.toml`, generado la primera vez que corre (no antes). Como ese archivo puede no existir todavía la primera vez que se corre `theme-switch.sh` en una instalación nueva, el script no fuerza `theme = 'dotfiles'` en el instalador — en cambio, `apply_theme_config` lo pisa de forma idempotente en **cada** cambio de tema si el archivo ya existe. Así, apenas HyprFM se ejecuta una vez (generando su config con el default de fábrica), el siguiente `theme <nombre>` lo corrige solo, sin pasos manuales.

**Nota HyprFM — bug de CWD:** `hyprfm-git` (0.5.3) ignora su tema custom (`theme.toml`) y cae al `catppuccin-mocha` de fábrica cuando el proceso arranca con `cwd` exactamente igual a `$HOME` — que es como Hyprland ejecuta *todos* los binds (`exec, ...`) por defecto. Por eso el keybind `$mainMod, F` en `hypr/hyprland.conf` no llama a `hyprfm` directo, sino `cd /tmp && hyprfm`: cualquier `cwd` distinto de `$HOME` esquiva el bug. Es un bug del binario (upstream), no de esta config — si una futura versión de `hyprfm-git` lo arregla, se puede volver a `exec, hyprfm` a secas.

**Nota Hyprland:** El wallpaper en Hyprland se maneja via `hyprpaper` (daemon separado). `theme-switch.sh` detecta automáticamente la presencia de `$HYPRLAND_INSTANCE_SIGNATURE` y aplica el wallpaper via `hyprctl hyprpaper wallpaper` en lugar de `qtile cmd-obj`. Ver [`theme-switch.sh`](../scripts/theme-switch.sh) líneas 374-402.

## Optimización de Wallpaper

El principal cuello de botella del cambio de temas era la recarga completa del config de Qtile (`qtile cmd-obj -o cmd -f reload_config`), que reevalúa todos los módulos Python (barras, widgets, screens, layouts) solo para cambiar el wallpaper.

### Flujo optimizado

```
apply_theme_config()  →  _set_wallpaper_direct()  →  reload_components()
                              ↕
               ┌──────────────────────────────┐
               │  1. feh --bg-fill (X11, ~50ms) │
               │  2. qtile set_wallpaper        │
               │     (fallback, sin reload)     │
               └──────────────────────────────┘
```

### `_set_wallpaper_direct()`

Estrategia de dos niveles:

| Nivel | Método | Tiempo | Requisito |
|-------|--------|--------|-----------|
| 1 (rápido X11) | `feh --bg-fill` | ~50ms | `feh` instalado |
| 2 (Qtile Wayland) | `qtile cmd-obj -o screen N -f set_wallpaper` | ~200ms | Qtile en ejecución |
| 3 (Hyprland) | `hyprctl hyprpaper wallpaper` | ~100ms | Hyprland + hyprpaper |

**`feh`** es un visor de imágenes mínimo que puede establecer el wallpaper de X11 directamente a través del protocolo `_XROOTMAP_ID`. No depende de Qtile ni de ningún entorno de escritorio, y es significativamente más rápido que pasar por Cairo (que Qtile usa internamente).

**Hyprland** usa `hyprctl hyprpaper wallpaper` que se comunica con el daemon hyprpaper via IPC. El wrapper `start-hyprpaper.sh` (v2 dinámico) genera el config desde `current_theme.json` y reintenta hasta 5 veces si el socket de Hyprland no está listo.

### Recomendación

```bash
sudo pacman -S feh
```

Si `feh` no está instalado, `theme-switch.sh` muestra una advertencia y usa el método fallback de Qtile. La experiencia sigue siendo funcional, pero el cambio de wallpaper será ~4x más lento.

**Nota:** En Qtile Wayland este método usa `qtile cmd-obj -o screen N -f set_wallpaper` directamente — Qtile Wayland lo implementa con Cairo + wlr-layer-shell y aplica el wallpaper en vivo sin recargar la configuración. En Hyprland usa `hyprctl hyprpaper wallpaper` via el daemon hyprpaper. `feh` solo funciona en X11.

## Uso

```bash
# Desde terminal
theme at-at

# Lista de temas disponibles
theme                  # Muestra el listado

# Desde Rofi
Mod + Shift + Space  ->  Themes
```

## Temas Disponibles

| Tema | Wallpaper | Paleta | Primary |
|------|-----------|--------|---------|
| **Brown AT-AT** | `at-at.png` | Marron/gris, tonos calidos | `#a0522d` |
| **Red Japan** | `japan-wallpaper.jpg` | Rojo oscuro, estilo japones | `#d32f2f` |
| **Gray Terminal** | `wallpaper hacker.jpg` | Grises, estilo terminal | `#808080` |
| **Green Geek** | `hacker-setup-dark.jpg` | Verde terminal, estilo geek | `#00ff00` |
| **Purple Sky** | `wallpaper_city.jpg` | Violeta, cielo nocturno | `#8a2be2` |
| **Ciberpunk** | `wallpaper_city_sci-fi.jpg` | Neon magenta/purple | `#ff00ff` |
| **Chill Lofi** | `wallpaper_Creativity_Room.jpg` | Tonos tierra calidos | `#d2b48c` |
| **Data Center** | `Wallpaper data center.jpg` | Cian/verde tecnologia | `#00ced1` |

## Estructura de un Tema

Cada tema vive en `themes/<nombre>/theme.json`:

> **Nota**: `theme.json` es JSON plano y se lee con `jq`, que no expande `$HOME`.
> El campo `wallpaper` necesita una ruta absoluta real. Si preferis un wallpaper
> del sistema, usa una ruta bajo `/usr/share/backgrounds/` (como hacen la mayoria
> de los temas incluidos); si preferis uno dentro del repo, usa el placeholder
> `__HOME__` (p. ej. `__HOME__/dotfiles/recursos/wallpapers/...`), que `install.sh`
> reemplaza por tu `$HOME` real durante la instalacion.

```json
{
  "name": "AT-AT",
  "wallpaper": "__HOME__/dotfiles/recursos/wallpapers/at-at.png",
  "colors": {
    "primary": "#a0522d",
    "secondary": "#8b4513",
    "background": "#1a1a1a",
    "foreground": "#d4c5a9",
    "chip": {
      "battery": "#a0522d",
      "bluetooth": "#4a90d9",
      "wlan": "#4a90d9",
      "audio": "#a0522d"
    }
  }
}
```

### Campos

| Campo | Descripcion |
|-------|-------------|
| `name` | Nombre del tema |
| `wallpaper` | Ruta absoluta al wallpaper |
| `colors.primary` | Color principal (polybar/waybar, prompt, layouts) |
| `colors.secondary` | Color secundario |
| `colors.background` | Color de fondo |
| `colors.foreground` | Color de texto |
| `colors.chip` | Colores especificos para modulos de la barra |

## Crear un Nuevo Tema

1. Crear directorio: `mkdir themes/mi-tema`
2. Elegir wallpaper en `recursos/wallpapers/` (o agregar uno nuevo)
3. Crear `theme.json` siguiendo la estructura de arriba
4. Usar: `theme mi-tema`

El tema se integrara automaticamente en el listado de Rofi y generara config tanto para Polybar (X11) como Waybar (Wayland).
