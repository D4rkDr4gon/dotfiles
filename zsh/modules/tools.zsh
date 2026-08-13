# ====== TOOLS ======

# Extract nmap information
function extractPorts(){
	ports="$(cat $1 | grep -oP '\d{1,5}/open' | awk '{print $1}' FS='/' | xargs | tr ' ' ',')"
	ip_address="$(cat $1 | grep -oP '\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}' | sort -u | head -n 1)"
	echo -e "\n[*] Extracting information...\n" > extractPorts.tmp
	echo -e "\t[*] IP Address: $ip_address"  >> extractPorts.tmp
	echo -e "\t[*] Open ports: $ports\n"  >> extractPorts.tmp
	echo $ports | tr -d '\n' | xclip -sel clip
	echo -e "[*] Ports copied to clipboard\n"  >> extractPorts.tmp
	cat extractPorts.tmp; rm extractPorts.tmp
}

#Codificacion hexa decimal
function hex-encode()
{
  echo "$@" | xxd -p
}

#Decodificacion hexa decimal
function hex-decode()
{
  echo "$@" | xxd -p -r
}

function rot13()
{
  echo "$@" | tr 'A-Za-z' 'N-ZA-Mn-za-m'
}

# ====== OLLAMA LOCAL AI ======

# Ollama CPU optimizations — Ryzen 7 5825U (8 physical cores)
export OLLAMA_NUM_THREADS=8
export OLLAMA_NUM_PARALLEL=1
export OLLAMA_KEEP_ALIVE=5m

# Start Ollama server in background (on-demand)
function ollama-up() {
  if pgrep -f "ollama serve" > /dev/null; then
    echo "󱙺 Ollama ya está corriendo"
  else
    echo "󱙺 Levantando Ollama..."
    ollama serve &>/dev/null &
    disown
    sleep 2
    echo "󱙺 Ollama iniciado"
  fi
}

# Stop Ollama server
function ollama-down() {
  if pgrep -f "ollama serve" > /dev/null; then
    kill $(pgrep -f "ollama serve")
    echo "󱙺 Ollama detenido"
  else
    echo "󱙺 Ollama no está corriendo"
  fi
}

# Quick test — run a model and measure time
function ollama-test() {
  local model="${1:-qwen3:1.7b}"
  local prompt="${2:-Decime hola en 5 palabras}"
  echo "󱙺 Test: $model"
  echo "Prompt: \"$prompt\""
  echo "---"
  time curl -s -X POST http://localhost:11434/api/generate \
    -H 'Content-Type: application/json' \
    -d "{\"model\": \"$model\", \"prompt\": \"$prompt\", \"stream\": false, \"options\": {\"temperature\": 0.3, \"num_predict\": 100}}" \
    | python3 -c "import sys,json; print(json.load(sys.stdin).get('response',''))" 2>/dev/null
}

function autopsy-fix() {
    # 1. Limpiamos variables globales de Java
    unset JAVA_HOME
    unset CLASSPATH
    unset JAVACMD
    
    # 2. Forzamos variables para el entorno de Java
    export JAVA_HOME="/usr/lib/jvm/java-21-openjdk"
    export PATH="$JAVA_HOME/bin:$PATH"
    
    # 3. Lanzamos de forma inmune al cierre de la terminal y redirigimos logs al vacío
    nohup /usr/bin/autopsy --jdkhome /usr/lib/jvm/java-21-openjdk > /dev/null 2>&1 &
    
    # 4. Desvinculamos el proceso inmediatamente de esta shell
    disown
}

# Show which model is loaded
alias ollama-ps='curl -s http://localhost:11434/api/ps | python3 -m json.tool 2>/dev/null'

