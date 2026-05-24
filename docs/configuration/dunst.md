# Dunst -- Notification Center

## Proposito

Sistema de notificaciones con centro de historial integrado.
- **Toast notifications**: Aparecen temporalmente en la esquina superior derecha
- **Notification center**: Accesible desde el Settings Menu (`Mod + Shift + Space` > Notifications)
  o via `rofi/scripts/notification-center.sh`

## Archivos

| Archivo | Proposito |
|---------|-----------|
| `dunst/dunstrc` | Configuracion principal de Dunst |

## Integracion

- **Picom**: Aplica 85% de opacidad a Dunst (misma que Rofi) y excluye esquinas redondeadas
- **Rofi**: El notification center usa `theme.rasi` para verse identico al launcher
- **Qtile**: Dunst se inicia automaticamente via `hooks.py`

## Configuracion Principal

| Parametro | Valor | Descripcion |
|-----------|-------|-------------|
| `geometry` | `300x5-30+50` | 300px ancho, 5 notif, margen der 30, margen sup 50 |
| `corner_radius` | `16` | Esquinas redondeadas |
| `font` | `Hack Nerd Font 10` | Tipografia |
| `history_length` | `20` | Maximo de notificaciones en historial |
| `stack_duplicates` | `true` | Agrupa notificaciones duplicadas |

## Urgencias

| Urgencia | Background | Foreground | Timeout |
|----------|------------|------------|---------|
| LOW | `#141414` | `#969696` | 5s |
| NORMAL | `#141414` | `#E6E6E6` | 8s |
| CRITICAL | `#141414` | `#FFFFFF` | Persiste |
