# Lock Screen

## Dual-Backend

El lock screen se adapta automáticamente al backend:

| Backend | Programa | Características |
|---------|----------|-----------------|
| **X11** | custom C binary (`lock-screen`) | Bloqueo visual sin password, fondo blur, clock + ASCII banner |
| **Wayland** | gtklock + grim + ImageMagick | Blur + ASCII banner en fondo, clock vivo con CSS, auth form glass |

La detección se hace en `scripts/lock-screen.sh` via `$XDG_SESSION_TYPE`.

## X11

### Overview (X11)

Custom X11 lockscreen written in C, triggered via `Mod + L` → Rofi Action Menu → **Lock**.

### Behavior (X11)

| Feature | Detail |
|---------|--------|
| **Unlock** | Any keypress or mouse click |
| **Background** | Captures current screen + strong Gaussian blur (radius 25 via Imlib2) |
| **Clock** | Live `HH:MM:SS` in top-right, updates every second |
| **Banner** | ASCII art "D4rkDr4g0n" with name/title in bottom-right |
| **Multi-monitor** | Full support via Xinerama — covers all displays |
| **Welcome Notification** | `notify-send` con "Bienvenido de nuevo! D4rkDr4g0n" al desbloquear |

### Files (X11)

| File | Purpose |
|------|---------|
| `scripts/lock-screen` | Compiled ELF binary |
| `scripts/lock-screen.c` | C source (Xlib + Xft + Imlib2) |
| `scripts/lock-screen.sh` | Shell wrapper with logging + `notify-send` welcome on unlock |

### Dependencies (X11)

- `xorg-server` (Xlib, Xft, Xinerama)
- `imlib2` (screen capture + blur)
- `i3lock-color` (runtime dependency for betterlockscreen, not used directly)

### Keybindings (X11)

Trigger path:

```
Mod + L  →  Rofi Action Menu  →  Lock  →  lock-screen.sh  →  lock-screen (C binary)
```

### Compilation (X11)

From `~/dotfiles/scripts/`:

```bash
gcc -O2 -o lock-screen lock-screen.c $(pkg-config --cflags --libs xft xinerama x11 imlib2)
```

## Wayland

### Overview (Wayland)

En Wayland se usa **gtklock** con pre-renderizado de fondo via `grim` + ImageMagick y un layout GTK3 custom para posicionar los elementos:

```
config:   ~/.config/gtklock/config.ini
style:    ~/.config/gtklock/style.css
layout:   ~/.config/gtklock/layout.ui
```

### Comportamiento

| Feature | Detail |
|---------|--------|
| **Unlock** | Password via PAM (input field estilizado glass) |
| **Background** | Current screen capturada con `grim`, blurred (Gaussian 0x8), banner ASCII compuesto en bottom-right |
| **Clock** | Label nativo de gtklock, **vivo** (actualiza cada segundo), posicionado en bottom-left vía layout custom |
| **Date** | Label nativo de gtklock, debajo del clock |
| **Banner** | ASCII art "D4rkDr4g0n" con nombre/título renderizado en bottom-right (baked en background) |
| **Auth form** | Aparece con fade al enfocar la pantalla (idle-hide), estilo glass semi-transparente en bottom-right |
| **Indicator** | Password reveal toggle, mensajes de error/warning |
| **Modules** | `playerctl-module` (controles multimedia), `userinfo-module` (avatar + username) |
| **Welcome Notification** | `notify-send` al desbloquear (mismo que X11) |

### Files

| File | Purpose |
|------|---------|
| `gtklock/config.ini` | Configuración general (time-format, modules, estilo y layout paths) |
| `gtklock/style.css` | Estilo GTK3 CSS completo (glass auth form, clock, etc.) |
| `gtklock/layout.ui` | Layout GTK3 custom (clock bottom-left, auth bottom-right) |
| `scripts/lock-screen.sh` | Shell wrapper, pre-renderiza fondo y lanza gtklock |
| `recursos/lock-banner.txt` | ASCII art banner para compositar en el fondo |

### Dependencies

| Paquete | Propósito |
|---------|-----------|
| `gtklock` | Lock screen GTK-based para Wayland |
| `grim` | Captura de pantalla |
| `imagemagick` | Procesamiento de imagen (blur, compositing) |
| `gtklock-playerctl-module` | (Opcional) Controles multimedia en lockscreen |
| `gtklock-userinfo-module` | (Opcional) Avatar + username en lockscreen |

### Personalización

- **Clock**: editá `#clock-label` y `#date-label` en `style.css` (font-size, color, text-shadow, etc.)
- **Auth form**: editá `#body-revealer`, `#input-field`, `#unlock-button` en `style.css`
- **Layout**: editá `layout.ui` para cambiar posición de clock, auth form, etc.
- **Banner background**: editá `lock-screen.sh` para cambiar blur, banner file, posición, etc.

## Notes

- En X11 el bloqueo es visual sin password (keyboard/pointer grab).
- En Wayland se requiere la password del usuario (estándar de seguridad de Wayland).
- Ambos backends muestran la notificación "Bienvenido de nuevo! D4rkDr4g0n" al desbloquear.
- gtklock permite personalización CSS completa, a diferencia de swaylock que no tiene overlays custom.
