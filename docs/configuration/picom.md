# Picom -- Compositor

**Ubicacion**: `picom/picom.conf`

## Configuracion

| Parametro | Valor |
|-----------|-------|
| Backend | GLX |
| Vsync | true |
| Corner radius | 12px |
| Blur | dual_kawase (strength 6) |
| Shadows | Deshabilitados |
| Fade | true, 200ms transition |

## Opacity Rules

Ventanas con opacidad reducida:

| Ventana | Opacidad |
|---------|----------|
| Rofi | 80% |
| Polybar | 95% |
| Qtile | 95% |
| Kitty | 85% |
| Sublime Text | 95% |
| Obsidian | 95% |

## Exclusiones de Bordes Redondeados

No aplica border radius a:
- Docks
- Escritorio
- Polybar
- dmenu
- Ventanas con nombre `polybar*`

## Efectos

- **Blur dual_kawase**: Desenfoque de fondo con calidad media/alta
- **Fade**: Transiciones suaves de 200ms al abrir/cerrar/mapear ventanas
- **Sin sombras**: Estilo plano y limpio
