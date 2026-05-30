# Atajos de Teclado

**Mod key** = Super (Windows) / `mod4`

---

## Qtile -- Window Manager

### Lanzar Aplicaciones

| Atajo | Accion |
|-------|--------|
| `Mod + Enter` | Terminal (Kitty) |
| `Mod + Space` | App launcher grid 5x4 (Rofi Android-style) |
| `Mod + B` | Navegador (Firefox) |
| `Mod + F` | File manager (Thunar) |
| `Mod + O` | Notas (Obsidian) |
| `Mod + P` | Password manager (Bitwarden) |
| `Mod + S` | Sublime Text |
| `Mod + V` | Clipboard history (CopyQ) |

### Gestion de Ventanas

| Atajo | Accion |
|-------|--------|
| `Mod + Q` | Cerrar ventana |
| `Mod + Shift + F` | Pantalla completa |
| `Mod + T` | Modo flotante |
| `Mod + Shift + Left/Right/Up/Down` | Mover ventana en direccion |
| `Mod + Ctrl + Left/Right/Up/Down` | Redimensionar ventana |
| `Mod + N` | Normalizar tamanos |
| `Alt + Tab` | Ventana siguiente en el stack |
| `Ctrl + Tab` | Siguiente ventana |
| `Ctrl + Shift + Tab` | Ventana anterior |

### Workspaces

| Atajo | Accion |
|-------|--------|
| `Mod + 1` | Ir a NOTES |
| `Mod + 2` | Ir a FILES |
| `Mod + 3` | Ir a DEV |
| `Mod + 4` | Ir a SYS |
| `Mod + 5` | Ir a WEB |
| `Mod + Shift + 1-5` | Mover ventana al workspace N |
| `Mod + Tab` | Siguiente layout / pantalla |

### Sistema

| Atajo | Accion |
|-------|--------|
| `Mod + Ctrl + R` | Recargar Qtile + barra (Polybar en X11, Waybar en Wayland) |
| `Mod + L` | Menu de accion (Suspend/Reboot/Poweroff/Logout) |
| `Mod + Shift + Space` | Settings menu (Rofi) |

### Stack Management

| Atajo | Accion |
|-------|--------|
| `Mod + Alt + S` | Nueva stack |
| `Mod + Alt + D` | Eliminar stack |
| `Mod + Alt + M` | Mover ventana a siguiente stack |
| `Mod + Alt + N` | Mover ventana a stack anterior |
| `Mod + Ctrl + J` | Shuffle ventana abajo |
| `Mod + Ctrl + K` | Shuffle ventana arriba |

### Hardware / Multimedia

| Atajo | Accion |
|-------|--------|
| `XF86AudioRaiseVolume` | Subir volumen +5% |
| `XF86AudioLowerVolume` | Bajar volumen -5% |
| `XF86AudioMute` | Silenciar |
| `XF86AudioMicMute` | Silenciar microfono |
| `XF86MonBrightnessUp` | Brillo +10% |
| `XF86MonBrightnessDown` | Brillo -10% |
| `Print` | Screenshot (Flameshot en X11, grim+slurp en Wayland) |
| `Mod + Shift + S` | Screenshot (Flameshot en X11, grim+slurp en Wayland) |

### Mouse

| Binding | Accion |
|---------|--------|
| `Mod + Click Izq` | Arrastrar ventana flotante |
| `Mod + Click Der` | Redimensionar ventana flotante |
| `Mod + Click Medio` | Traer ventana al frente |

---

## Kitty -- Terminal

| Atajo | Accion |
|-------|--------|
| `Ctrl + Shift + Enter` | Nueva tab |
| `Ctrl + Shift + W` | Cerrar tab |
| `Ctrl + Shift + N` | Renombrar tab |
| `Ctrl + Shift + Space` | Nueva ventana (split) |
| `Ctrl + Shift + Left` | Reducir ancho 5px |
| `Ctrl + Shift + Right` | Aumentar ancho 5px |
| `Ctrl + Shift + Up` | Aumentar alto 5px |
| `Ctrl + Shift + Down` | Reducir alto 5px |

---

## Thunar -- File Manager

| Atajo | Accion |
|-------|--------|
| `Ctrl + T` | Nueva tab |
| `Ctrl + W` | Cerrar tab |
| `Ctrl + N` | Nueva ventana |
| `F2` | Renombrar |
| `F3` | Toggle split view |
| `F5` | Recargar |
| `F9` | Toggle side pane |
| `Ctrl + 1` | Vista iconos |
| `Ctrl + 2` | Vista lista |
| `Ctrl + 3` | Vista compacta |
| `Ctrl + H` | Mostrar ocultos |
| `Ctrl + L` | Ir a ubicacion |
| `Ctrl + F` | Buscar |
| `Alt + Left` | Atras |
| `Alt + Right` | Adelante |
| `Alt + Up` | Directorio padre |
| `Alt + Home` | Home |
| `Ctrl + Q` | Cerrar ventana |
| `Ctrl + Shift + W` | Cerrar todas las ventanas |

---

## Zsh Aliases

### Sistema

| Alias | Comando |
|-------|---------|
| `c` | `clear` |
| `q` | `exit` |
| `top` | `btop` |
| `..` | `cd ..` |
| `...` | `cd ../..` |
| `....` | `cd ../../..` |
| `.....` | `cd ../../../..` |

### Navegacion y Archivos

| Alias | Comando |
|-------|---------|
| `ls` | `lsd --group-dirs=first` |
| `l` | `lsd --group-dirs=first` |
| `ll` | `lsd -la --group-dirs=first` |
| `la` | `lsd -a --group-dirs=first` |
| `lla` | `lsd -lha --group-dirs=first` |
| `cat` | `bat` |
| `catn` | `cat` (original) |
| `catnl` | `bat --paging=never` |
| `vi` | `nvim` |

### Configuracion

| Alias | Comando |
|-------|---------|
| `theme` | `~/dotfiles/scripts/theme-switch.sh` |
| `zshconfig` | `nvim ~/.zshrc` |
| `polybarupdate` | `~/.config/polybar/launch.sh` |
| `barupdate` | `~/dotfiles/scripts/barupdate.sh` (barra según backend) |
| `display-monitors` | `sh ~/dotfiles/automat/display-monitors.sh` |
| `hosts` | `sudo nvim /etc/hosts` |

### Red / VPN

| Alias | Comando |
|-------|---------|
| `vpnup` | `nmcli connection up ARCH_LINUX-CH-US-3` |

| `vpndown` | `nmcli connection down ARCH_LINUX-CH-US-3` |

| `vpnreplace` | `sh ~/dotfiles/scripts/vpn-replace.sh <archivo.conf>` |
### AI / Tools

| Alias | Comando |
|-------|---------|
| `launchgemma` | `sh ~/dotfiles/automat/launchgemma.sh` |
| `logo` | `sh ~/dotfiles/automat/launch-logo.sh` |
| `n8nstart` | `sudo systemctl start n8n` |
| `n8nstop` | `sudo systemctl stop n8n` |

---

## Rofi -- Menus

### App Launcher (`Mod + Space`)
- **Grid Android-style**: 5 columnas x 4 filas, icono arriba + nombre abajo
- Busqueda en vivo para filtrar apps

### Action Menu (`Mod + L`)
- **Grid**: 4 iconos en fila con nombre abajo
- **Lock**: En X11 usa betterlockscreen (bloqueo visual sin password). En Wayland usa swaylock (blur + clock + indicator). Muestra notificacion de bienvenida al desbloquear
- **Reboot**: Reiniciar
- **Poweroff**: Apagar
- **Logout**: Cerrar sesion de Qtile

### Settings Menu (`Mod + Shift + Space`)
- **Themes**: Lista los 8 temas para cambio instantaneo
- **Workspaces**: Selector de workspaces
- **Apps**: App launcher (rofi drun)
- **Search**: Busqueda en Google (abre Firefox en WEB workspace)
- **Backgrounds**: Seleccionar wallpaper de `recursos/wallpapers/`
- **Notifications**: Notification center (historial de notificaciones de Dunst en Rofi)

### Emoji Picker
- Accesible desde Rofi con el script `emoji.sh`
- 800+ emojis, copia al portapapeles al seleccionar
