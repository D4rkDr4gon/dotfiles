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
```

## Archivos

| Archivo | Rol | Características Clave |
|---------|-----|----------------------|
| `dunst/dunstrc` | Configuración principal | 350px ancho, corner_radius 16px, font Hack Nerd Font 10, notification_limit 5, history_length 20 |
| `rofi/scripts/notification-center.sh` | Centro de notificaciones | Muestra resumen, abre texto completo con scroll, "Clear all", no se cierra hasta Escape |

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

## Integración con theme-switch.sh

`DUNST_CONFIG="$HOME/dotfiles/dunst/dunstrc"` — dunst no soporta `@import`
de otro archivo (es un único `dunstrc`), así que se editan los 3 bloques de
urgencia con `sed` por rango de dirección. `background` sale de
`chip_battery` (la superficie más sutil de la rampa, ver
`docs/design-system.md`); `highlight` (la barra de progreso del timeout)
pasa a ser el acento real de cada estado en vez de un gris fijo. Reload en
caliente real via `dunstctl reload` (dunst 1.9+, sin matar el proceso).
