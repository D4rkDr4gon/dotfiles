# Shortcuts — Cheatsheet + Editor

`Mod+K` (Hyprland y Qtile) abre una TUI (`recursos/shortcuts/shortcuts_tui.py`,
Python + Textual) que junta en una sola tabla filtrable todos los atajos de
teclado del sistema, de 5 fuentes con formatos completamente distintos:

| Fuente | Archivo | Formato |
|---|---|---|
| Hyprland | `hypr/hyprland.conf` | `bind = MODS, KEY, dispatcher, args  # comentario` |
| kitty | `kitty/kitty.conf` | `map combo acción` |
| herdr | `herdr/config.toml` | `[keys]` (nombrados) + `[[keys.command]]` (bloques con `key`/`command`/`description`) |
| Qtile (X11) | `qtile/modules/keys.py` | `Key([mods], "key", lazy.spawn(...), desc="...")` |
| Obsidian | `/files/Personal-Vault/.obsidian/hotkeys.json` | JSON `{comando: [{modifiers, key}]}` — solo los que el usuario ya personalizó, Obsidian no expone sus defaults en un archivo |

## Editar (`Enter` sobre una fila)

Reasigna **solo el combo de teclas** — nunca la acción/comando que dispara.
Es una decisión de diseño, no una limitación técnica: reescribir a ciegas
una línea de código (el dispatcher de Hyprland, la `lazy.spawn(...)` de
Qtile) es mucho más riesgoso que reasignar qué tecla la dispara. Para
cambiar QUÉ hace un atajo, se sigue editando el archivo a mano.

Cada fuente tiene su propia función de reescritura, dirigida a la línea/
campo exacto (por número de línea capturado al parsear), sin tocar el
resto de la línea ni reformatear el archivo entero:

- **Hyprland**: `SUPER` se normaliza a `$mainMod` al guardar (la variable
  que ya usa el resto de `hyprland.conf`).
- **kitty**: reemplaza el combo al inicio de la línea `map`.
- **herdr**: TOML — reemplaza el valor de `key = "..."` de la línea exacta
  (named binds y bloques `[[keys.command]]` por igual). Los que tienen
  alternates (`next_tab = ["prefix+n", "ctrl+alt+]"]`) quedan **solo
  lectura** en la tabla — colapsar la lista a un solo valor perdería la
  alternativa, así que se edita a mano.
- **Qtile**: agrega comillas automáticamente a cualquier modificador que no
  sea la variable `mod` (ej. `shift` → `"shift"`) — sin esto la línea
  compila igual (`Key([mod, shift], ...)` no es un error de sintaxis) pero
  tira `NameError` recién al recargar Qtile. Se verificó ejecutando el
  archivo modificado de verdad, no solo compilándolo.
- **Obsidian**: reescribe el JSON completo de forma estructurada
  (`json.load`/`json.dump`), el único de los 5 que no es edición de texto
  línea por línea.

Después de guardar, la TUI muestra el comando de reload correspondiente
(`hyprctl reload`, `herdr server reload-config`, reabrir kitty, recargar
Qtile) — no lo ejecuta solo, para no reiniciar nada sin confirmación
explícita del usuario.

## Lanzamiento

- Hyprland: `bind = $mainMod, K, exec, bash waybar/scripts/shortcuts-launch.sh`
  → `float-tui-launch.sh shortcuts 'Shortcuts' 110 34 python3 shortcuts_tui.py`
  (mismo lanzador genérico de TUIs flotantes que usan `claude-agents`,
  `vpn-tui`, `cliamp`, `bluetui`, `impala` — float + pin + posicionado
  arriba a la derecha).
- Qtile: `Key([mod], "k", lazy.spawn("kitty --class shortcuts ..."))` +
  entrada en `FLOAT_GEOMETRY` (`qtile/modules/hooks.py`) para el
  posicionamiento flotante equivalente en X11.

## Theming

Lee `qtile/current_theme.json` directamente al arrancar (mismo patrón que
`vpn_tui.py`/`claude-agents-tui.sh`) — no pasa por `theme-switch.sh`, no
hace falta ningún target nuevo en el pipeline central.
