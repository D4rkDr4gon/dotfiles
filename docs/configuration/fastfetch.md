# Fastfetch -- System Info

**Ubicacion**: `fastfetch/`

## Archivos

| Archivo | Descripcion |
|---------|-------------|
| `config.jsonc` | Configuracion principal del display |
| `ascii/` | Logos ASCII (arch.txt, cat.txt, rose.txt) |
| `png/` | Logos PNG para mostrar como imagen |

## Configuracion

Fastfetch muestra informacion del sistema con un logo aleatorio de la carpeta `png/`.

### Datos Mostrados

- **OS**: Distribucion y kernel
- **DE/WM**: Entorno de escritorio / Qtile
- **Packages**: Paquetes instalados (pacman, yay, etc.)
- **Hardware**: Host, CPU, GPU, Memoria, Swap, Disk
- **Battery**: Estado de bateria
- **Uptime**: Tiempo de actividad
- **Terminal**: Kitty
- **Locale**: Idioma/configuracion regional

### Estilo

- **Separator**: ` ▸ `
- **Iconos**: Nerd Font con colores por categoria
- **Color blocks**: Barra de colores al final del output
- **Colores dinamicos**: Actualizados por el tema activo

## Logo Aleatorio

Al ejecutar `fastfetch`, se selecciona un logo PNG al azar de `fastfetch/png/`, que incluye variantes de Arch Linux, logos personalizados, y otros graficos.
