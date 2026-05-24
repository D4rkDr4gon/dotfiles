#!/bin/bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/lib/common.sh"

MODELS=(llama3.2 codellama mistral neural-chat qwen:7b)

main() {
    check_arch
    header "OLLAMA"
    install_pacman_pkg "ollama"
    sudo systemctl enable ollama 2>/dev/null || true
    sudo systemctl start ollama 2>/dev/null || true

    if systemctl is-active --quiet ollama; then
        log "Servicio Ollama activo"
    else
        warn "Servicio Ollama no activo. Revisa: sudo systemctl status ollama"
    fi

    # Scripts de utilidad
    mkdir -p "$HOME/.local/bin"
    cat > "$HOME/.local/bin/ollama-status" << 'EOF'
#!/bin/bash
systemctl status ollama --no-pager -l
echo "=== Modelos ==="
ollama list
EOF
    chmod +x "$HOME/.local/bin/ollama-status"
    log "Script ollama-status creado en ~/.local/bin"
    log "Ollama instalado. Para descargar modelos: bash $SCRIPT_DIR/../ollama-pull.sh"
}
main "$@"
