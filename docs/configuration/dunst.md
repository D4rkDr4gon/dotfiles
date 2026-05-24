# Dunst -- Notification Center

## Proposito

Sistema de notificaciones con centro de historial integrado en Rofi.

- **Toast notifications**: Aparecen 15s en la esquina superior derecha con 85% de opacidad (Picom)
- **Notification center**: Accesible desde `Settings Menu` (`Mod + Shift + Space` > Notifications)
  o via `rofi/scripts/notification-center.sh`

## Archivos

| Archivo | Proposito |
|---------|-----------|
| `dunst/dunstrc` | Configuracion principal de Dunst |
| `rofi/scripts/notification-center.sh` | Notification center en Rofi |

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
