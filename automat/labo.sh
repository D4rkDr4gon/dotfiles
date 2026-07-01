#!/usr/bin/env bash
# ==============================================================================
# labo.sh — Wazuh + TheHive lab manager
# Enciende / apaga / muestra estado del laboratorio de seguridad
#
# Uso:
#   ./labo.sh start      → Arranca todo el stack
#   ./labo.sh stop       → Detiene todo
#   ./labo.sh restart    → Reinicia todo
#   ./labo.sh status     → Estado de cada contenedor
#   ./labo.sh logs       → Últimas líneas de logs de cada contenedor
#   ./labo.sh top        → Recursos en vivo de los contenedores
# ==============================================================================

DOCKER="docker"

CONTAINERS=(
  "cassandra"
  "elasticsearch"
  "cortex"
  "thehive"
  "wazuh-indexer"
  "wazuh-manager"
  "wazuh-dashboard"
)

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

check_docker() {
  if ! $DOCKER info >/dev/null 2>&1; then
    echo -e "${RED}[!] Docker no está corriendo.${NC}"
    echo -e "${YELLOW}   Esperá unos segundos o ejecutá cualquier comando docker para iniciarlo.${NC}"
    exit 1
  fi
}

containers_running_count() {
  local count=0
  for c in "${CONTAINERS[@]}"; do
    state=$($DOCKER inspect -f '{{.State.Running}}' "$c" 2>/dev/null)
    [[ "$state" == "true" ]] && ((count++))
  done
  echo "$count"
}

cmd_start() {
  echo -e "${CYAN}═══════════════════════════════════════${NC}"
  echo -e "${CYAN}  🚀 Arrancando laboratorio SOC...${NC}"
  echo -e "${CYAN}═══════════════════════════════════════${NC}"

  for c in "${CONTAINERS[@]}"; do
    echo -ne "${YELLOW}[...]${NC} $c ... "
    $DOCKER start "$c" >/dev/null 2>&1
    if [ $? -eq 0 ]; then
      echo -e "${GREEN}✅ OK${NC}"
    else
      echo -e "${RED}❌ ERROR${NC}"
    fi
  done

  echo ""
  cmd_status
  echo ""
  echo -e "${GREEN}✅ Laboratorio listo.${NC}"
}

cmd_stop() {
  echo -e "${CYAN}═══════════════════════════════════════${NC}"
  echo -e "${CYAN}  🛑 Deteniendo laboratorio SOC...${NC}"
  echo -e "${CYAN}═══════════════════════════════════════${NC}"

  for c in "${CONTAINERS[@]}"; do
    echo -ne "${YELLOW}[...]${NC} $c ... "
    $DOCKER stop "$c" >/dev/null 2>&1
    if [ $? -eq 0 ]; then
      echo -e "${GREEN}✅ OK${NC}"
    else
      echo -e "${RED}❌ ERROR${NC}"
    fi
  done

  echo ""
  cmd_status
  echo ""
  echo -e "${GREEN}✅ Laboratorio detenido. Ventiladores descansan.${NC}"
}

cmd_restart() {
  cmd_stop
  echo ""
  sleep 2
  cmd_start
}

cmd_status() {
  echo -e "${CYAN}═══════════════════════════════════════${NC}"
  echo -e "${CYAN}  📊 Estado del laboratorio${NC}"
  echo -e "${CYAN}═══════════════════════════════════════${NC}"

  $DOCKER ps -a --filter "name=cassandra" \
               --filter "name=elasticsearch" \
               --filter "name=cortex" \
               --filter "name=thehive" \
               --filter "name=wazuh" \
               --format "table {{.Names}}\t{{.Image}}\t{{.Status}}"

  local running=$(containers_running_count)
  local total=${#CONTAINERS[@]}
  echo ""
  if [ "$running" -eq "$total" ]; then
    echo -e "${GREEN}✅ $running/$total contenedores activos${NC}"
  elif [ "$running" -eq 0 ]; then
    echo -e "${RED}⛔ $running/$total contenedores activos${NC}"
  else
    echo -e "${YELLOW}⚠️  $running/$total contenedores activos${NC}"
  fi
}

cmd_logs() {
  for c in "${CONTAINERS[@]}"; do
    echo -e "${CYAN}──── $c ────${NC}"
    $DOCKER logs --tail 5 "$c" 2>/dev/null
    echo ""
  done
}

cmd_top() {
  echo -e "${CYAN}═══════════════════════════════════════${NC}"
  echo -e "${CYAN}  📈 Recursos del laboratorio${NC}"
  echo -e "${CYAN}═══════════════════════════════════════${NC}"
  $DOCKER stats --no-stream --filter "name=cassandra" \
                          --filter "name=elasticsearch" \
                          --filter "name=cortex" \
                          --filter "name=thehive" \
                          --filter "name=wazuh"
}

# ──────────────────────────────────────────────

case "${1:-}" in
  start)
    check_docker
    cmd_start
    ;;
  stop)
    check_docker
    cmd_stop
    ;;
  restart)
    check_docker
    cmd_restart
    ;;
  status)
    check_docker
    cmd_status
    ;;
  logs)
    check_docker
    cmd_logs
    ;;
  top)
    check_docker
    cmd_top
    ;;
  *)
    echo -e "${CYAN}Uso:${NC} $0 ${GREEN}start${NC}|${RED}stop${NC}|${YELLOW}restart${NC}|${CYAN}status${NC}|logs|top"
    echo ""
    echo "  start    → Arranca todo el stack (Wazuh + TheHive)"
    echo "  stop     → Detiene todo"
    echo "  restart  → Reinicia todo"
    echo "  status   → Muestra estado de cada contenedor"
    echo "  logs     → Últimas líneas de logs"
    echo "  top      → Recursos en vivo (CPU, RAM, NET, I/O)"
    exit 1
    ;;
esac
