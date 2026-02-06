#!/bin/bash

# --- FUNCIÓN DE LIMPIEZA ---
# Usamos 'pkill -f' porque el proceso se llama 'agent', no 'playit'.
# 'killall playit' fallaría.
limpiar_todo() {
    echo "Ejecutando limpieza profunda..."
    pkill -9 -f playit 2>/dev/null || true
    pkill -9 -f java 2>/dev/null || true
    tmux kill-server 2>/dev/null || true
    stty sane
}

# 1. LIMPIEZA PREVENTIVA AL INICIO
limpiar_todo
reset
export TERM=xterm-256color

echo "--- Iniciando Servidor (Modo Inteligente) ---"

# 2. LANZAR PROCESOS
# Lanzamos playit buscando la ruta exacta para que pkill lo encuentre luego
/usr/local/bin/playit > /workspaces/Runing-BETA/playit_status.log 2>&1 &

cd /workspaces/Runing-BETA/servidor_minecraft
tmux new-session -d -s server "/home/codespace/java/current/bin/java -Xmx4G -Xms1G -jar fabric-server-launch.jar nogui"

echo "Servidor activo. Conectando..."
sleep 4

# 3. ENTRAR A LA CONSOLA
tmux attach -t server

# --- 4. EL CEREBRO DEL SCRIPT (DECISIÓN CRÍTICA) ---
# Aquí es donde arreglamos el problema de que playit siga andando o se cierre mal.

if tmux has-session -t server 2>/dev/null; then
    # ESCENARIO A: Te sacó el bug, pero el server sigue vivo.
    echo "-----------------------------------------------------------"
    echo "¡OJO! Te desconectaste (o te sacó el bug), pero el server SIGUE CORRIENDO."
    echo "NO hemos matado a playit para que puedas volver a entrar."
    echo "Usa: tmux attach -t server"
    echo "-----------------------------------------------------------"
    stty sane
else
    # ESCENARIO B: Escribiste 'stop' y el server se cerró de verdad.
    echo "-----------------------------------------------------------"
    echo "Detectamos que el servidor se cerró correctamente."
    echo "Matando playit y limpiando RAM..."
    limpiar_todo
    reset
    echo "¡Todo limpio! CPU al 0%."
    echo "-----------------------------------------------------------"
fi