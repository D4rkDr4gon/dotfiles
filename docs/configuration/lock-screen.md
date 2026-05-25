# Lock Screen

## Overview

Custom X11 lockscreen written in C, triggered via `Mod + L` → Rofi Action Menu → **Lock**.

## Behavior

| Feature | Detail |
|---------|--------|
| **Unlock** | Any keypress or mouse click |
| **Background** | Captures current screen + strong Gaussian blur (radius 25 via Imlib2) |
| **Clock** | Live `HH:MM:SS` in top-right, updates every second |
| **Banner** | ASCII art "D4rkDr4g0n" with name/title in bottom-right |
| **Multi-monitor** | Full support via Xinerama — covers all displays |
| **Welcome Notification** | `notify-send` con "Bienvenido de nuevo! D4rkDr4g0n" al desbloquear |

## Files

| File | Purpose |
|------|---------|
| `scripts/lock-screen` | Compiled ELF binary |
| `scripts/lock-screen.c` | C source (Xlib + Xft + Imlib2) |
| `scripts/lock-screen.sh` | Shell wrapper with logging + `notify-send` welcome on unlock |

## Dependencies

- `xorg-server` (Xlib, Xft, Xinerama)
- `imlib2` (screen capture + blur)
- `i3lock-color` (runtime dependency for betterlockscreen, not used directly)

## Keybindings

Trigger path:

```
Mod + L  →  Rofi Action Menu  →  Lock  →  lock-screen.sh  →  lock-screen (C binary)
```

## Compilation

From `~/dotfiles/scripts/`:

```bash
gcc -O2 -o lock-screen lock-screen.c $(pkg-config --cflags --libs xft xinerama x11 imlib2)
```

## Notes

- The C binary does **not** require a password — it is a visual lock only (keyboard/pointer grab).
- The blurred background is captured at lock time and remains static.
- For suspend-time locking, `betterlockscreen` is used via systemd service (`betterlockscreen@.service`).
