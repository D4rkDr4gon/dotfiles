# Lock Screen

## Dual-Backend

El lock screen se adapta automáticamente al backend:

| Backend | Programa | Características |
|---------|----------|-----------------|
| **X11** | betterlockscreen / i3lock-color | Bloqueo visual sin password, fondo blur, cualquier tecla desbloquea |
| **Wayland** | swaylock | Blur + clock + indicator, config en `swaylock/config` |

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

En Wayland se usa `swaylock` con la configuración de `swaylock/config`:

```
ignore-empty-password
daemonize
clock
indicator-idle-visible
indicator-radius=100
indicator-thickness=10
effect-blur=7x5
```

### Behavior (Wayland)

| Feature | Detail |
|---------|--------|
| **Unlock** | Password (misma que la de usuario) |
| **Background** | Current screen blurred with `effect-blur=7x5` |
| **Clock** | Live clock on the lock screen |
| **Indicator** | Circular indicator appears on keypress |
| **Welcome Notification** | `notify-send` al desbloquear (mismo que X11) |

### Files (Wayland)

| File | Purpose |
|------|---------|
| `swaylock/config` | swaylock configuration |
| `scripts/lock-screen.sh` | Shell wrapper, detecta backend y ejecuta swaylock |

### Dependencies (Wayland)

- `swaylock` (package from official repos)

## Notes

- En X11 el bloqueo es visual sin password (keyboard/pointer grab).
- En Wayland se requiere la password del usuario (estándar de seguridad de Wayland).
- Ambos backends muestran la notificación "Bienvenido de nuevo! D4rkDr4g0n" al desbloquear.
