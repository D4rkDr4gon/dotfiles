# Dunst -- Notification Center

## Diagrama de Arquitectura

```mermaid
graph TB
    subgraph Config["Archivo de Configuración"]
        DC[dunstrc<br/>Notificaciones + Centro de historial]
    end

    subgraph Notifications["Toast Notifications"]
        POS[top-right<br/>Offset (30, 50)]
        LIMIT[5 notis visibles<br/>20 en historial]
        URG[3 niveles: LOW, NORMAL, CRITICAL]
        STACK[Stack duplicados]
    end

    subgraph Center["Notification Center vía Rofi"]
        NC[notification-center.sh<br/>Summary + texto completo + Clear all]
        DND[dnd-menu.sh<br/>Toggle global + timer + apps silenciadas]
    end

    subgraph Integration["Integraciones"]
        QTL[Qtile hooks.py<br/>Autostart]
        PICO[Picom 85% opacidad]
        ROFI[theme.rasi<br/>Mismo estilo que launcher]
    end

    DC --> POS
    DC --> LIMIT
    DC --> URG
    DC --> STACK
    DC --> NC
    QTL --> DC
    PICO --> DC
    NC --> ROFI
    DND --> DC
    DND --> ROFI
```

## Archivos

| Archivo | Rol | Características Clave |
|---------|-----|----------------------|
| `dunst/dunstrc` | Configuración principal | 350px ancho, corner_radius 16px, font Hack Nerd Font 10, notification_limit 5, history_length 20 |
| `rofi/scripts/notification-center.sh` | Centro de notificaciones | Muestra resumen, abre texto completo con scroll, entrada "No Molestar", "Clear all", no se cierra hasta Escape |
| `rofi/scripts/dnd-menu.sh` | Gestor de No Molestar | Toggle global, temporizador con auto-desactivación (systemd-run --user), silenciar apps puntuales |
| `dunst/blocked-apps.conf` | Estado de apps silenciadas | `enabled<TAB>appname` por línea, tracked en git, regenera la sección de reglas en `dunstrc` |

## Proposito

Sistema de notificaciones con centro de historial integrado en Rofi.

- **Toast notifications**: Aparecen 15s en la esquina superior derecha con 85% de opacidad (Picom)
- **Notification center**: Accesible desde `Settings Menu` (`Mod + Shift + Space` > Notifications)
  o via `rofi/scripts/notification-center.sh`

## Integracion

- **Picom (X11)**: Aplica opacidad a Dunst y excluye esquinas redondeadas
- **Wayland**: Dunst no necesita compositor externo, funciona nativamente
- **Rofi**: El notification center usa `theme.rasi` para verse identico al launcher
  - Muestra solo el summary de cada notificacion (una linea limpia)
  - Al seleccionar una noti, abre el texto completo en ventana con scroll
  - Opcion "Clear all" para limpiar el historial
  - El centro no se cierra hasta presionar Escape
- **Qtile**: Dunst se inicia automaticamente via `hooks.py`
- **Startup**: Al iniciar sesion, se envia un "Bienvenido D4rkDr4g0n"

## Configuracion Principal

| Parametro | Valor | Descripcion |
|-----------|-------|-------------|
| `width` | `350` | Ancho de la notificacion en pixeles |
| `notification_limit` | `5` | Max notis visibles simultaneas |
| `origin` | `top-right` | Posicion en pantalla |
| `offset` | `(30, 50)` | Margen derecho 30px, superior 50px |
| `corner_radius` | `16` | Esquinas redondeadas |
| `font` | `Hack Nerd Font 10` | Tipografia |
| `history_length` | `20` | Maximo de notificaciones en historial |
| `stack_duplicates` | `true` | Agrupa notificaciones duplicadas |

## Urgencias

| Urgencia | Background | Foreground | Highlight | Timeout | Uso |
|----------|------------|------------|-----------|---------|-----|
| LOW | `chip_battery` | texto atenuado (45%) | `chip_wlan` | 10s | Notis informativas |
| NORMAL | `chip_battery` | `foreground` | `primary` | 15s | Notis generales |
| CRITICAL | `chip_battery` | `foreground` | `status_error` | Persiste | Alertas importantes |

> Estos 3 bloques ya no tienen colores fijos — los reescribe `theme-switch.sh`
> en cada `theme <nombre>` (ver sección de abajo). `corner_radius = 10`
> (antes 16), unificado con el resto del sistema.

## No Molestar (`dnd-menu.sh`)

Accesible desde `Settings Menu` (`Mod + Shift + Space` > Notifications >
"No Molestar") o directamente con `bash ~/dotfiles/rofi/scripts/dnd-menu.sh`.

**No usa `dunstctl set-paused`.** Se probó primero con `set-paused` y el
comportamiento no era el esperado: dunst no descarta las notis que llegan
pausado, las encola ("waiting") y las muestra todas de golpe como toast al
reanudar — justo lo que "No Molestar" no debería hacer. En su lugar, el
toggle usa una regla dunst propia `[dnd_global]` sin filtros (matchea todas
las notificaciones) con `skip_display = true`: con `skip_display`, dunst
manda la notificación directo al historial sin mostrarla nunca como toast,
ni en el momento ni después. Confirmado con `dunstctl count history/waiting/displayed`
en ambos casos.

| Función | Mecanismo | Detalle |
|---------|-----------|---------|
| Toggle global | `dunstctl rule dnd_global enable\|disable` + persistencia en `dunstrc` | Regla `[dnd_global]` (sin filtro, `skip_display = true`) entre los marcadores `DND-GLOBAL-BEGIN`/`END`. `dunstctl rule` cambia el estado en caliente; `set_dnd()` en `dnd-menu.sh` además reescribe el bloque en disco para que sobreviva a un reinicio del demonio |
| Temporizador | `systemd-run --user --unit=dnd-timer --on-active=<segs>` | Unidad transient (timer+service) que corre `dnd-menu.sh --disable-dnd` al vencer (no llama a `dunstctl` directo, para que la desactivación también persista en disco). Opciones: 1h, 2h, hasta mañana (08:00), personalizado. Se cancela con `systemctl --user stop dnd-timer.timer dnd-timer.service` si se apaga el modo a mano antes |
| Silenciar apps puntuales | Reglas dunst `skip_display = true` por `appname`, independientes del toggle global | Mismo mecanismo que el toggle pero con filtro `appname`. Cada app bloqueada vive como sección `[block_<nombre>]` autogenerada entre los marcadores `DND-APP-RULES-BEGIN`/`END`. El estado real (qué apps y si están activas) vive en `dunst/blocked-apps.conf` (`enabled<TAB>appname`, tracked en git); cada cambio reescribe la sección y corre `dunstctl reload` |

`dunstctl reload` (sin argumentos) relee el `dunstrc` con el que arrancó el
demonio — confirmado empíricamente, ya que dunst no soporta un `import`
real de otro archivo (ver nota de `theme-switch.sh` más abajo), así que las
reglas de apps silenciadas viven en el mismo `dunstrc`, no en un archivo aparte.
Las reglas de apps sí necesitan `reload` completo porque son secciones
nuevas; el toggle global y el timer no lo necesitan porque `dnd_global` ya
existe siempre en el archivo y solo cambia su `enabled` vía `dunstctl rule`.

El estado del temporizador (hasta cuándo queda activo) se guarda en
`~/.cache/dunst-dnd-until` — es efímero, no tracked en git.

## Integración con theme-switch.sh

`DUNST_CONFIG="$HOME/dotfiles/dunst/dunstrc"` — dunst no soporta `@import`
de otro archivo (es un único `dunstrc`), así que se editan los 3 bloques de
urgencia con `sed` por rango de dirección. `background` sale de
`chip_battery` (la superficie más sutil de la rampa, ver
`docs/design-system.md`); `highlight` (la barra de progreso del timeout)
pasa a ser el acento real de cada estado en vez de un gris fijo. Reload en
caliente real via `dunstctl reload` (dunst 1.9+, sin matar el proceso).
