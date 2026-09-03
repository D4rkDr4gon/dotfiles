# Herdr -- Multiplexor de agentes de IA

## Que es

Multiplexor de terminal (tipo tmux) pensado para agentes de codificacion en terminal (Claude Code, Codex, etc.). Un servidor en background posee los procesos de terminal reales; los clientes se conectan/desconectan sin matar nada. Reconoce el estado de cada agente (`working`, `blocked`, `done`, `idle`, `unknown`) y prioriza interaccion con mouse.

## Diagrama de Arquitectura

```mermaid
graph TB
    subgraph Config["Archivos de Configuracion"]
        CT[herdr/config.toml<br/>Unico archivo versionado]
    end

    subgraph Runtime["~/.config/herdr (NO versionado)"]
        SOCK[herdr.sock / herdr-client.sock]
        LOG[herdr-server.log / herdr-client.log]
        SESS[session.json<br/>Workspaces, tabs, panes vivos]
    end

    subgraph Theme["Sistema de Temas"]
        TS[theme-switch.sh<br/>Pisa theme.custom.*]
    end

    subgraph Launch["Lanzamiento"]
        HYPR[hyprland.conf<br/>Mod+Shift+Enter]
        QTILE[qtile/keys.py<br/>Mod+Shift+Enter]
        LS[herdr/launch.sh<br/>kitty -e herdr]
    end

    CT -->|symlink| RUNTIME_CT[~/.config/herdr/config.toml]
    TS --> CT
    HYPR --> LS
    QTILE --> LS
    LS -->|auto_detect_launch| SESS
```

## Por que solo se symlinkea `config.toml`

`~/.config/herdr/` mezcla configuracion con estado de runtime en vivo: sockets del servidor, logs y `session.json` (workspaces/tabs/panes activos). Symlinkear el directorio completo meteria ese estado dentro del repo de dotfiles. Por eso el patron acá es distinto al resto de los componentes: solo `~/.config/herdr/config.toml` es un symlink a `dotfiles/herdr/config.toml` — el resto del directorio queda intacto como estado local de la maquina.

## Prefix

Prefix custom: **`ctrl+space`** (el default de Herdr es `ctrl+b`, se cambio para no chocar con los bindings de Kitty `ctrl+shift+*` ni con Qtile `mod4`).

## Lanzamiento

`Mod + Shift + Enter` (identico en Hyprland y Qtile) ejecuta `herdr/launch.sh`, que corre `kitty --title herdr -e herdr`. El binario de Herdr detecta solo si ya hay un servidor corriendo (`auto_detect_launch()`) y se conecta a el, o arranca uno nuevo si no hay ninguno — no hace falta logica de attach propia.

## Configuracion Principal (`herdr/config.toml`)

| Seccion | Contenido |
|---------|-----------|
| `[keys]` | `prefix = "ctrl+space"`, navegacion de tabs/paneles, `prefix+a` cicla al siguiente agente (`next_agent`), comandos custom en popup: `prefix+alt+g` lazygit, `prefix+alt+e` nvim, `prefix+alt+o` opencode, `prefix+alt+t` btop, `prefix+alt+c` claude, `prefix+alt+d` lazydocker |
| `[theme]` | `name = "terminal"` (tema base incorporado; Herdr no acepta nombres de tema arbitrarios) |
| `[theme.custom]` | Overrides de color sobre el tema base — actualizados por `theme-switch.sh` en cada `theme <nombre>` |
| `[terminal]` | Shell/cwd por defecto |
| `[ui]` | Posicion de la tab bar, toasts |

Ver atajos completos en [keybindings.md](../keybindings.md#herdr----multiplexor-de-agentes-dentro-de-la-sesion).

## Integracion con el sistema de temas

`scripts/theme-switch.sh` pisa 8 claves de `[theme.custom]` con los colores del `theme.json` activo, y llama a `herdr server reload-config` en `reload_components()` para aplicarlos sin reiniciar la sesion:

| Clave en `[theme.custom]` | Fuente en `theme.json` |
|---|---|
| `sidebar_bg` | `background` |
| `active_row_bg` | `chip_bluetooth` |
| `selection_bg` | `secondary` |
| `accent` | `primary` |
| `blue` | `chip_audio` |
| `green` | `status_ok` |
| `red` | `status_error` |
| `yellow` | `status_warn` |

`status_ok`/`status_warn`/`status_error` son colores de estado semanticos (verde/amarillo/rojo) que cada `theme.json` define a mano para combinar con su paleta — reemplazan lo que antes eran valores fijos de Catppuccin sin relacion con el tema activo. Cualquier tema nuevo que se agregue a `themes/` debe incluir estas 3 claves ademas de las ya existentes.

> **Nota:** `theme.name` sigue fijo en `"terminal"` — Herdr valida el nombre contra una lista cerrada de temas incorporados (`catppuccin`, `nord`, `tokyo-night`, `gruvbox`, `one-dark`, etc.), no soporta un tema con nombre propio. Solo los colores de `[theme.custom]` son dinamicos.

## Diagnostico

| Problema | Comando |
|----------|---------|
| Agente no detectado | `herdr agent list` y `herdr agent explain <target> --json` |
| Config invalida tras editar | `herdr server reload-config` — devuelve `diagnostics` con las claves invalidas |
| Parar el servidor por completo | `herdr server stop` |
| Ver config activa resuelta | `herdr --default-config` (defaults) vs `herdr/config.toml` (overrides) |

**Docs oficiales:** https://herdr.dev/docs/
