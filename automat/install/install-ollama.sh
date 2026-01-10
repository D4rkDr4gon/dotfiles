#!/bin/bash

# Script de instalación para Ollama y modelos de IA

set -euo pipefail

# Colores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1"
    exit 1
}

# Verificar si estamos en Arch
check_arch() {
    if [ ! -f /etc/arch-release ]; then
        error "Este script es solo para Arch Linux"
    fi
}

# Instalar Ollama
install_ollama() {
    log "Instalando Ollama..."
    
    if pacman -Q ollama >/dev/null 2>&1; then
        log "✓ Ollama ya está instalado"
    else
        sudo pacman -S --noconfirm ollama
        log "✓ Ollama instalado"
    fi
}

# Habilitar y configurar servicio Ollama
setup_ollama_service() {
    log "Configurando servicio Ollama..."
    
    # Habilitar servicio para que inicie automáticamente
    sudo systemctl enable ollama 2>/dev/null || true
    sudo systemctl start ollama 2>/dev/null || true
    
    # Verificar estado
    if systemctl is-active --quiet ollama; then
        log "✓ Servicio Ollama activo"
    else
        warn "Servicio Ollama no está activo. Requiere configuración manual:"
        echo "sudo systemctl enable ollama"
        echo "sudo systemctl start ollama"
    fi
}

# Descargar modelos populares
download_models() {
    log "Descargando modelos populares de Ollama..."
    
    local models=(
        "llama3.2"          # Modelo ligero y rápido
        "codellama"         # Para programación
        "mistral"           # Modelo equilibrado
        "neural-chat"       # Chat general
        "qwen:7b"           # Modelo ligero chino-inglés
    )
    
    for model in "${models[@]}"; do
        log "Descargando modelo: $model"
        if ollama list | grep -q "$model"; then
            log "✓ Modelo $model ya existe"
        else
            ollama pull "$model" && log "✓ Modelo $model descargado" || warn "✗ No se pudo descargar $model"
        fi
    done
}

# Instalar dependencias adicionales
install_dependencies() {
    log "Instalando dependencias adicionales..."
    
    local deps=(
        "curl"               # Para peticiones HTTP
        "jq"                 # Para procesar JSON
        "wget"               # Para descargas
        "git"                # Para repositorios
        "python"             # Para scripts
        "python-pip"         # Para paquetes Python
    )
    
    for dep in "${deps[@]}"; do
        if pacman -Q "$dep" >/dev/null 2>&1; then
            log "✓ $dep ya está instalado"
        else
            log "Instalando $dep..."
            sudo pacman -S --noconfirm "$dep"
        fi
    done
}

# Instalar herramientas Python para Ollama
install_python_tools() {
    log "Instalando herramientas Python para Ollama..."
    
    local python_packages=(
        "ollama"             # Cliente Python oficial
        "openai"             # Compatible con API OpenAI
        "requests"           # Para peticiones HTTP
        "python-dotenv"      # Para variables de entorno
    )
    
    for package in "${python_packages[@]}"; do
        if pip3 show "$package" >/dev/null 2>&1; then
            log "✓ $package ya está instalado"
        else
            log "Instalando $package..."
            pip3 install "$package"
        fi
    done
}

# Crear scripts de utilidad
create_utility_scripts() {
    log "Creando scripts de utilidad para Ollama..."
    
    local scripts_dir="$HOME/.local/bin"
    mkdir -p "$scripts_dir"
    
    # Script para verificar estado
    cat > "$scripts_dir/ollama-status" << 'EOF'
#!/bin/bash
echo "=== Estado de Ollama ==="
systemctl status ollama --no-pager -l
echo ""
echo "=== Modelos disponibles ==="
ollama list
echo ""
echo "=== Uso de recursos ==="
ps aux | grep ollama | grep -v grep || echo "Ollama no está ejecutándose"
EOF
    
    # Script para limpiar modelos
    cat > "$scripts_dir/ollama-cleanup" << 'EOF'
#!/bin/bash
echo "=== Limpiando caché de Ollama ==="
ollama gc
echo ""
echo "Espacio liberado en /usr/share/ollama:"
du -sh /usr/share/ollama/.ollama 2>/dev/null || echo "Directorio no encontrado"
EOF
    
    # Script para actualizar modelos
    cat > "$scripts_dir/ollama-update" << 'EOF'
#!/bin/bash
echo "=== Actualizando modelos de Ollama ==="
ollama list | awk 'NR>1 {print $1}' | while read model; do
    echo "Actualizando $model..."
    ollama pull "$model"
done
EOF
    
    # Hacer scripts ejecutables
    chmod +x "$scripts_dir"/ollama-*
    
    log "✓ Scripts de utilidad creados en $scripts_dir"
    log "Scripts disponibles:"
    echo "  ollama-status    - Verificar estado y modelos"
    echo "  ollama-cleanup   - Limpiar caché"
    echo "  ollama-update    - Actualizar modelos"
}

# Configurar variables de entorno
setup_environment() {
    log "Configurando variables de entorno..."
    
    # Nota: Las variables se configuran en el zshrc del repo y se gestionan con stow
    
    # Variables sugeridas para agregar al zshrc
    log "Variables de entorno sugeridas:"
    echo "export OLLAMA_HOST=127.0.0.1:11434"
    echo "export OLLAMA_MODELS=/usr/share/ollama/.ollama/models"
    echo "export PATH=\$HOME/.local/bin:\$PATH"
}

# Crear servicios de usuario opcionales
create_user_services() {
    log "Creando servicios de usuario opcionales..."
    
    local services_dir="$HOME/.config/systemd/user"
    mkdir -p "$services_dir"
    
    # Servicio para reiniciar ollama automáticamente si se cae
    cat > "$services_dir/ollama-auto-restart.service" << 'EOF'
[Unit]
Description=Ollama Auto Restart
After=network.target

[Service]
Type=oneshot
ExecStart=/usr/bin/systemctl --user restart ollama
RemainAfterExit=yes

[Install]
WantedBy=default.target
EOF
    
    log "✓ Servicio de usuario creado en $services_dir"
    echo "Para habilitar: systemctl --user enable ollama-auto-restart"
}

# Verificar instalación
verify_installation() {
    log "Verificando instalación de Ollama..."
    
    # Verificar comando ollama
    if command -v ollama >/dev/null 2>&1; then
        log "✓ ollama encontrado en: $(which ollama)"
        ollama --version | head -1
    else
        error "ollama no se encuentra en PATH"
    fi
    
    # Verificar servicio
    if systemctl is-active --quiet ollama; then
        log "✓ Servicio ollama activo"
    else
        warn "Servicio ollama inactivo"
    fi
    
    # Verificar modelos
    local model_count=$(ollama list 2>/dev/null | wc -l)
    if [ "$model_count" -gt 1 ]; then
        log "✓ $((model_count-1)) modelos instalados"
    else
        warn "No hay modelos instalados"
    fi
    
    # Verificar scripts de utilidad
    if [ -f "$HOME/.local/bin/ollama-status" ]; then
        log "✓ Scripts de utilidad instalados"
    fi
}

# Mostrar información post-instalación
show_post_install_info() {
    echo -e "${BLUE}========================================${NC}"
    echo -e "${BLUE}  USO DE OLLAMA${NC}"
    echo -e "${BLUE}========================================${NC}"
    echo -e "${GREEN}Comandos básicos:${NC}"
    echo "  ollama list                    - Listar modelos"
    echo "  ollama pull <modelo>          - Descargar modelo"
    echo "  ollama run <modelo>           - Ejecutar modelo"
    echo "  ollama show <modelo>          - Mostrar info del modelo"
    echo ""
    echo -e "${GREEN}Ejemplos de uso:${NC}"
    echo "  ollama run llama3.2 \"Hola, ¿cómo estás?\""
    echo "  ollama run codellama \"Escribe una función en Python\""
    echo ""
    echo -e "${GREEN}API HTTP:${NC}"
    echo "  curl http://localhost:11434/api/generate -d '{\"model\":\"llama3.2\",\"prompt\":\"Hola\"}'"
    echo ""
    echo -e "${GREEN}Scripts de utilidad:${NC}"
    echo "  ollama-status                 - Verificar estado"
    echo "  ollama-cleanup               - Limpiar caché"
    echo "  ollama-update                - Actualizar modelos"
}

# Función principal
main() {
    echo -e "${BLUE}========================================${NC}"
    echo -e "${BLUE}  INSTALADOR DE OLLAMA${NC}"
    echo -e "${BLUE}========================================${NC}"
    
    check_arch
    install_dependencies
    install_ollama
    setup_ollama_service
    install_python_tools
    create_utility_scripts
    create_user_services
    setup_environment
    download_models
    verify_installation
    show_post_install_info
    
    echo -e "${GREEN}========================================${NC}"
    echo -e "${GREEN}  INSTALACIÓN DE OLLAMA COMPLETADA${NC}"
    echo -e "${GREEN}========================================${NC}"
}

main "$@"