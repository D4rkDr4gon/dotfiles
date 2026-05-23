# opencode -- AI Assistant

**Ubicacion**: `opencode/`

## Archivos

| Archivo | Descripcion |
|---------|-------------|
| `opencode.jsonc` | Configuracion principal del asistente AI |
| `.gitignore` | Ignora runtime (node_modules, lock files) |
| `package.json` | Dependencias de plugins |
| `node_modules/` | Runtime instalado (gitignored) |

## opencode.jsonc

```jsonc
{
  "$schema": "https://opencode.ai/config.json",
  "skills": {
    "paths": ["/home/lcampassi/MY-AGENT-SKILLS"]
  }
}
```

### Configuracion

- **$schema**: Referencia al schema oficial de opencode
- **skills.paths**: Directorio donde residen las skills personalizadas

## Skills Personalizadas

Las skills viven en `/home/lcampassi/MY-AGENT-SKILLS/` e incluyen:

| Skill | Descripcion |
|-------|-------------|
| **dotfiles-manager** | Gestion de dotfiles: documentacion, creacion de temas, contexto completo del repositorio |

## Enlace Simbolico

```bash
~/.config/opencode -> ~/dotfiles/opencode/
```
