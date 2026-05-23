# Rofi -- Application Launcher

**Ubicacion**: `rofi/`

## Archivos

| Archivo | Descripcion |
|---------|-------------|
| `config.rasi` | Configuracion de modos (drun, run, window) |
| `theme.rasi` | Tema visual personalizado |
| `favoritos.txt` | Lista de apps favoritas |
| `scripts/` | Scripts para funcionalidades extendidas |

## Configuracion

- **Modos**: drun (apps instaladas), run (comandos), window (ventanas activas)
- **Sort**: fzf-style fuzzy matching
- **Iconos**: Habilitados en las entradas

## Tema

- **Posicion**: Norte (top)
- **Ancho**: 480px
- **Border radius**: 24px
- **Fondo**: Oscuro semi-transparente
- **Font**: Nerd Font para iconos
- **Elementos**: Esquinas redondeadas en todos los componentes

## Scripts

| Script | Descripcion |
|--------|-------------|
| `launcher.sh` | App launcher custom con soporte para "g <query>" (Google search) |
| `emoji.sh` | Emoji picker (800+ emojis), copia al portapapeles |
| `qtile-action-menu.sh` | Acciones del sistema: Suspend, Reboot, Poweroff, Logout |
| `qtile-workspace-switcher.sh` | Selector de workspaces (NOTES/FILES/DEV/SYS/WEB) |
| `settings-menu.sh` | Menu central: Themes, Workspaces, Web search, Backgrounds |
| `web-search.sh` | Busqueda en Google, abre Firefox en WEB workspace |

## Acceso

- `Mod + Space` -- App launcher
- `Mod + L` -- Action menu (suspend/reboot/poweroff/logout)
- `Mod + Shift + Space` -- Settings menu
