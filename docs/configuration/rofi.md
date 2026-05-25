# Rofi -- Application Launcher

## Diagrama de Arquitectura

```mermaid
graph TB
    subgraph Config["Archivos de Configuración"]
        CR[config.rasi<br/>Modos: drun, run, window]
        TR[theme.rasi<br/>Tema visual general]
    end

    subgraph Themes["Temas Específicos"]
        TDR[theme-drun.rasi<br/>Grid Android 5x4]
        TAR[theme-action.rasi<br/>Grid iconos 4x1]
    end

    subgraph Scripts["Scripts"]
        LAUNCH[launcher.sh<br/>App launcher + Google search]
        EMOJI[emoji.sh<br/>800+ emojis]
        QACT[qtile-action-menu.sh<br/>Suspend, Reboot, Poweroff, Logout]
        QWS[qtile-workspace-switcher.sh<br/>Selector workspaces]
        SETT[settings-menu.sh<br/>Menú central]
        WS[web-search.sh<br/>Búsqueda en Google]
        NC[notification-center.sh<br/>Centro de notificaciones]
    end

    subgraph Access["Atajos"]
        MS[Mod + Space]
        ML[Mod + L]
        MSS[Mod + Shift + Space]
    end

    CR --> TR
    TR --> TDR
    TR --> TAR
    TR --> LAUNCH
    TR --> EMOJI
    TR --> QACT
    TR --> QWS
    TR --> SETT
    TR --> WS
    TR --> NC
    MS --> TDR
    ML --> TAR
    MSS --> SETT
```

## Archivos

| Archivo | Rol | Características Clave |
|---------|-----|----------------------|
| `config.rasi` | Configuración de modos | drun, run, window, fuzzy matching fzf-style |
| `theme.rasi` | Tema visual general | Norte, 480px, border-radius 24px, fondo oscuro |
| `theme-drun.rasi` | Grid app launcher | 5 columnas x 4 filas, iconos 36px, 680px ancho |
| `theme-action.rasi` | Grid acciones | 4 columnas x 1 fila, icono + texto, 520px ancho |
| `favoritos.txt` | Apps favoritas | Lista de aplicaciones favoritas |
| `scripts/` | Scripts extendidos | Launcher, emoji, acciones, workspaces, settings, web, notificaciones |

**Ubicacion**: `rofi/`

## Configuracion

- **Modos**: drun (apps instaladas), run (comandos), window (ventanas activas)
- **Sort**: fzf-style fuzzy matching
- **Iconos**: Habilitados en las entradas

## Tema Action (Grid Iconos)

`theme-action.rasi` se usa para el menu de acciones (`Mod+L`):

- **Grid**: 4 columnas x 1 fila, icono arriba + texto abajo
- **Window**: centrado, 520px de ancho
- **Acciones**: Suspend, Reboot, Poweroff, Logout

## Tema Drun (Android Grid)

`theme-drun.rasi` se usa exclusivamente para el app launcher (`Mod+Space`):

- **Grid**: 5 columnas x 4 filas
- **Layout**: icono arriba, texto abajo (vertical)
- **Window**: centrado, 680px de ancho
- **Iconos**: 36px

## Tema General

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
| `settings-menu.sh` | Menu central: Themes, Workspaces, Apps, Web search, Backgrounds |
| `web-search.sh` | Busqueda en Google, abre Firefox en WEB workspace |

## Acceso

- `Mod + Space` -- App launcher (grid Android-style 5x4)
- `Mod + L` -- Action menu (suspend/reboot/poweroff/logout)
- `Mod + Shift + Space` -- Settings menu
