#!/usr/bin/env bash
# ==============================================================================
# labo.sh — Wazuh + TheHive lab manager
# Enciende / apaga / muestra estado del laboratorio de seguridad
#
# Uso:
#   ./labo.sh start      → Arranca Docker + todo el stack
#   ./labo.sh stop       → Detiene todo + apaga Docker
#   ./labo.sh restart    → Reinicia todo
#   ./labo.sh status     → Estado de cada contenedor
#   ./labo.sh logs       → Últimas líneas de logs de cada contenedor
#   ./labo.sh top        → Recursos en vivo de los contenedores
# ==============================================================================

DOCKER_SERVICE="docker.service"
DOCKER_SOCKET="docker.socket"

# Detectar si el usuario necesita sudo para docker
# (grupo docker puede no estar activo en la sesión actual)
DOCKER="docker"
if ! docker info >/dev/null 2>&1; then
  if sudo docker info >/dev/null 2>&1; then
    DOCKER="sudo docker"
    echo -e "${YELLOW}ℹ️  Usando 'sudo docker' (permisos de socket)${NC}"
  fi
fi

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
GRAY='\033[0;90m'
NC='\033[0m' # No Color

# ──────────────────────────────────────────────
# Funciones auxiliares
# ──────────────────────────────────────────────

docker_is_running() {
  $DOCKER info >/dev/null 2>&1
}

docker_daemon_start() {
  # Asegurar que docker.socket esté activo (evita socket-activation colgada)
  if ! systemctl is-active --quiet "$DOCKER_SOCKET" 2>/dev/null; then
    echo -e "${YELLOW}[...]${NC} Activando docker.socket..."
    sudo systemctl start "$DOCKER_SOCKET" 2>/dev/null
  fi

  echo -e "${YELLOW}[...]${NC} Iniciando servicio Docker (systemctl)..."
  if systemctl is-active --quiet "$DOCKER_SERVICE" 2>/dev/null; then
    echo -e "${GREEN}✅${NC} Docker ya estaba corriendo"
    return 0
  fi

  sudo systemctl start "$DOCKER_SERVICE" 2>/dev/null
  if [ $? -ne 0 ]; then
    echo -e "${RED}❌ No se pudo iniciar docker.service${NC}"
    exit 1
  fi

  # Esperar a que el socket esté listo (timeout 60s)
  # Nota: después de un crash, Docker puede tardar en recuperar redes/containers
  echo -ne "${YELLOW}[...]${NC} Esperando a que Docker responda..."
  local timeout=60
  while [ $timeout -gt 0 ]; do
    if docker_is_running; then
      echo -e " ${GREEN}✅${NC}"
      # Pausa de estabilización: el daemon terminó de arrancar pero puede estar
      # recargando contenedores o redes. 3 segundos extras evitan carreras.
      sleep 3
      return 0
    fi
    sleep 1
    ((timeout--))
  done

  echo -e " ${RED}❌ Timeout esperando a Docker${NC}"
  exit 1
}

docker_daemon_stop() {
  echo -e "${YELLOW}[...]${NC} Deteniendo servicio Docker (systemctl)..."
  local was_active=false
  if systemctl is-active --quiet "$DOCKER_SERVICE" 2>/dev/null; then
    was_active=true
  fi

  # 1. Detener el servicio (si está activo)
  if [ "$was_active" = true ]; then
    sudo systemctl stop "$DOCKER_SERVICE" 2>/dev/null
    if [ $? -ne 0 ]; then
      echo -e "${RED}❌ Error al detener docker.service${NC}"
      return 1
    fi

    # Esperar confirmación de que realmente se detuvo (timeout 15s)
    echo -ne "${YELLOW}[...]${NC} Esperando confirmación..."
    local timeout=15
    while [ $timeout -gt 0 ]; do
      if ! systemctl is-active --quiet "$DOCKER_SERVICE" 2>/dev/null; then
        echo -e " ${GREEN}✅${NC}"
        break
      fi
      sleep 1
      ((timeout--))
    done
    if systemctl is-active --quiet "$DOCKER_SERVICE" 2>/dev/null; then
      echo -e " ${YELLOW}⚠️  timeout, pero debería estar apagándose${NC}"
    fi
  else
    echo -e "${GREEN}✅${NC} Docker ya estaba detenido"
  fi

  # 2. Detener también docker.socket para evitar reactivación accidental
  if systemctl is-active --quiet "$DOCKER_SOCKET" 2>/dev/null; then
    echo -e "${YELLOW}[...]${NC} Deteniendo docker.socket (evita reactivación)..."
    sudo systemctl stop "$DOCKER_SOCKET" 2>/dev/null
    if [ $? -eq 0 ]; then
      echo -e "${GREEN}✅${NC} Socket detenido"
    else
      echo -e "${RED}❌ Error al detener docker.socket${NC}"
    fi
  fi

  return 0
}

check_docker_or_die() {
  if ! docker_is_running; then
    echo -e "${RED}[!] Docker no está corriendo.${NC}"
    echo -e "${YELLOW}   Usá './labo.sh start' para iniciar el servicio primero.${NC}"
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

# ──────────────────────────────────────────────
# Comandos
# ──────────────────────────────────────────────

cmd_start() {
  echo -e "${CYAN}═══════════════════════════════════════${NC}"
  echo -e "${CYAN}  🚀 Arrancando laboratorio SOC...${NC}"
  echo -e "${CYAN}═══════════════════════════════════════${NC}"

  # 1. Iniciar el daemon de Docker si no está corriendo
  docker_daemon_start

  # 2. Arrancar los contenedores (con reintento si fallan)
  local failures=0
  for c in "${CONTAINERS[@]}"; do
    echo -ne "${YELLOW}[...]${NC} $c ... "
    if $DOCKER start "$c" >/dev/null 2>&1; then
      echo -e "${GREEN}✅ OK${NC}"
    else
      # Reintento único después de 1 segundo
      sleep 1
      if $DOCKER start "$c" >/dev/null 2>&1; then
        echo -e "${GREEN}✅ OK (reintento)${NC}"
      else
        echo -e "${RED}❌ ERROR${NC}"
        ((failures++))
      fi
    fi
  done

  echo ""
  cmd_status

  if [ "$failures" -eq 0 ]; then
    echo -e "${GREEN}✅ Laboratorio listo. Todos los servicios activos.${NC}"
  else
    echo -e "${YELLOW}⚠️  Laboratorio parcial ($failures contenedores con error).${NC}"
    echo -e "${YELLOW}   Revisá con: ./labo.sh logs${NC}"
  fi
}

cmd_stop() {
  echo -e "${CYAN}═══════════════════════════════════════${NC}"
  echo -e "${CYAN}  🛑 Deteniendo laboratorio SOC...${NC}"
  echo -e "${CYAN}═══════════════════════════════════════${NC}"

  # 1. Detener los contenedores (solo si Docker está corriendo)
  if docker_is_running; then
    for c in "${CONTAINERS[@]}"; do
      echo -ne "${YELLOW}[...]${NC} $c ... "
      if $DOCKER stop "$c" >/dev/null 2>&1; then
        echo -e "${GREEN}✅ OK${NC}"
      else
        echo -e "${GRAY}➖ no corriendo${NC}"
      fi
    done

    echo ""
    cmd_status
    echo ""

    # Pequeña pausa para que Docker termine de liberar recursos
    sleep 2
  else
    echo -e "${YELLOW}[!] Docker no está corriendo — salteando parada de contenedores${NC}"
    echo ""
  fi

  # 2. Detener el daemon de Docker
  docker_daemon_stop
  echo ""
  echo -e "${GREEN}✅ Laboratorio apagado. Ventiladores descansan.${NC}"
}

cmd_restart() {
  echo -e "${CYAN}═══════════════════════════════════════${NC}"
  echo -e "${CYAN}  🔄 Reiniciando laboratorio SOC...${NC}"
  echo -e "${CYAN}═══════════════════════════════════════${NC}"

  # Estrategia: solo reiniciamos contenedores, sin tocar el daemon.
  # Si Docker no está corriendo, cmd_start lo levanta.

  if docker_is_running; then
    for c in "${CONTAINERS[@]}"; do
      echo -ne "${YELLOW}[...]${NC} $c ... "
      if $DOCKER restart "$c" >/dev/null 2>&1; then
        echo -e "${GREEN}✅ OK${NC}"
      else
        echo -e "${RED}❌ ERROR${NC}"
      fi
    done
  else
    echo -e "${YELLOW}[!] Docker no está corriendo, arrancando desde cero...${NC}"
    echo ""
    cmd_start
    return
  fi

  echo ""
  cmd_status
  echo -e "${GREEN}✅ Laboratorio reiniciado.${NC}"
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
  check_docker_or_die
  for c in "${CONTAINERS[@]}"; do
    echo -e "${CYAN}──── $c ────${NC}"
    $DOCKER logs --tail 5 "$c" 2>/dev/null || echo -e "${GRAY}(sin logs)${NC}"
    echo ""
  done
}

cmd_top() {
  check_docker_or_die
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
    cmd_start
    ;;
  stop)
    cmd_stop
    ;;
  restart)
    cmd_restart
    ;;
  status)
    check_docker_or_die
    cmd_status
    ;;
  logs)
    check_docker_or_die
    cmd_logs
    ;;
  top)
    check_docker_or_die
    cmd_top
    ;;
  *)
    echo -e "${CYAN}Uso:${NC} $0 ${GREEN}start${NC}|${RED}stop${NC}|${YELLOW}restart${NC}|${CYAN}status${NC}|logs|top"
    echo ""
    echo "  start    → Inicia Docker + arranca contenedores (Wazuh + TheHive)"
    echo "  stop     → Detiene contenedores + apaga Docker"
    echo "  restart  → Reinicia solo contenedores (no toca el daemon)"
    echo "  status   → Muestra estado de cada contenedor"
    echo "  logs     → Últimas líneas de logs"
    echo "  top      → Recursos en vivo (CPU, RAM, NET, I/O)"
    exit 1
    ;;
esac
