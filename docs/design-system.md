# Sistema de Diseño — "Flat Minimal"

## Filosofía

El objetivo no es solo que cada app *combine* con el color del tema activo — es que las piezas del entorno (dunst, rofi, waybar, HyprFM, Sublime Text, LazyVim, kitty, Walker, la VPN TUI, la TUI de agentes, Obsidian, herdr) se *parezcan* entre sí: misma estructura de componentes, misma jerarquía tipográfica, mismo trato de selección/hover, mismo radio de esquina. El color varía con el tema; la forma no varía nunca.

Este modelo está tomado directamente de cómo lo resuelve [Omarchy](https://github.com/basecamp/omarchy) (confirmado con fetch de sus archivos fuente reales, no capturas): la geometría (radios, `border_size`, gaps, tipografía, opacidad/blur) vive en un archivo fijo compartido entre todos los temas (`looknfeel.conf` / `shell.toml.tpl`), y **ningún tema la toca** — solo intercambia una paleta de colores con el mismo esquema de claves. Nuestro equivalente a ese archivo fijo es [`themes/_design-tokens.json`](../themes/_design-tokens.json).

## Las reglas de "Flat Minimal"

| Elemento | Regla |
|---|---|
| Borde | Ninguno (`border: none` / `frame_width: 0` / sin box-drawing ni `border: tall`) |
| Radio | **10px único**, en todo lo que lo soporte (dunst, rofi, ventanas de Hyprland — que cascadea gratis a kitty/herdr/Sublime/Obsidian/TUIs por ser ventanas normales del compositor —, waybar, Walker, Obsidian) |
| Fondo de reposo | `background` (superficie base) o transparente |
| Fondo de selección/hover/activo | Un tono de la rampa de superficies — nunca un borde de color, siempre relleno |
| Acento del tema | Solo en texto/ícono destacado, barra de progreso/estado, o fondo de selección — nunca como línea decorativa suelta |
| Tipografía | Título en negrita + `foreground`; meta/subtítulo atenuado (blend `foreground`→`background` al 35-45%); fuente única, `Hack Nerd Font`, en todo el sistema |
| Ícono + texto | Ícono Nerd Font + espaciado fijo antes del label, mismo ritmo en todas las apps |
| Separadores | Línea de 1px en la superficie más sutil, nunca un doble marco |

## La rampa de superficies: reinterpretar `chip_*`

`theme.json` no tiene (ni necesita) campos nuevos para esto. Los 4 campos `chip_battery → chip_audio`, pensados originalmente solo para íconos de waybar, son en los 8 temas originales una rampa de superficies ascendente (oscuro→claro) sobre el `background`. Esa es exactamente la escala de "elevación" que necesita el resto del sistema:

| Campo | Rol reinterpretado |
|---|---|
| `background` | Superficie base (fondo de ventana/panel) |
| `chip_battery` | Superficie 1 — fondo de reposo de un chip/fila (dunst, tabs inactivas de kitty, `crust` de HyprFM, `bg-card` de Obsidian) |
| `chip_bluetooth` | Superficie 2 — hover/foco sutil (`mantle` de HyprFM, `bg-hover`/`border` de Obsidian, borde inactivo de Hyprland) |
| `chip_wlan` | Superficie 3 — selección activa (fila seleccionada de rofi, `datatable--cursor` de la VPN TUI, `surface` de HyprFM) |
| `chip_audio` | Superficie 4 — la más clara, `overlay` de HyprFM |
| `primary` / `secondary` | Acento — nunca borde, siempre texto/ícono/relleno de estado |
| `status_ok/warn/error` | Estados semánticos, ya usados por herdr/hyprfm/dunst/agents-tui/VPN TUI |

Un tono intermedio sin campo propio (texto atenuado) se deriva con `hex_blend()` (ya existe en `theme-switch.sh`, replicada en Python en `vpn_tui.py`), nunca un campo nuevo.

## `themes/_design-tokens.json`

Constante de forma, no consumida en runtime por ningún script todavía (es la referencia escrita para que una app nueva no invente un radio/opacidad a ojo): `font_mono`, `radius` (10), `border` ("none"), `border_size`, `gaps`, `opacity` por app, `blur`, `spacing`.

## El buscador único (`Mod+Space`)

### Por qué no es rofi

El primer intento fue construir el buscador tipo Spotlight sobre rofi (`combi` + un script propio de fallback). Se abandonó tras confirmar con `man rofi-script` y con pruebas reales (`rofi -dump-config`, ejecución headless) una limitación arquitectónica real: **rofi nunca vuelve a ejecutar un script en cada tecla** — solo al presionar Enter sobre texto sin match (`ROFI_RETV=2`). El filtrado "en vivo" que sí existe en `drun`/`run` es 100% client-side sobre una lista cargada una única vez al abrir. Por eso con rofi solo se puede elegir entre "algo precargado + filtrado en vivo" o "vacío + sin filtrado en vivo" — nunca las dos cosas juntas para fuentes heterogéneas (apps + comandos + calculadora + búsqueda web). Mezclar el plugin nativo `rofi-calc` (que sí recalcula en vivo, por ser un plugin C con acceso a la API interna) dentro de `combi-modi` además tiene un bug reportado y sin fix (`svenstaro/rofi-calc` issue #33).

### La solución real: Walker + Elephant

[**Elephant**](https://github.com/abenz1267/elephant) es un daemon (no un script) que expone "providers" (apps, comandos, calculadora, búsqueda web, y más) y sí puede recalcular resultados en cada tecla, porque el cliente le manda la query completa cada vez y el daemon responde en vivo — sin la limitación de rofi. [**Walker**](https://github.com/abenz1267/walker) es el frontend (GTK4 + `gtk4-layer-shell`) que dibuja la ventana y le habla a Elephant. Es, además, el mismo stack al que migró Omarchy en su versión más reciente ("Quattro") para resolver exactamente este problema — confirmado en la investigación de referencia de este proyecto.

Instalado vía AUR: `elephant`, `elephant-desktopapplications`, `elephant-runner`, `elephant-calc`, `elephant-websearch`, `walker`. El daemon corre como servicio de usuario systemd (`elephant service enable`, atado a `graphical-session.target`).

Configuración en `walker/` (symlinkeado completo a `~/.config/walker`, mismo patrón que dunst/kitty/rofi):
- `config.toml`: `providers.default = [desktopapplications, calc, runner, websearch]`, **`providers.empty = []`** — a propósito: sin nada precargado al abrir. A diferencia de rofi, esto no sacrifica el filtrado en vivo, porque Elephant sí puede recalcular por tecla. `[placeholders] "default".list = ""` (sin texto "No Results") y `hide_action_hints = true` (sin la barra de atajos Esc/Enter al pie) — ambos necesarios para que la ventana se vea como "solo el cuadro de búsqueda" en reposo; ver el detalle de por qué en la sección de abajo.
- `themes/dotfiles/`: copia de la carpeta `default` que trae el paquete, con `style.css` con los `@define-color` reescritos por `theme-switch.sh` (mismo patrón que `gtk-3.0/gtk.css`) y las reglas Flat Minimal aplicadas (radio 10px único, sin bordes — solo el `.box-wrapper` conserva su `box-shadow` de elevación, que no es un borde/marco), y `layout.xml` con `width-request` fijo (760px, antes 600) pero **sin `height-request` fijo** — la ventana debe crecer verticalmente recién cuando hay resultados (hasta `max-content-height=470` en el `Scroll`), no reservar un bloque grande y vacío desde que abre.

#### Por qué hizo falta tocar 3 lugares distintos para "que no se vea nada en reposo"

Verificado leyendo el código fuente real de Walker (`abenz1267/walker`, `src/ui/window.rs`), porque adivinar por prueba y error no alcanzó:

1. **`BoxWrapper` con `height-request` fijo** (760×640 original) reserva ese alto siempre, aunque no haya nada para mostrar — primer fix: sacar el `height-request` del `layout.xml` (el `width-request` sí se deja fijo, para que el ancho no "salte" mientras se escribe).
2. **El `Placeholder`** ("No Results") se fuerza a `visible = (n_items == 0)` **en código** (`handle_changed_items()`), así que un `visible="false"` puesto a mano en `layout.xml` no sirve de nada — Walker lo pisa. Lo que sí lee del archivo de configuración es el *texto*: `p.set_text(&placeholders.get(provider).list)`. Por eso el fix real es `[placeholders] "default".list = ""` en `config.toml`, no el XML.
3. **`Keybinds`** (la franja de atajos Esc/Enter al pie, con su propio `padding-top`/`border-top`) se deja visible siempre salvo que `cfg.hide_action_hints` sea `true` — y en ese caso el código simplemente *no* la toca (no hay un `set_visible(false)` explícito), así que además de `hide_action_hints = true` en `config.toml` hace falta poner `visible="false"` como default en `layout.xml` para que, al no tocarla nunca el código, se quede oculta.

La lección para cualquier ajuste futuro de Walker: **los valores que Walker recalcula en cada frame** (`Placeholder` visible/texto, `Scroll` visible, tamaño de `BoxWrapper` al reabrir) **hay que cambiarlos vía `config.toml`**, no en `layout.xml` — el XML solo manda para lo que el código nunca toca (`Keybinds` visible cuando `hide_action_hints=true`, `ElephantHint` que ya arrancaba en `false` en el tema original, tamaños que no estén fijados por config).

### X11/Qtile: sigue con rofi

Walker depende de `gtk4-layer-shell` (protocolo Wayland) — no corre bajo X11. Para el bind equivalente en Qtile (`qtile/modules/keys.py`, `mod+space`) se mantiene el buscador de rofi construido en el primer intento: `rofi/scripts/spotlight-launch.sh` (modo `combi` con `drun,run` + `rofi/scripts/spotlight-fallback.sh` como catch-all de texto sin match — cascada comando de shell → expresión matemática vía `bc`/`python3` → búsqueda web). Es el máximo real que rofi permite: precarga recientes (`lines: 5`, historial nativo de rofi) + filtrado en vivo de apps/comandos, con calculadora y búsqueda web resueltas al presionar Enter (sin preview mientras se escribe).

## Excepción conocida: herdr

`herdr` es un binario Rust de terceros — dibuja su propia UI (paneles, bordes) y no hay forma de aplicarle Flat Minimal a nivel estructural sin parchear su código fuente. Solo controlamos su paleta vía `[theme.custom]` en `herdr/config.toml`. Mismo color, no misma estructura — es la única excepción real del sistema.

## Verificación / rollback

`theme-switch.sh` no tiene backup automático — los `sed -i`/heredocs sobrescriben directo sobre archivos versionados en git. El rollback de emergencia:

```bash
git -C ~/dotfiles checkout -- dunst/dunstrc rofi/colors.rasi rofi/theme-drun.rasi \
  hypr/hyprland.conf herdr/config.toml lazy-nvim/lua/config/colors.lua \
  sublime-text/Packages/User/Kali-Red-Hack.sublime-color-scheme \
  walker/themes/dotfiles/style.css
```

El caso normal de "volver atrás" es simplemente re-aplicar el tema original: `theme <nombre>` sobrescribe todo de nuevo. Para Obsidian (vive en `/files/Personal-Vault`, un repo git aparte con remoto propio) el rollback es `git -C /files/Personal-Vault checkout -- .obsidian/themes/lc-red/theme.css .obsidian/appearance.json`.
