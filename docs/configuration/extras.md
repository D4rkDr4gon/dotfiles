# Extras

## OneDrive

**Ubicacion**: `onedrive/`

Sincronizacion con Microsoft OneDrive para backup de configuraciones y documentos.

| Archivo | Descripcion |
|---------|-------------|
| `config` | Configuracion del cliente: sync_dir = ~/OneDrive, optimizado para Obsidian (atomic writes), skip temp files, notificaciones desactivadas |
| `sync_list` | Lista de archivos/dirs a sincronizar |

## Recursos (`recursos/`)

### Wallpapers

18+ wallpapers en `recursos/wallpapers/` con tematica cyberpunk, sci-fi, hacker, ciudades.

### gastos.py

**Ubicacion**: `recursos/finnancials/gastos.py`

TUI (Terminal User Interface) expense manager construido con la libreria `textual` de Python.

**Caracteristicas**:
- SQLite backend
- Multi-cuenta
- Multi-moneda (ARS, USD, USDT, EUR, BTC)
- Categorias con presupuestos
- CRUD completo de transacciones
- Exportacion a CSV
- Dashboard con net worth y estadisticas mensuales
- Datos almacenados en `~/.local/share/gastos/`

### ASCII Art

| Archivo | Contenido |
|---------|-----------|
| `logo.txt` | Dragon ASCII art con colores ANSI |
| `tux.txt` | Tux (pinguino de Linux) ASCII |
| `logo-bloqueo.png` | Imagen para pantalla de bloqueo |

## Theme Manager

**Ubicacion**: `recursos/Theme-Manager/Palettes/`

Contiene paletas de temas, incluyendo `Fiery-Red-Sunset.theme` como referencia para crear nuevos esquemas de color.

## Scripts Utilitarios (`scripts/`)

| Script | Descripcion |
|--------|-------------|
| `theme-switch.sh` | Sistema central de cambio de temas. Actualiza polybar, kitty, zsh, qtile y fastfetch con los colores del tema seleccionado |

## nvchad/ (Placeholder)

Directorio vacio para una configuracion alternativa de Neovim usando NvChad. Actualmente no en uso.
