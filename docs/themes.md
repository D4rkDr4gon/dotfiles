# Sistema de Temas

## Arquitectura

El sistema de temas permite cambiar la apariencia completa del entorno con un solo comando. Cada tema es un directorio con un `theme.json` que define colores y wallpaper.

### Como funciona

1. `scripts/theme-switch.sh` lee el `theme.json` del tema seleccionado
2. Actualiza los archivos de configuracion de cada componente:
   - `polybar/colors.ini` -- colores de la barra
   - `kitty/colors.conf` -- colores del terminal
   - `~/.zsh_colors` -- colores del prompt
   - `qtile/current_theme.json` -- tema activo
   - `qtile/modules/screens.py` -- wallpaper
3. Recarga los componentes: polybar, kitty, qtile

### Uso

```bash
# Desde terminal
theme at-at

# Lista de temas disponibles
theme                  # Muestra el listado

# Desde Rofi
Mod + Shift + Space  ->  Themes
```

## Temas Disponibles

| Tema | Wallpaper | Paleta |
|------|-----------|--------|
| **AT-AT** | `at-at.png` | Marron/gris, tonos calidos |
| **Kali Red** | `wallpaper_dark_spaceship.jpg` | Rojo oscuro, sangre |
| **Hacker** | `wallpaper hacker.jpg` | Verde matrix sobre negro |
| **Hacker Setup** | `hacker-setup-dark.jpg` | Beige/teal calido |
| **City** | `wallpaper_city.jpg` | Rosa/purpura, ciudad |
| **City Sci-Fi** | `wallpaper_city_sci-fi.jpg` | Teal/gris, sci-fi |
| **Creativity Room** | `wallpaper_Creativity_Room.jpg` | Tonos tierra calidos |
| **Data Center** | `Wallpaper data center.jpg` | Cian/verde tecnologia |

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

- **name**: Nombre del tema
- **wallpaper**: Ruta absoluta al wallpaper
- **colors.primary**: Color principal (utilizado en polybar, prompt, etc.)
- **colors.secondary**: Color secundario
- **colors.background**: Color de fondo
- **colors.foreground**: Color de texto
- **colors.chip**: Colores especificos para modulos de polybar (battery, bluetooth, wlan, audio)

## Crear un Nuevo Tema

1. Crear directorio: `mkdir themes/mi-tema`
2. Crear `theme.json` siguiendo la estructura de arriba
3. Agregar wallpaper en `recursos/wallpapers/`
4. Usar: `theme mi-tema`

El tema se integrara automaticamente en el listado de Rofi.
