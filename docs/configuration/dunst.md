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

- **Picom**: Aplica 85% de opacidad a Dunst (misma que Rofi) y excluye esquinas redondeadas
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

| Urgencia | Background | Foreground | Timeout | Uso |
|----------|------------|------------|---------|-----|
| LOW | `#141414` | `#969696` | 10s | Notis informativas |
| NORMAL | `#141414` | `#E6E6E6` | 15s | Notis generales |
| CRITICAL | `#141414` | `#FFFFFF` | Persiste | Alertas importantes |
