# Proyecto: Migración LightDM → greetd + ReGreet + Lock Screen Config

> **Inicio:** 2026-06-22
> **Estado:** Planificación
> **Responsable:** Atlas (Arch Linux System Manager)
> **Vault Babilonia:** `$BABILONIA/Manuales/.../GREETD-MIGRATION.md` (pendiente)

---

## 📋 Índice

1. [Objetivo](#objetivo)
2. [Arquitectura actual](#arquitectura-actual)
3. [Arquitectura objetivo](#arquitectura-objetivo)
4. [Requisitos](#requisitos)
5. [Estrategia de contingencia (NO QUEDARSE SIN ACCESO)](#estrategia-de-contingencia)
6. [Fases de implementación](#fases-de-implementación)
7. [Investigación greetd + ReGreet](#investigación-greetd--regreet)
8. [Tema ReGreet: Especificación visual](#tema-regreet-especificación-visual)
9. [Lock Screen Settings Panel](#lock-screen-settings-panel)
10. [Checklist de implementación](#checklist-de-implementación)
11. [Referencias](#referencias)

---

## Objetivo

Migrar de **LightDM** (Display Manager X11 actual) a **greetd + ReGreet** (Wayland nativo), manteniendo:

-   ✅ Fingerprint login (Goodix 27c6:550a via fprintd)
-   ✅ Sesión dual: Qtile (Wayland) + Hyprland
-   ✅ Estética rofi (monocromático oscuro, bordes 24px, Hack Nerd Font)
-   ✅ Selección fácil de sesión en el greeter
-   ✅ Panel de ajustes de bloqueo en settings-menu.sh de rofi

---

## Arquitectura actual

```
Hardware → systemd-boot (UKI) → LightDM (VT 1)
                                    ├─ Qtile (Wayland) — sesión default
                                    │   ├─ Waybar + Rofi + Dunst
                                    │   ├─ gtklock (pantalla de bloqueo)
                                    │   └─ lock-screen.sh (blur + banner)
                                    │
                                    └─ Hyprland (Wayland) — sesión alternativa
                                        ├─ Waybar + Rofi + Dunst
                                        ├─ start-hyprland.sh (wrapper v3)
                                        └─ gtklock (pantalla de bloqueo)
```

### Servicios actuales

| Servicio | Estado | Display Manager |
|---|---|---|
| `lightdm.service` | ✅ Enabled | LightDM (vt 1) |
| `fprintd.service` | ✅ Active | Fingerprint daemon |

### PAM actual (/etc/pam.d/lightdm)

```
auth       sufficient   pam_fprintd.so    ← huella primero
auth       include      system-login      ← contraseña como fallback
```

### Desktop entries

| Archivo | Sesión | Exec |
|---|---|---|
| `/usr/share/wayland-sessions/hyprland.desktop` | Hyprland | `start-hyprland.sh` (wrapper) |
| `/usr/share/wayland-sessions/qtile-wayland.desktop` | Qtile Wayland | `qtile start -b wayland` |
| `/usr/share/xsessions/qtile.desktop` | Qtile X11 | `qtile start` |

---

## Arquitectura objetivo

```
Hardware → systemd-boot (UKI) → greetd (VT 1)
                                    │
                                    ├─ [default_session] → cage -s -mlast -d -- regreet
                                    │       │
                                    │       └─ ReGreet (GTK4 greeter)
                                    │           ├─ Usuario: lcampassi
                                    │           ├─ Sesión: ▼ Qtile (Wayland)  o  ▼ Hyprland
                                    │           ├─ Huella: touch sensor → PAM fprintd
                                    │           └─ Pass: fallback si no hay huella
                                    │
                                    ├─ Si elige Qtile    → qtile start -b wayland
                                    │                        ├─ Waybar + Rofi + Dunst
                                    │                        ├─ gtklock (pantalla de bloqueo)
                                    │                        └─ theme-switch.sh
                                    │
                                    └─ Si elige Hyprland → start-hyprland.sh
                                                             ├─ Waybar + Rofi + Dunst
                                                             ├─ gtklock (pantalla de bloqueo)
                                                             └─ theme-switch.sh
```

### Servicios objetivo

| Servicio | Estado | Display Manager |
|---|---|---|
| `greetd.service` | ✅ Enabled | greetd (vt 1) |
| `lightdm.service` | ❌ Disabled (no desinstalado — fallback) | — |
| `fprintd.service` | ✅ Active | Fingerprint daemon |

---

## Requisitos

### Funcionales

| # | Requisito | Cómo se cumple |
|---|---|---|
| R1 | Inicio de sesión con huella digital | PAM greetd con `pam_fprintd.so` como `sufficient` |
| R2 | Selección de sesión Qtile/Hyprland | ReGreet dropdown de sesiones desde `.desktop` files |
| R3 | Estética combinada con rofi | CSS GTK4 ReGreet: `#0a0a0aE8`, 24px radius, Hack Nerd Font |
| R4 | Pantalla de bloqueo configurable | gtklock + lock-screen.sh + panel en settings-menu.sh |
| R5 | Sin dependencias X11 | greetd + ReGreet + cage son 100% Wayland |
| R6 | Fallback si greetd falla | LightDM deshabilitado pero instalado + rescue entry |

### Técnicos

| # | Requisito | Detalle |
|---|---|---|
| T1 | greetd daemon + ReGreet + cage | `sudo pacman -S greetd greetd-regreet cage` |
| T2 | PAM greetd con fingerprint | `/etc/pam.d/greetd` con `pam_fprintd.so` |
| T3 | Tema GTK4 CSS para ReGreet | `/etc/greetd/regreet.css` |
| T4 | Config ReGreet | `/etc/greetd/regreet.toml` |
| T5 | Config greetd | `/etc/greetd/config.toml` |
| T6 | Desktop entries correctos | Ya existen en `/usr/share/wayland-sessions/` |
| T7 | rescue kernel cmdline override | systemd-boot: presionar `e` en boot → `systemd.mask=greetd.service` |

---

## Estrategia de contingencia

> ⚠️ **REGLAS DE ORO:**
> 1. LightDM **NO se desinstala** — solo se deshabilita
> 2. greetd se prueba **en VT separado** antes de deshabilitar LightDM
> 3. Siempre hay un TTY accesible (Ctrl+Alt+F3)
> 4. Preparar rescue antes de tocar LightDM

### Plan de recuperación (3 niveles)

#### Nivel 1 — systemd-boot override (rápido)

En el boot, cuando aparezca el menú de systemd-boot:

```
  Arch Linux          ← seleccionar y presionar 'e'
  Windows 11
```

Agregar al final de la línea de comandos del kernel:

```
systemd.mask=greetd.service
```

Esto evita que greetd arranque. El sistema caerá en un TTY. Desde ahí:

```bash
sudo systemctl disable greetd
sudo systemctl enable --now lightdm
reboot
```

#### Nivel 2 — TTY recovery (si greetd no funciona)

Si greetd falla pero el sistema arranca:

```bash
Ctrl+Alt+F3   # Cambia a TTY3
# Login con usuario/contraseña
sudo systemctl disable greetd
sudo systemctl enable --now lightdm
reboot
```

#### Nivel 3 — Recovery desde ISO (worst case)

1. Bootear desde USB de Arch
2. Montar particiones
3. `arch-chroot /mnt`
4. `sudo systemctl disable greetd && sudo systemctl enable lightdm`

### Archivos de backup pre-migración

```bash
# Se guardan antes de modificar nada:
/etc/lightdm/lightdm.conf          → /etc/lightdm/lightdm.conf.bak.$(date +%Y%m%d)
/etc/lightdm/lightdm-gtk-greeter.conf → /etc/lightdm/lightdm-gtk-greeter.conf.bak.$(date +%Y%m%d)
/etc/pam.d/lightdm                 → /etc/pam.d/lightdm.bak.$(date +%Y%m%d)
```

---

## Fases de implementación

### Fase 0: Preparación (antes de tocar nada)

-   [ ] Respaldo de configs actuales (LightDM, PAM)
-   [ ] Verificar rescue TTY funciona (Ctrl+Alt+F3)
-   [ ] Tener ISO de Arch en USB por si acaso
-   [ ] Crear snapshot de `dotfiles/` (git commit)
-   [ ] Leer documentación de ReGreet / greetd

### Fase 1: Instalación de greetd + ReGreet

-   [ ] `sudo pacman -S greetd greetd-regreet cage`
-   [ ] Crear usuario `greeter` si no existe
-   [ ] Verificar paquetes instalados correctamente

### Fase 2: Configuración greetd (VT 2 para pruebas)

-   [ ] Crear `/etc/greetd/config.toml` con `vt = 2`
-   [ ] Crear `/etc/greetd/regreet.toml` con configuración base
-   [ ] Crear PAM `/etc/pam.d/greetd` con `pam_fprintd.so`
-   [ ] Crear tema CSS `/etc/greetd/regreet.css`
-   [ ] Asegurar permisos correctos: `greeter` user, `/etc/greetd/` legible

### Fase 3: Prueba en VT separado

-   [ ] `sudo systemctl stop lightdm` (cierra sesión)
-   [ ] Cambiar a VT 2 (Ctrl+Alt+F2)
-   [ ] `sudo systemctl start greetd`
-   [ ] Probar login con huella
-   [ ] Probar sesión Qtile
-   [ ] Probar sesión Hyprland
-   [ ] Si falla: Ctrl+Alt+F1 → LightDM sigue en VT 1

### Fase 4: Migración definitiva

-   [ ] `sudo systemctl disable lightdm`
-   [ ] `sudo systemctl enable greetd`
-   [ ] Cambiar `vt = 1` en `config.toml`
-   [ ] `sudo systemctl restart greetd`
-   [ ] Probar reboot completo

### Fase 5: Lock Screen Settings Panel

-   [ ] Crear `dotfiles/rofi/scripts/lock-settings.sh`
-   [ ] Integrar en `settings-menu.sh`
-   [ ] Crear `dotfiles/gtklock/themes/` para variantes de color
-   [ ] Integrar con `theme-switch.sh` para aplicar colores del tema actual
-   [ ] Sincronizar wallpaper de lock screen con tema actual

### Fase 6: Documentación

-   [ ] Documentar en `docs/greetd-migration.md`
-   [ ] Documentar en vault Babilonia
-   [ ] Actualizar `docs/requirements.md`
-   [ ] Actualizar `docs/configuration/wayland.md`
-   [ ] Crear entry en `dotfiles/docs/` sobre lock screen config

---

## Investigación greetd + ReGreet

### Paquetes necesarios

| Paquete | Repo | Propósito |
|---|---|---|
| `greetd` | extra | Login manager daemon (Rust) |
| `greetd-regreet` | extra | Greeter GTK4 (ReGreet) |
| `cage` | extra | Compositor Wayland minimalista para el greeter |
| `fprintd` | extra | Fingerprint daemon (ya instalado) |

### `/etc/greetd/config.toml` — Daemon greetd

```toml
[terminal]
vt = 1                    # VT donde corre greetd
switch = true             # Switchear automáticamente a este VT

[general]
source_profile = true     # Source ~/.profile y /etc/profile
runfile = "/run/greetd/run"

[default_session]
command = "dbus-run-session cage -s -mlast -d -- regreet"
user = "greeter"
```

**Flags de cage:**
- `-s` → Habilita VT switching (crítico para fallback por TTY)
- `-mlast` → Usa solo el último monitor
- `-d` → Evita client-side decorations

### `/etc/greetd/regreet.toml` — Config ReGreet

```toml
skip_selection = false

[background]
path = "/usr/share/backgrounds/default-wallpaper.jpg"
fit = "Cover"

[env]
XDG_SESSION_TYPE = "wayland"

[GTK]
application_prefer_dark_theme = true
font_name = "Hack Nerd Font 14"
cursor_theme_name = "Adwaita"
icon_theme_name = "Adwaita"
theme_name = "Adwaita"

[commands]
reboot = ["systemctl", "reboot"]
poweroff = ["systemctl", "poweroff"]

[appearance]
greeting_msg = ""

[widget.clock]
format = "%a %H:%M"
resolution = "500ms"
```

### `/etc/pam.d/greetd` — PAM con fingerprint

```
#%PAM-1.0
auth       sufficient   pam_fprintd.so     ← Huella primero
auth       sufficient   pam_unix.so try_first_pass likeauth nullok  ← Pass fallback
auth       substack     system-auth         ← Auth genérica
-auth      optional     pam_gnome_keyring.so
account    include      system-auth
session    include      system-auth
-session   optional     pam_gnome_keyring.so auto_start
```

**Cómo funciona el fingerprint con greetd:**
1. ReGreet muestra campo de contraseña + botón de login
2. Usuario presiona Enter con campo vacío → PAM ejecuta `pam_fprintd.so`
3. Lector de huellas se activa → usuario toca el sensor
4. Si huella OK → auth exitoso → inicia sesión
5. Si huella falla/no disponible → `pam_unix.so` pide contraseña
6. Usuario escribe password y presiona Enter

### Desktop entries para selector de sesión

ReGreet lee sesiones de `/usr/share/wayland-sessions/` y `/usr/share/xsessions/`. Los archivos actuales ya están configurados:

**`/usr/share/wayland-sessions/hyprland.desktop`**:
```desktop
[Desktop Entry]
Name=Hyprland
Comment=Hyprland Wayland compositor (con wrapper)
Exec=/home/lcampassi/dotfiles/hypr/scripts/start-hyprland.sh
Type=Application
DesktopNames=Hyprland
Keywords=tiling;wayland;compositor;
```

**`/usr/share/wayland-sessions/qtile-wayland.desktop`**:
```desktop
[Desktop Entry]
Name=Qtile (Wayland)
Comment=Qtile Session
Exec=qtile start -b wayland
Type=Application
Keywords=wm;tiling
```

---

## Tema ReGreet: Especificación visual

### Paleta (idéntica a rofi)

| Variable | Hex | Uso |
|---|---|---|
| `bg0` | `#0a0a0aE8` | Fondo ventana, semi-transparente ~91% |
| `bg1` | `#141414` | Input fields, opaco |
| `bg2` | `#1E1E1E99` | Elementos secundarios, ~60% opaco |
| `bg3` | `#333333F2` | Hover/selección, ~95% opaco |
| `fg0` | `#E6E6E6` | Texto principal |
| `fg1` | `#FFFFFF` | Blanco puro (sin uso actual) |
| `fg2` | `#969696` | Texto secundario |
| `fg3` | `#4A4A4A` | Placeholder |

### Layout visual

```
┌──────────────────────────────────────────┐
│   ┌──────────────────────────────────┐   │  ← overlay con background-image
│   │    picture#background            │   │
│   │    filter: brightness(0.4)       │   │
│   ├──────────────────────────────────┤   │
│   │  ┌────────────────────────────┐  │   │
│   │  │  frame.background          │  │   │  ← bg0, radius 24px, padding 30px
│   │  │  ┌────────────────────┐    │  │   │
│   │  │  │  Avatar (opcional) │    │  │   │
│   │  │  │  ────────────────  │    │  │   │
│   │  │  │  lcampassi         │    │  │   │  ← combobox (usuario)
│   │  │  │  ┌──────────────┐ │    │  │   │
│   │  │  │  │ ●●●●●●●●●●   │ │    │  │   │  ← passwordentry
│   │  │  │  └──────────────┘ │    │  │   │
│   │  │  │  Session: ▼ Qtile│ │    │  │   │  ← combobox (sesión)
│   │  │  │  ┌──────────────┐ │    │  │   │
│   │  │  │  │ Iniciar      │ │    │  │   │  ← button.suggested-action
│   │  │  │  └──────────────┘ │    │  │   │
│   │  │  └────────────────────┘    │  │   │
│   │  └────────────────────────────┘  │   │
│   └──────────────────────────────────┘   │
│                                          │
│   ┌──────────────────┐                   │
│   │ Mon 22 Jun 20:30 │  ← clock frame    │
│   └──────────────────┘                   │
└──────────────────────────────────────────┘
```

### CSS Template

```css
/* /etc/greetd/regreet.css */

window { background: none; }
overlay { background: none; }

/* Background image with dark overlay */
picture#background {
    filter: brightness(0.4);
}

/* Main login box - matching rofi theme.rasi */
frame.background {
    background-color: rgba(10, 10, 10, 0.91);  /* #0a0a0aE8 */
    border-radius: 24px;
    border: 1px solid rgba(255, 255, 255, 0.06);
    padding: 30px;
    min-width: 400px;
}

/* Labels */
label {
    color: #E6E6E6;
    font-family: "Hack Nerd Font";
    font-size: 14px;
}

/* Password entry - matching rofi inputbar */
passwordentry {
    background-color: #141414;
    color: #E6E6E6;
    border-radius: 16px;
    border: 2px solid #333333;
    padding: 8px 16px;
    font-family: "Hack Nerd Font";
    font-size: 14px;
    caret-color: #969696;
}

passwordentry:focus {
    border-color: #4A4A4A;
}

/* Dropdowns (user + session selector) */
comboboxtext {
    background-color: #141414;
    color: #E6E6E6;
    border-radius: 16px;
    border: 2px solid #333333;
    padding: 8px 16px;
    font-family: "Hack Nerd Font";
    font-size: 14px;
}

/* Login button */
button.suggested-action {
    background-color: #333333;
    color: #FFFFFF;
    border-radius: 16px;
    border: none;
    padding: 10px 24px;
    font-family: "Hack Nerd Font";
    font-size: 14px;
    font-weight: bold;
}

button.suggested-action:hover {
    background-color: #4A4A4A;
}

/* Power/reboot buttons */
button.destructive-action {
    background-color: rgba(239, 68, 68, 0.15);
    color: #ef4444;
    border-radius: 16px;
    border: 1px solid rgba(239, 68, 68, 0.3);
}

button.destructive-action:hover {
    background-color: rgba(239, 68, 68, 0.3);
}

/* Clock frame - top area */
frame.background clock {
    background-color: rgba(10, 10, 10, 0.7);
    border-radius: 24px;
    padding: 10px 24px;
    border: 1px solid rgba(255, 255, 255, 0.06);
}

/* Clock label */
label:has(+ label) {
    font-family: "Hack Nerd Font";
    font-size: 80px;
    font-weight: bold;
    color: #E6E6E6;
}

/* Notification bar */
infobar {
    background-color: rgba(51, 51, 51, 0.95);
    border-radius: 16px;
}
```

---

## Lock Screen Settings Panel

### Ubicación

Nueva entrada en `settings-menu.sh`:

```
  Themes
  Workspaces
󰏓  Apps
  Search
  Backgrounds
  Notifications
🔒  Lock Screen        ← NUEVO
```

### Submenú "Lock Screen"

Al seleccionar "Lock Screen", se abre un submenú con opciones:

```
Lock Screen Settings
────────────────────
🖼  Wallpaper              ← Elegir wallpaper específico para lock
🎨  Color Theme            ← Aplicar paleta de un tema al lock screen
🔄  Sync with Desktop      ← Usar mismo wallpaper + colores del tema actual
🔐  Fingerprint Auth       ← On/Off (toggle)
📝  Custom Message         ← Texto del banner (editable)
←  Go Back
```

### Archivos involucrados

| Archivo | Propósito |
|---|---|
| `dotfiles/rofi/scripts/lock-settings.sh` | Nuevo script para el panel de ajustes de bloqueo |
| `dotfiles/rofi/scripts/settings-menu.sh` | Modificar para agregar entrada "Lock Screen" |
| `dotfiles/scripts/lock-screen.sh` | Leer configuración de lock desde archivo JSON |
| `dotfiles/gtklock/style.css` | Template CSS con variables de color |
| `dotfiles/gtklock/layout.ui` | Layout GTK de gtklock (sin cambios) |
| `dotfiles/gtklock/themes/` | Nuevo directorio para variantes de tema de lock |
| `~/.config/gtklock/current_theme.json` | Nuevo archivo de configuración de lock screen |
| `dotfiles/scripts/theme-switch.sh` | Modificar para sync lock screen con tema actual |

### Formato de configuración de lock screen

```json
// ~/.config/gtklock/current_theme.json
{
    "wallpaper": "/home/lcampassi/dotfiles/recursos/wallpapers/japan-wallpaper.jpg",
    "colors": {
        "bg": "#0a0a0aE8",
        "fg": "#E6E6E6",
        "accent": "#4A4A4A",
        "border": "#141414"
    },
    "blur": "0x8",
    "banner_text": "D4rkDr4g0n",
    "sync_with_theme": true,
    "fingerprint_auth": true
}
```

### Integración con theme-switch.sh

Cuando se ejecuta `theme <nombre>`, el script debe:

1. Aplicar el tema (wallpaper, colores waybar/kitty/zsh/etc.)
2. **Si `sync_with_theme = true`** en lock config:
   - Copiar wallpaper del tema a la config de lock
   - Extraer colores dominantes del tema (o usar los del theme.json)
   - Escribir `~/.config/gtklock/current_theme.json`
   - El próximo lock mostrará el nuevo wallpaper + colores

---

## Checklist de implementación

### Preparación

-   [ ] **HACER COMMIT** de dotfiles actual (`git add -A && git commit -m "pre-greetd-migration"`)
-   [ ] Respadar configs LightDM + PAM
-   [ ] Verificar TTY funciona: `Ctrl+Alt+F3` → login → `exit`
-   [ ] Verificar `fprintd-verify` funciona
-   [ ] Leer documentación greetd (ArchWiki)
-   [ ] Tener ISO Arch Linux en USB (por las dudas)

### Instalación

-   [ ] `sudo pacman -S greetd greetd-regreet cage`
-   [ ] `sudo systemctl status greetd` (verificar que existe)
-   [ ] `cage --version` (verificar instalación)
-   [ ] `regreet --version` (verificar instalación)
-   [ ] Crear usuario greeter si no existe

### Configuración greetd

-   [ ] Crear `/etc/greetd/config.toml` (VT 2 inicialmente)
-   [ ] Crear `/etc/greetd/regreet.toml`
-   [ ] Crear `/etc/greetd/regreet.css` (tema rofi-like)
-   [ ] Crear `/etc/pam.d/greetd` (con fingerprint)
-   [ ] Permisos: `sudo chmod -R go+r /etc/greetd`
-   [ ] Verificar `greeter` usuario tiene acceso a `/etc/greetd/`

### Pruebas

-   [ ] `sudo systemctl stop lightdm` (cierra sesión)
-   [ ] Cambiar a VT 2: `Ctrl+Alt+F2`
-   [ ] `sudo systemctl start greetd`
-   [ ] **Probar login con huella** en ReGreet
-   [ ] **Probar login con contraseña** en ReGreet
-   [ ] **Probar sesión Qtile** desde ReGreet
-   [ ] **Probar sesión Hyprland** desde ReGreet
-   [ ] Si todo OK → continuar. Si falla → `Ctrl+Alt+F1` → LightDM

### Migración

-   [ ] `sudo systemctl disable lightdm`
-   [ ] `sudo systemctl enable greetd`
-   [ ] Cambiar `vt = 1` en `/etc/greetd/config.toml`
-   [ ] `sudo systemctl restart greetd`
-   [ ] `sudo reboot`
-   [ ] Verificar que greetd aparece en boot
-   [ ] Login con huella en boot
-   [ ] Probar ambas sesiones

### Lock Screen Panel

-   [ ] Crear `dotfiles/rofi/scripts/lock-settings.sh`
-   [ ] Agregar entrada "Lock Screen" en `settings-menu.sh`
-   [ ] Crear `dotfiles/gtklock/themes/` con variantes
-   [ ] Crear sistema de configuración JSON para gtklock
-   [ ] Modificar `theme-switch.sh` para sincronizar lock screen
-   [ ] Modificar `lock-screen.sh` para leer config JSON
-   [ ] Probar cambio de wallpaper de lock desde rofi
-   [ ] Probar cambio de colores de lock desde rofi

### Documentación

-   [ ] `dotfiles/docs/greetd-migration.md` (proceso)
-   [ ] `dotfiles/docs/configuration/lock-screen.md` (config lock)
-   [ ] `dotfiles/docs/requirements.md` (actualizar)
-   [ ] `$BABILONIA/Manuales/.../GREETD-MIGRATION.md` (vault)
-   [ ] `dotfiles/docs/keybindings.md` (si cambian atajos)
-   [ ] Commit final con todos los cambios

---

## Referencias

### Documentación oficial

-   [ArchWiki - greetd](https://wiki.archlinux.org/title/Greetd)
-   [ReGreet GitHub](https://github.com/rharish101/ReGreet)
-   [greetd sourcehut](https://git.sr.ht/~kennylevinsen/greetd)
-   [Hyprland Wiki - Display Managers](https://wiki.hyprland.org/Useful-Utilities/Display-Managers/)
-   [Cage GitHub](https://github.com/Hjdskes/cage)
-   [fprintd ArchWiki](https://wiki.archlinux.org/title/Fprint)
-   [gtklock GitHub](https://github.com/jovanlanik/gtklock)
-   [systemd-boot ArchWiki](https://wiki.archlinux.org/title/Systemd-boot)
-   [UKI ArchWiki](https://wiki.archlinux.org/title/Unified_kernel_image)

### Archivos del sistema involucrados

```
/etc/greetd/config.toml         ← greetd daemon config
/etc/greetd/regreet.toml        ← ReGreet config
/etc/greetd/regreet.css         ← ReGreet theme CSS
/etc/pam.d/greetd               ← PAM con fingerprint
/usr/share/wayland-sessions/    ← Desktop entries (Qtile, Hyprland)
~/.config/gtklock/              ← Config pantalla de bloqueo
```

### Dotfiles involucrados

```
~/dotfiles/hypr/scripts/start-hyprland.sh
~/dotfiles/rofi/scripts/settings-menu.sh
~/dotfiles/rofi/scripts/lock-settings.sh      ← NUEVO
~/dotfiles/scripts/lock-screen.sh
~/dotfiles/scripts/theme-switch.sh
~/dotfiles/gtklock/style.css
~/dotfiles/gtklock/layout.ui
~/dotfiles/gtklock/config.ini
~/dotfiles/gtklock/themes/                    ← NUEVO
```

### Archivos de vault Babilonia

```
$BABILONIA/Manuales/.../HYPRLAND-CONFIG.md
$BABILONIA/Manuales/.../GREETD-MIGRATION.md   ← PENDIENTE
```
