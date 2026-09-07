# Walker + Elephant — Buscador Único

`Mod+Space` (Hyprland) abre un buscador único estilo macOS Spotlight: apps, comandos de `$PATH`, calculadora y búsqueda web, todo en una sola caja, sin nada precargado, con resultados que aparecen en vivo mientras se escribe.

## Arquitectura

- **[Elephant](https://github.com/abenz1267/elephant)**: daemon (systemd user service) que expone "providers" pluggeables y responde queries en vivo, tecla por tecla — no tiene la limitación de rofi (ver `docs/design-system.md`, sección "Por qué no es rofi").
- **[Walker](https://github.com/abenz1267/walker)**: frontend GTK4 + `gtk4-layer-shell` que dibuja la ventana y le habla a Elephant.
- Providers instalados: `elephant-desktopapplications` (apps), `elephant-runner` (comandos), `elephant-calc` (calculadora, vía `qalc`/libqalculate), `elephant-websearch` (búsqueda web).
- Es el mismo stack al que migró Omarchy en su versión más reciente ("Quattro") para resolver este mismo problema.

## Instalación

```bash
yay -S elephant elephant-desktopapplications elephant-runner elephant-calc elephant-websearch walker
elephant service enable   # systemd --user, atado a graphical-session.target — arranca solo en el próximo login
```

`install.sh` ya los lista en `PACKAGES_AUR` y symlinkea `walker/` → `~/.config/walker` (paquete completo, mismo patrón que dunst/kitty/rofi).

## Estructura del paquete (`~/dotfiles/walker/`)

```
walker/
├── config.toml                    # providers, keybinds, placeholders, shell (layer-shell)
└── themes/dotfiles/
    ├── config.toml, style.css     # @define-color, reescrito por theme-switch.sh
    ├── layout.xml                 # estructura GTK (ancho fijo, alto NO fijo)
    ├── item*.xml, keybind.xml, preview.xml  # sin colores, copiados tal cual del tema "default"
```

## Decisiones de configuración (y por qué)

- **`providers.empty = []`**: nada se muestra al abrir. A diferencia de rofi, esto no cuesta el filtrado en vivo — Elephant recalcula por tecla sin importar el estado inicial.
- **`providers.default = [desktopapplications, calc, runner, websearch]`**: `runner` viene comentado por defecto en el paquete, se habilitó a mano.
- **`[placeholders] "default".list = ""`**: sin texto "No Results". Importante — esto NO se controla desde `layout.xml` (Walker fuerza `visible=(n_items==0)` en código sobre el widget `Placeholder`, ignorando cualquier `visible` puesto a mano ahí), el único lugar real es este valor de `config.toml`.
- **`hide_action_hints = true`**: sin la franja de atajos (Esc/Enter) al pie. Junto con `visible="false"` a mano en el `Keybinds` de `layout.xml` (Walker nunca la vuelve a mostrar si esta opción está en `true`, pero tampoco la oculta explícitamente — depende del default del XML).
- **`layout.xml` sin `height-request` fijo** en `BoxWrapper` (el original del paquete trae 570px fijo): la ventana debe verse como una barra de búsqueda chica y crecer recién cuando hay resultados, hasta el tope `max-content-height=470` del `Scroll`. `width-request` sí queda fijo (760px, agrandado del 600px original) para que el ancho no salte mientras se escribe.

Ver `docs/design-system.md` para el detalle completo de por qué cada uno de estos 3 ajustes (precarga, placeholder, keybinds) necesitó tocarse en un lugar distinto — se verificó leyendo el código fuente real de Walker, no por prueba y error.

## Integración con theme-switch.sh

`WALKER_STYLE="$HOME/dotfiles/walker/themes/dotfiles/style.css"` — mismo patrón `@define-color` que `gtk-3.0/gtk.css`: `window_bg_color`, `accent_bg_color`, `theme_fg_color`, `error_bg_color`, `error_fg_color` se pisan con `background`/`primary`/`foreground`/`status_error` del tema activo. No hace falta reload — Walker lee el CSS actual en cada apertura (no es un proceso persistente).

## X11 / Qtile

Walker no corre bajo X11 (depende de `gtk4-layer-shell`, protocolo Wayland). El bind equivalente en Qtile (`mod+space`, `qtile/modules/keys.py`) usa en cambio `rofi/scripts/spotlight-launch.sh` — ver `docs/configuration/rofi.md`.
