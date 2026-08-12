# Hyprland — Window Manager (Alternativo)

## Overview

Hyprland es un compositor Wayland dinámico con tiling, altamente personalizable y con animaciones nativas. Está configurado para **replicar los mismos keybindings, workspaces y comportamiento general que Qtile**, permitiendo elegir en el login cuál usar sin interferencias.

### Diferencias con Qtile

| Aspecto | Qtile (Wayland) | Hyprland |
|---------|----------------|----------|
| **Config** | Python (`config.py`) | Hyprlang (`hyprland.conf`) |
| **Layouts** | Columns, MonadTall, Stack | Dwindle, Master, passthrough (flotante) |
| **Animaciones** | No nativas | Nativas, configurables |
| **Blur/Transparencia** | Por app vía hooks | `windowrulev2` global |
| **Wallpaper** | Qtile `Screen(wallpaper=...)` | `hyprpaper` (daemon separado) |
| **Barra** | Waybar | Waybar (compartido) |
| **Launcher** | Rofi | Rofi (compartido) |
| **Notificaciones** | Dunst | Dunst (compartido) |
| **Lock screen** | gtklock | gtklock (compartido) |
| **Screenshots** | grim+slurp | grim+slurp (compartido) |

## Arquitectura Dual-WM

```
LightDM
├── Qtile (Wayland) → usa qtile/ + scripts qtile-*
└── Hyprland         → usa hypr/ + scripts dual-WM (action-menu, workspace-switcher...)
```

Los scripts compartidos detectan el WM activo via `$HYPRLAND_INSTANCE_SIGNATURE`:

```bash
if [ -n "$HYPRLAND_INSTANCE_SIGNATURE" ]; then
    # Comportamiento Hyprland
else
    # Comportamiento Qtile
fi
```

## Keybindings

**Mod key** = Super (Windows) / `mod4`

### Lanzar Aplicaciones

| Atajo | Acción |
|-------|--------|
| `Mod + Enter` | Terminal (Kitty) |
| `Mod + Space` | App launcher (Rofi) |
| `Mod + B` | Firefox |
| `Mod + F` | Thunar |
| `Mod + O` | Obsidian |
| `Mod + P` | Bitwarden |
| `Mod + S` | Sublime Text |
| `Mod + V` | CopyQ |

### Gestión de Ventanas

| Atajo | Acción |
|-------|--------|
| `Mod + Q` | Cerrar ventana |
| `Mod + Shift + F` | Fullscreen |
| `Mod + T` | Float toggle |
| `Mod + Shift + Arrows` | Mover ventana |
| `Mod + Ctrl + Arrows` | Redimensionar |
| `Mod + Tab` | Siguiente ventana |
| `Mod + N` | Toggle split layout |

### Workspaces

| Atajo | Acción |
|-------|--------|
| `Mod + 1` | Ir a workspace 1 |
| `Mod + 2` | Ir a workspace 2 |
| `Mod + 3` | Ir a workspace 3 |
| `Mod + 4` | Ir a workspace 4 |
| `Mod + 5` | Ir a workspace 5 |
| `Mod + 6` | Ir a workspace 6 |
| `Mod + Shift + 1-6` | Mover ventana al workspace N |
| `Ctrl + Tab` | Siguiente workspace |
| `Ctrl + Shift + Tab` | Workspace anterior |

### Sistema

| Atajo | Acción |
|-------|--------|
| `Mod + Ctrl + R` | Recargar Hyprland + Waybar |
| `Mod + L` | Action menu (Lock/Reboot/Poweroff/Logout) |
| `Mod + Shift + Space` | Settings menu (Rofi) |

### Hardware / Multimedia

| Atajo | Acción |
|-------|--------|
| `XF86AudioRaiseVolume` | Subir volumen +5% |
| `XF86AudioLowerVolume` | Bajar volumen -5% |
| `XF86AudioMute` | Silenciar |
| `XF86AudioMicMute` | Silenciar micrófono |
| `XF86MonBrightnessUp` | Brillo +10% |
| `XF86MonBrightnessDown` | Brillo -10% |
| `XF86AudioPlay` | Play/Pause |
| `XF86AudioNext` | Siguiente |
| `XF86AudioPrev` | Anterior |
| `Print` | Screenshot (grim+slurp) |
| `Mod + Shift + S` | Screenshot |

## Workspaces

Misma semántica que Qtile (6 workspaces):

| # | Icono | Nombre |
|---|-------|--------|
| 1 |  | Workspace 1 |
| 2 |  | Workspace 2 |
| 3 |  | Workspace 3 |
| 4 |  | Workspace 4 |
| 5 |  | Workspace 5 |
| 6 |  | Workspace 6 |

## Autostart (exec-once)

Equivalente a `hooks.py` de Qtile:

```conf
exec-once = waybar
exec-once = dunst
exec-once = hyprpaper
```

## Window Rules

Reglas de flotación y opacidad vía `windowrulev2`, equivalente a `floating_layout` + hooks de Qtile:

### Ventanas flotantes
- pavucontrol, blueman-manager, nm-connection-editor
- pinentry, ssh-askpass, confirmreset, branchdialog

### Opacidad
- Kitty: 0.90
- Obsidian: 0.92
- Sublime Text: 0.92
- Thunar: 0.92
- Rofi: 0.75
- Dunst: 0.85

## Wallpaper

Usa `hyprpaper` como daemon. El wallpaper se actualiza automáticamente al cambiar de tema vía `theme-switch.sh`.

## Archivos de Configuración

**Ubicación**: `~/.config/hypr/` (symlink via `stow` desde `~/dotfiles/hypr/`)

```
~/.config/hypr/
├── hyprland.conf          # Config principal
├── hyprpaper.conf         # Wallpaper daemon
└── scripts/
    ├── hypr-workspaces.py       # Workspace indicator para Waybar
    └── hypr-workspace-switch.sh # Switch workspaces con scroll
```

## Instalación

```bash
# Manual
sudo pacman -S hyprland hyprpaper hyprlock hypridle xdg-desktop-portal-hyprland
cd ~/dotfiles && stow -t ~/.config/hypr hypr

# O via instalador automatizado
bash ~/dotfiles/automat/install/install-hyprland.sh
```

## Solución de Problemas

| Síntoma | Causa | Solución |
|---------|-------|----------|
| Pantalla negra al iniciar | GPU no soportada | `export WLR_NO_HARDWARE_CURSORS=1 && Hyprland` |
| Cursor invisible | Bug de amdgpu | Agregar `env = WLR_NO_HARDWARE_CURSORS,1` en hyprland.conf |
| Wallpaper no aparece | hyprpaper no corriendo | `killall hyprpaper; hyprpaper &; hyprctl hyprpaper wallpaper ",/ruta/al/wallpaper"` |
| Waybar muestra workspaces vacíos | Script de workspaces no detecta Hyprland | Verificar `$HYPRLAND_INSTANCE_SIGNATURE` |
| Atajo no funciona | Binding incorrecto | Verificar sintaxis en `hyprland.conf` |
