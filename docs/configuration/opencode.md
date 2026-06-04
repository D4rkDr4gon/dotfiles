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
    "paths": ["/home/lcampassi/MY-AGENT-SKILLS/SKILLS"]
  },
  "agent": {
    "build": { "color": "#00B894" },
    "plan": { "color": "#FF9F43" },
    "general": { "color": "#A855F7" },
    "explore": { "color": "#0EA5E9" }
  },
  "mcpServers": {
    // MCP servers disponibles (comentados por defecto)
  }
}
```

### Configuracion

- **$schema**: Referencia al schema oficial de opencode
- **skills.paths**: Directorio donde residen las skills personalizadas
- **agent**: Personalización visual de agentes built-in
- **mcpServers**: Servidores MCP (Model Context Protocol) opcionales

## Agentes Disponibles

Los agentes se cargan desde `~/.config/opencode/agents/` (symlink a `opencode/agents/`).

### Primarios (Tab)
| Agente | Propósito |
|--------|-----------|
| `arch-sysadmin` | Administración Arch Linux |
| `windows-sysadmin` | Administración Windows 11 |
| `blue-copilot` | CSIRT, Forense, Blue Team |
| `red-copilot` | Pentesting, Red Team, CTF |
| `dev-copilot` | Desarrollo (Python, JS, Rust, C, Shell) |
| `agent-creator` | Creación de agentes |

### Subagentes (@mention)
| Agente | Invocado por | Propósito |
|--------|-------------|-----------|
| `@arch-delegate` | arch-sysadmin | Tareas menores Arch |
| `@arch-dotfiles` | arch-sysadmin | Documentación dotfiles |
| `@arch-Obsidian` | arch-sysadmin | Documentación en vault |
| `@windows-delegate` | windows-sysadmin | Tareas menores Windows |
| `@windows-docs` | windows-sysadmin | Documentación en vault |
| `@malware-analyst` | blue-copilot | Análisis de malware |
| `@log-analyst` | blue-copilot, arch-sysadmin, windows-sysadmin | Análisis de logs y SIEM |
| `@network-forensics` | blue-copilot | Forense de red y PCAP |
| `@osint-agent` | blue-copilot, red-copilot | OSINT y threat intel |

## Skills Personalizadas

Las skills viven en `/home/lcampassi/MY-AGENT-SKILLS/SKILLS/` e incluyen:

| Skill | Descripcion |
|-------|-------------|
| **arch-manager** | Contexto completo del sistema Arch |
| **windows-manager** | Contexto completo del sistema Windows |
| **dotfiles-manager** | Gestion de dotfiles |
| **obsidian-manager** | Gestion de vault Obsidian (cross-platform) |
| **ollama-manager** | Gestion de modelos locales Ollama |
| **openvpn-manager** | Conexiones OpenVPN para pentesting |
| **agent-creator** | Instrucciones para crear agentes |
| **docker-manager** | Docker/Podman y sandboxing |

## MCP Servers (Model Context Protocol)

Los MCP servers extienden las capacidades de opencode. Están preconfigurados en `opencode.jsonc` pero comentados. Para activarlos:

### Docker
```bash
# Instalar y descomentar en opencode.jsonc
npm install -g @anthropic/docker-mcp-server
# o via Docker: docker pull mcp/docker
```

### GitHub
```bash
npm install -g @modelcontextprotocol/server-github
# Configurar GITHUB_TOKEN en el env del server
```

### Filesystem
```bash
npm install -g @modelcontextprotocol/server-filesystem
# Configurar directorios permitidos en args
```

## Enlace Simbolico

```bash
# Linux
~/.config/opencode -> ~/dotfiles/opencode/

# Windows
# No hay symlink nativo, se usa copia directa en:
# C:\Users\lcampassi\.config\opencode\
```
