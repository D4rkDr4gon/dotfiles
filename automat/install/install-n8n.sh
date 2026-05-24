#!/bin/bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/lib/common.sh"

main() {
    check_arch
    header "N8N WORKFLOW AUTOMATION"
    if ! command -v yay &>/dev/null; then
        error "n8n requiere yay. Instala yay primero."
    fi
    install_yay_pkg "n8n"

    # Crear servicio de usuario para n8n
    mkdir -p "$HOME/.config/systemd/user"
    cat > "$HOME/.config/systemd/user/n8n.service" << 'EOF'
[Unit]
Description=n8n Workflow Automation
After=network.target

[Service]
Type=simple
ExecStart=/usr/bin/n8n start
Restart=on-failure
RestartSec=10

[Install]
WantedBy=default.target
EOF
    systemctl --user daemon-reload 2>/dev/null || true
    log "n8n instalado. Para habilitar: systemctl --user enable --now n8n"
    log "Web UI: http://localhost:5678"
}
main "$@"
