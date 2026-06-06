# GTK3 — Tema Base y CSS Dinámico

**Ubicacion**: `gtk-3.0/`

## Propósito

Personalización visual de aplicaciones GTK3, principalmente **Thunar** (file manager) y otras apps GTK3 del sistema. Combina un archivo de configuración estático (`settings.ini`) con un archivo CSS generado dinámicamente por el sistema de temas (`theme-switch.sh`).

## Archivos

| Archivo | Rol | Actualización |
|---------|-----|---------------|
| `settings.ini` | Configuración base del tema GTK (theme name, icon theme, font) | Manual / estático |
| `~/.config/gtk-3.0/gtk.css` | Estilos visuales dinámicos para Thunar y apps GTK3 | Generado automáticamente por `theme-switch.sh` |

## settings.ini

Define el tema GTK base, set de iconos y fuente. No se modifica al cambiar de tema dinámico:

```ini
[Settings]
gtk-theme-name=Matcha-dark-aliz
gtk-icon-theme-name=Papirus-Dark
gtk-font-name=Sans 10
gtk-application-prefer-dark-theme=1
```

## gtk.css (Generado por theme-switch.sh)

El `theme-switch.sh` genera `~/.config/gtk-3.0/gtk.css` con estilos que siguen la paleta del tema activo. Usa `@define-color` para las variables de color y la función CSS `shade()` para variantes.

### Variables de Color

| Variable | Fuente en theme.json |
|----------|---------------------|
| `@theme_bg` | `background` |
| `@theme_fg` | `foreground` |
| `@theme_primary` | `primary` |
| `@theme_secondary` | `secondary` |
| `@theme_selected_bg` | `primary` |
| `@theme_selected_fg` | `#ffffff` (fijo) |

### Selectores CSS Afectados

| Selector | Descripción |
|----------|-------------|
| `.thunar` | Ventana principal |
| `.thunar .sidebar` | Panel lateral (tree view) |
| `.thunar .sidebar .view` | Items del panel lateral |
| `.thunar .sidebar .view:selected` | Item seleccionado en sidebar |
| `.thunar .standard-view` | Área de archivos |
| `.thunar .standard-view .view` | Items en vista de archivos |
| `.thunar .standard-view .view:selected` | Item seleccionado |
| `.thunar .location-bar` | Barra de ubicación |
| `.thunar .path-bar button` | Botones de ruta |
| `.thunar toolbar` | Barra de herramientas |
| `.thunar toolbar button` | Botones de la toolbar |
| `treeview` | Columnas de vista detallada |
| `treeview:selected` | Fila seleccionada |
| `treeview header button` | Encabezados de columna |
| `scrollbar` | Scrollbars |
| `scrollbar slider` | Slider de scrollbar |
| `entry` | Campos de texto (búsqueda, location) |
| `entry:focus` | Campo de texto con foco |
| `menu` | Menús contextuales |
| `menu menuitem:hover` | Item de menú hover |
| `tooltip` | Tooltips |

### Ejemplo de Generación

```css
@define-color theme_bg #1d1a22;
@define-color theme_fg #c8c8c8;
@define-color theme_primary #b6896d;
@define-color theme_secondary #777777;

.thunar {
  background-color: @theme_bg;
  color: @theme_fg;
}

.thunar .sidebar {
  background-color: shade(@theme_bg, 0.95);
  border-right: 1px solid shade(@theme_bg, 1.3);
}
```

## Recarga de Estilos

El CSS no se recarga en caliente. Si Thunar está abierto al cambiar de tema, `theme-switch.sh` lo cierra automáticamente con `thunar -q` para que los nuevos estilos se apliquen al re-abrirlo.

```bash
# Manual: cerrar Thunar para forzar recarga de estilos
thunar -q
```

## Enlace Simbólico

```bash
~/.config/gtk-3.0/settings.ini -> ~/dotfiles/gtk-3.0/settings.ini
```

El `gtk.css` se genera en `~/.config/gtk-3.0/gtk.css` directamente por `theme-switch.sh`, no tiene symlink.
