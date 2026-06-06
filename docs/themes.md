# Sistema de Temas

## Architecture

El sistema de temas permite cambiar la apariencia completa del entorno con un solo comando. Cada tema es un directorio con un `theme.json` que define colores y wallpaper. El `theme-switch.sh` actua como orquestrador central: parsea el JSON, genera archivos de configuracion especificos por componente, y dispara recargas en vivo sin necesidad de logout.

Soporta tanto el backend X11 (Polybar) como Wayland (Waybar) simultáneamente.

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
        GEN -->|reload_components| REL[Live Reload]
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
    end

    subgraph Reload["Live Reload"]
        PR[Polybar: launch.sh]
        WR[Waybar: launch.sh]
        KR[Kitty: kitty @ set-colors]
        QR[Ctile: reload_config]
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
    PC --> PR
    WC --> WR
    KC --> KR
    QT --> QR
    SC --> QR
    ZC --> ZR
    GC --> TH
```

**Sources:** `scripts/theme-switch.sh`, `gtk-3.0/gtk.css`, `opencode/opencode.jsonc`

## Pipeline Overview

`theme-switch.sh` sigue una ruta de ejecucion lineal:

1. **Dependency Check**: Verifica que `jq` este instalado
2. **Theme Validation**: Confirma que el directorio del tema y `theme.json` existan
3. **Config Generation** (`apply_theme_config`): Extrae hex codes y escribe en formatos especificos por componente
4. **Live Reload** (`reload_components`): Notifica a cada componente para que aplique los cambios

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

## Live Component Reloading

Una vez escritos los archivos, los cambios se aplican sin logout:

1. **Kitty**: Usa `kitty @ set-colors` para actualizar todas las terminales activas al instante
2. **Qtile**: Llama `qtile cmd-obj -o cmd -f reload_config` para re-leer los módulos Python
3. **Polybar** (X11): Ejecuta `launch.sh` para matar y reiniciar la barra con el nuevo `colors.ini`
4. **Waybar** (Wayland): Detecta `XDG_SESSION_TYPE=wayland` y ejecuta `launch.sh` con el nuevo `theme.css`
5. **Zsh**: Las sesiones futuras hacen source de `~/.zsh_colors` via `zsh/modules/theme.zsh`
6. **Thunar**: Si está abierto, se cierra con `thunar -q` para que al re-abrirlo tome los nuevos estilos GTK CSS
7. **opencode**: Los colores de agentes en `opencode.jsonc` se actualizan via `sed` (no requiere recarga)

**Nota:** GTK CSS (`gtk-3.0/gtk.css`) no se recarga en caliente — Thunar debe cerrarse y re-abrirse. `theme-switch.sh` lo maneja automáticamente si el proceso está activo.

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

```json
{
  "name": "AT-AT",
  "wallpaper": "/home/lcampassi/dotfiles/recursos/wallpapers/at-at.png",
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
