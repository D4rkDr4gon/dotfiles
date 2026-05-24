#!/bin/bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/lib/common.sh"

MODELS=(llama3.2 codellama mistral neural-chat qwen:7b)

main() {
    header "DESCARGANDO MODELOS OLLAMA"
    if ! command -v ollama &>/dev/null; then
        error "Ollama no instalado. Ejecuta install-ollama.sh primero"
    fi
    if ! systemctl is-active --quiet ollama; then
        info "Iniciando servicio Ollama..."
        sudo systemctl start ollama 2>/dev/null || ollama serve &
        sleep 2
    fi
    for model in "${MODELS[@]}"; do
        if ollama list | grep -q "$model"; then
            log "Modelo $model ya existe"
        else
            info "Descargando $model (~3-8GB)..."
            ollama pull "$model" && log "$model descargado" || warn "Fallo $model"
        fi
    done
    log "Modelos descargados (~15GB total)"
}
main "$@"
