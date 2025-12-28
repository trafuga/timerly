#!/bin/bash
# timerly.sh - Enhanced version with seconds support

SCRIPT_DIR="$(cd "$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")" && pwd)"
TIMER_PID_FILE="/tmp/timerly_daemon.pid"
TIMER_CONFIG_FILE="/tmp/timerly_config"
APPS_LIST_FILE="/tmp/timerly_apps"
STATS_FILE="/tmp/timerly_stats"
LOG_FILE="$HOME/timerly.log"
LOG_DATE_FILE="/tmp/timerly_log_date"
DEFAULT_CONFIG_FILE="$SCRIPT_DIR/timer_defaults.conf"
TEMPLATES_DIR="$SCRIPT_DIR/templates"

# Función para limpiar log al cambiar de día
cleanup_log_if_new_day() {
    local current_date=$(date '+%Y-%m-%d')
    local last_date=""

    if [ -f "$LOG_DATE_FILE" ]; then
        last_date=$(cat "$LOG_DATE_FILE")
    fi

    # Si es un nuevo día, limpiar el log
    if [ "$current_date" != "$last_date" ]; then
        if [ -f "$LOG_FILE" ]; then
            > "$LOG_FILE"  # Limpiar el log sin borrarlo
        fi
        echo "$current_date" > "$LOG_DATE_FILE"
    fi
}

# Función para cargar configuración por defecto
load_default_config() {
    if [ -f "$DEFAULT_CONFIG_FILE" ]; then
        source "$DEFAULT_CONFIG_FILE"
        log_message "⚙️ Config default"
    fi
}

# Función para cargar configuración personalizada
load_custom_config() {
    local config_input="$1"
    local config_file=""
    
    # Determinar la ubicación del archivo de configuración
    if [[ "$config_input" == /* ]] || [[ "$config_input" == ./* ]] || [[ "$config_input" == ../* ]]; then
        # Es una ruta absoluta o relativa - usar como está
        config_file="$config_input"
    else
        # Es un nombre simple - buscar en templates
        if [[ "$config_input" == *.conf ]]; then
            # Ya tiene extensión .conf
            config_file="$TEMPLATES_DIR/$config_input"
        else
            # Agregar extensión .conf automáticamente
            config_file="$TEMPLATES_DIR/$config_input.conf"
        fi
    fi
    
    # Cargar el archivo de configuración
    if [ -f "$config_file" ]; then
        source "$config_file"
        log_message "⚙️ Config: $(basename "$config_file")"
        echo "✅ Configuración personalizada cargada: $config_file"
    else
        echo "❌ Error: No se puede encontrar el archivo de configuración: $config_file"
        if [[ "$config_input" != /* ]] && [[ "$config_input" != ./* ]] && [[ "$config_input" != ../* ]]; then
            echo "💡 Sugerencia: Para usar archivos fuera de templates/, especifica la ruta completa"
            echo "   Ejemplo: --config /ruta/completa/mi_config.conf"
            echo "   Ejemplo: --config ./mi_config.conf"
        fi
        exit 1
    fi
}

# Función para crear archivo de configuración de ejemplo
create_default_config() {
    cat > "$DEFAULT_CONFIG_FILE" << 'EOF'
# Configuración por defecto para timerly.sh
# Estos valores se usarán si no se especifican en la línea de comandos

# Tiempo por defecto (número)
DEFAULT_TIMER_VALUE="25"

# Unidad de tiempo por defecto: 's' (segundos) o 'm' (minutos)  
DEFAULT_TIME_UNIT="m"

# Número de repeticiones por defecto
DEFAULT_REPEAT_COUNT="4"

# Mensaje por defecto
DEFAULT_ALERT_MESSAGE="¡Hora de tomar un descanso!"

# Mensaje final por defecto (opcional)
DEFAULT_FINAL_MESSAGE="¡Sesión de trabajo completada!"

# Aplicaciones por defecto (separadas por comas)
DEFAULT_APPS_STRING="firefox,gedit"

# Duración de las notificaciones en segundos
DEFAULT_NOTIFICATION_TIMEOUT="20"
EOF
    echo "✅ Archivo de configuración creado: $DEFAULT_CONFIG_FILE"
    echo "   Puedes editarlo para personalizar los valores por defecto"
}

# Función para mostrar ayuda
show_help() {
    cat << EOF
Uso: $0 -t TIEMPO -u UNIDAD -r REPETICIONES -m "MENSAJE" -a "APLICACION1,APLICACION2,..."

Parámetros:
  -t, --timer     Tiempo entre alertas (número)
  -u, --unit      Unidad de tiempo: 's' (segundos) o 'm' (minutos)
  -r, --repeat    Número de veces a repetir la alerta
  -m, --message   Mensaje a mostrar en la alerta
  -f, --final     Mensaje final para la última alerta (opcional)
  -a, --apps      Aplicaciones a abrir (separadas por comas)
  --config        Archivo de configuración (nombre o ruta completa)
  -s, --status    Mostrar estado del timer
  -k, --kill      Detener timer activo
  -c, --create-config  Crear archivo de configuración por defecto
  --stats         Mostrar estadísticas de uso
  --reset-stats   Resetear todas las estadísticas (con confirmación)
  -h, --help      Mostrar esta ayuda

Ejemplos:
  # Timer en minutos (modo clásico)
  $0 -t 5 -u m -r 3 -m "¡Hora de descansar!" -a "firefox,code,spotify"
  
  # Timer en segundos (para pruebas rápidas)
  $0 -t 30 -u s -r 5 -m "Recordatorio rápido" -a "gedit"
  
  # Timer de 90 segundos (1.5 minutos)
  $0 -t 90 -u s -r 2 -m "Verificar postura" -a "firefox"
  
  # Timer con mensaje final diferente
  $0 -t 10 -u s -r 3 -m "Descansa un poco" -f "¡Sesión completada!" -a "gedit"
  
  # Timer con configuración desde templates/ (sintaxis nueva - más simple)
  timerly cepillado
  timerly ejercicios -a "spotify,firefox"
  timerly pomodoro
  
  # Timer con configuración desde templates/ (sintaxis tradicional)
  $0 --config cepillado
  $0 --config config_ejercicios.conf
  
  # Timer con configuración desde ruta personalizada
  $0 --config /home/user/mi_config.conf
  $0 --config ./mi_config.conf
  
  # Agregar más aplicaciones al timer existente
  $0 -a "discord,telegram"
  
  # Ver estado
  $0 -s
  
  # Detener timer
  $0 -k

Sintaxis simplificada:
  Si el primer parámetro no empieza con '-', se trata automáticamente como configuración.
  Ejemplo: 'timerly miconfig' es equivalente a 'timerly --config miconfig'

Nota: Si omites -u, por defecto será minutos (m) para compatibilidad.
      Si ya hay un timer ejecutándose, solo se abrirán las nuevas aplicaciones
      sin reiniciar el timer.

Configuración por defecto:
  Los parámetros pueden tener valores por defecto en timer_defaults.conf
  Si el archivo no existe, créalo con: timerly --create-config
  Los parámetros de línea de comandos sobreescriben la configuración por defecto.

Configuraciones personalizadas:
  --config NOMBRE     Busca NOMBRE.conf en templates/
  --config /ruta/     Usa la ruta completa especificada
  --config ./archivo  Usa ruta relativa al directorio actual

EOF
}

# Función para log (compacta)
log_message() {
    echo "$(date '+%H:%M:%S') $1" >> "$LOG_FILE"
}

# Función para inicializar estadísticas
init_stats() {
    cat > "$STATS_FILE" << 'EOF'
STATS_START_TIME=$(date +%s)
STATS_TOTAL_TIMERS=0
STATS_TOTAL_APPS=0
STATS_TOTAL_ALERTS=0
STATS_TOTAL_DURATION=0
STATS_CREATED_DATE=$(date '+%Y-%m-%d %H:%M:%S')
EOF
}

# Función para cargar estadísticas
load_stats() {
    if [ ! -f "$STATS_FILE" ]; then
        init_stats
    fi
    source "$STATS_FILE"
}

# Función para guardar estadísticas
save_stats() {
    cat > "$STATS_FILE" << EOF
STATS_START_TIME=$STATS_START_TIME
STATS_TOTAL_TIMERS=$STATS_TOTAL_TIMERS
STATS_TOTAL_APPS=$STATS_TOTAL_APPS
STATS_TOTAL_ALERTS=$STATS_TOTAL_ALERTS
STATS_TOTAL_DURATION=$STATS_TOTAL_DURATION
STATS_CREATED_DATE="$STATS_CREATED_DATE"
EOF
}

# Función para actualizar estadísticas
update_stats() {
    load_stats
    STATS_TOTAL_TIMERS=$((STATS_TOTAL_TIMERS + 1))
    STATS_TOTAL_APPS=$((STATS_TOTAL_APPS + ${#APPS[@]}))
    STATS_TOTAL_ALERTS=$((STATS_TOTAL_ALERTS + REPEAT_COUNT))
    STATS_TOTAL_DURATION=$((STATS_TOTAL_DURATION + TIMER_SECONDS * REPEAT_COUNT))
    save_stats
}

# Función para convertir tiempo a segundos
convert_to_seconds() {
    local time_value="$1"
    local time_unit="$2"
    
    case "$time_unit" in
        "s"|"sec"|"seconds")
            echo "$time_value"
            ;;
        "m"|"min"|"minutes"|"")
            echo $((time_value * 60))
            ;;
        *)
            echo "0"
            ;;
    esac
}

# Función para formatear tiempo para mostrar
format_time_display() {
    local seconds="$1"
    
    if [ "$seconds" -lt 60 ]; then
        echo "${seconds}s"
    elif [ "$seconds" -eq 60 ]; then
        echo "1m"
    elif [ $((seconds % 60)) -eq 0 ]; then
        echo "$((seconds / 60))m"
    else
        echo "$((seconds / 60))m ${seconds % 60}s"
    fi
}

# Función para calcular tiempo restante
calculate_next_alert_time() {
    local seconds="$1"
    echo "$(date -d "+$seconds seconds" '+%H:%M:%S')"
}

# Función para mostrar alerta
show_alert() {
    local message="$1"
    local alert_num="$2"
    local total_alerts="$3"
    local interval_seconds="$4"
    local title="⏰ Recordatorio de Aplicación"
    
    local interval_display=$(format_time_display "$interval_seconds")
    local next_alert=""
    
    if [ "$alert_num" -lt "$total_alerts" ]; then
        next_alert="🕐 Próxima alerta: $(calculate_next_alert_time "$interval_seconds")"
    else
        next_alert="🏁 Esta es la última alerta"
    fi
    
    local full_message="$message

🔢 Alerta: $alert_num de $total_alerts
⏱️  Intervalo: $interval_display
🕐 Hora actual: $(date '+%H:%M:%S')
$next_alert
📱 Aplicaciones activas: $(cat "$APPS_LIST_FILE" 2>/dev/null | wc -l || echo "0")

¿Continuar con el timer?"
    
    if command -v zenity &> /dev/null; then
        choice=$(zenity --question \
            --title="$title" \
            --text="$full_message" \
            --ok-label="Continuar" \
            --cancel-label="Detener Timer" \
            --width=450 \
            --height=300 2>/dev/null && echo "continue" || echo "stop")
        
        if [ "$choice" = "stop" ]; then
            log_message "⏹️ Usuario detuvo en alerta $alert_num"
            cleanup_timer
            exit 0
        fi
    elif command -v notify-send &> /dev/null; then
        notify-send "$title" "$message (Alerta $alert_num/$total_alerts - Intervalo: $interval_display)" --urgency=critical --expire-time=10000
    else
        echo ""
        echo "========================================="
        echo "🔔 $message"
        echo "   Alerta $alert_num de $total_alerts"
        echo "   Intervalo: $interval_display"
        echo "   Hora: $(date '+%H:%M:%S')"
        if [ "$alert_num" -lt "$total_alerts" ]; then
            echo "   Próxima: $(calculate_next_alert_time "$interval_seconds")"
        fi
        echo "========================================="
        echo -e "\a"
    fi
    
    log_message "🔔 Alerta $alert_num/$total_alerts | $interval_display"
}

# Función para abrir aplicaciones
open_applications() {
    local apps_string="$1"
    local apps_opened=0

    # Crear archivo de aplicaciones si no existe
    touch "$APPS_LIST_FILE"

    # Separar aplicaciones por comas
    IFS=',' read -ra APPS <<< "$apps_string"

    for app in "${APPS[@]}"; do
        # Limpiar espacios
        app=$(echo "$app" | xargs)

        # Agregar a la lista si no está ya registrada (solo para tracking)
        if ! grep -q "^$app$" "$APPS_LIST_FILE" 2>/dev/null; then
            echo "$app" >> "$APPS_LIST_FILE"
        fi

        # Siempre ejecutar la aplicación, independientemente de si ya está en la lista
        apps_opened=$((apps_opened + 1))

        log_message "🚀 $app"
        echo "🚀 Abriendo: $app"

        # Ejecutar la aplicación con wrapper para monitorear cierre
        if command -v "$app" &> /dev/null; then
            nohup "$SCRIPT_DIR/app_wrapper.sh" "$app" "$LOG_FILE" "$app" > /dev/null 2>&1 &
        else
            nohup "$SCRIPT_DIR/app_wrapper.sh" "$app" "$LOG_FILE" bash -c "$app" > /dev/null 2>&1 &
        fi

        sleep 1  # Pequeña pausa entre aplicaciones
    done

    log_message "📱 Apps: $apps_opened"
    echo "✅ Se ejecutaron $apps_opened aplicaciones"
}

# Función para limpiar archivos del timer
cleanup_timer() {
    rm -f "$TIMER_PID_FILE" "$TIMER_CONFIG_FILE" "$APPS_LIST_FILE"
    log_message "🧹 Limpio"
}

# Función del daemon del timer con progreso mejorado
timer_daemon() {
    local timer_seconds="$1"
    local repeat_count="$2"
    local alert_message="$3"
    local time_display="$4"
    
    # Configurar traps para limpieza
    trap cleanup_timer EXIT INT TERM
    
    # Guardar PID del daemon
    echo $$ > "$TIMER_PID_FILE"
    
    log_message "▶️ Timer PID:$$ | $time_display x$repeat_count"

    for ((i=1; i<=repeat_count; i++)); do
        
        # Mostrar progreso detallado para tiempos largos
        if [ "$timer_seconds" -ge 120 ]; then
            # Para tiempos >= 2 minutos, mostrar progreso cada 30 segundos
            local progress_interval=30
            local remaining_seconds=$timer_seconds
            
            while [ $remaining_seconds -gt 0 ]; do
                if [ $remaining_seconds -le $progress_interval ]; then
                    sleep $remaining_seconds
                    break
                else
                    sleep $progress_interval
                    remaining_seconds=$((remaining_seconds - progress_interval))
                    local remaining_display=$(format_time_display $remaining_seconds)
                    log_message "⏳ $i/$repeat_count: -$remaining_display"
                fi
            done
        elif [ "$timer_seconds" -ge 60 ]; then
            # Para tiempos entre 1-2 minutos, mostrar a mitad
            local half_time=$((timer_seconds / 2))
            sleep $half_time
            local remaining_display=$(format_time_display $half_time)
            log_message "⏳ $i/$repeat_count: -$remaining_display"
            sleep $half_time
        else
            # Para tiempos < 1 minuto, esperar completo
            sleep $timer_seconds
        fi
        
        # Verificar si el daemon sigue siendo válido
        if [ ! -f "$TIMER_PID_FILE" ]; then
            log_message "⏹️ Detenido externamente"
            exit 0
        fi

        show_alert "$alert_message" "$i" "$repeat_count" "$timer_seconds"
    done

    log_message "✅ Timer completado"
    cleanup_timer
    
    if command -v zenity &> /dev/null; then
        local total_time_display=$(format_time_display $((timer_seconds * repeat_count)))
        zenity --info \
            --title="🎉 Timer Completado" \
            --text="Todas las alertas han sido mostradas.

Total de alertas: $repeat_count
Intervalo: $time_display
Duración total: $total_time_display
Aplicaciones que se abrieron: $(cat "$APPS_LIST_FILE" 2>/dev/null | tr '\n' ', ' | sed 's/,$//')" \
            --width=400 \
            --timeout=10
    fi
}

# Función para verificar si el timer está activo
is_timer_active() {
    if [ -f "$TIMER_PID_FILE" ]; then
        PID=$(cat "$TIMER_PID_FILE")
        if ps -p "$PID" > /dev/null 2>&1; then
            return 0  # Timer activo
        else
            # PID file obsoleto
            rm -f "$TIMER_PID_FILE"
            return 1  # Timer no activo
        fi
    else
        return 1  # Timer no activo
    fi
}

# Función para mostrar estado mejorada
show_status() {
    if is_timer_active; then
        PID=$(cat "$TIMER_PID_FILE")
        
        # Leer configuración si existe
        if [ -f "$TIMER_CONFIG_FILE" ]; then
            source "$TIMER_CONFIG_FILE"
            local interval_display=$(format_time_display "$TIMER_SECONDS")
            echo "🟢 Timer ACTIVO (PID: $PID)"
            echo "   ⏱️  Intervalo: $interval_display"
            echo "   🔁 Repeticiones: $REPEAT_COUNT"
            echo "   💬 Mensaje: '$ALERT_MESSAGE'"
            echo "   📅 Iniciado: $(ps -o lstart= -p $PID 2>/dev/null || echo 'Información no disponible')"
        else
            echo "🟢 Timer ACTIVO (PID: $PID) - Configuración no disponible"
        fi
        
        if [ -f "$APPS_LIST_FILE" ]; then
            echo "   📱 Aplicaciones registradas:"
            while IFS= read -r app; do
                echo "      • $app"
            done < "$APPS_LIST_FILE"
        fi
    else
        echo "🔴 Timer INACTIVO"
    fi
    
    echo ""
    echo "📊 Últimas entradas del log:"
    if [ -f "$LOG_FILE" ]; then
        tail -5 "$LOG_FILE"
    else
        echo "   No hay entradas de log"
    fi
}

# Función para detener timer
kill_timer() {
    if is_timer_active; then
        PID=$(cat "$TIMER_PID_FILE")
        kill "$PID" 2>/dev/null
        cleanup_timer
        log_message "⏹️ Manual"
        echo "🛑 Timer detenido"
    else
        echo "ℹ️  No hay timer activo para detener"
    fi
}

# Función para mostrar estadísticas
show_stats() {
    load_stats

    # Calcular tiempo de uptime
    local current_time=$(date +%s)
    local uptime=$((current_time - STATS_START_TIME))
    local uptime_days=$((uptime / 86400))
    local uptime_hours=$(((uptime % 86400) / 3600))
    local uptime_minutes=$(((uptime % 3600) / 60))

    # Mostrar encabezado
    echo ""
    echo "╔════════════════════════════════════════════════════════════════════════════════════╗"
    echo "║                      📊 HISTORIAL DE APLICACIONES EJECUTADAS                      ║"
    echo "╠════════════════════════════════════════════════════════════════════════════════════╣"
    echo "║                                                                                    ║"
    echo "║  📅 Fecha de creación: $STATS_CREATED_DATE                                      "
    echo "║  ⏱️  Tiempo activo: ${uptime_days}d ${uptime_hours}h ${uptime_minutes}m                                          "
    echo "║                                                                                    ║"
    echo "╠════════════════════════════════════════════════════════════════════════════════════╣"

    # Procesar registros del log
    if [ -f "$LOG_FILE" ]; then
        # Extraer líneas con registros de aplicaciones (formato del app_wrapper.sh)
        # Formato: ✅ PID:XXXX | AppName | HH:MM:SS → HH:MM:SS | X:XXm

        local total_seconds=0
        local app_count=0

        # Leer el archivo del log y procesar registros de aplicaciones
        while IFS= read -r line; do
            # Buscar líneas que contengan el formato de app_wrapper.sh
            if [[ "$line" =~ ^\✅|^\⚠️ ]] && [[ "$line" =~ \|.*\|.*→.*\| ]]; then
                app_count=$((app_count + 1))

                # Extraer componentes del registro
                # Formato: ✅ PID:XXXX | AppName | MM-DD HH:MM:SS → HH:MM:SS | X:XXm
                local status=$(echo "$line" | cut -d' ' -f1)
                local app_name=$(echo "$line" | cut -d'|' -f2 | xargs)
                local times=$(echo "$line" | cut -d'|' -f3 | xargs)
                local duration=$(echo "$line" | cut -d'|' -f4 | xargs)

                # Convertir duración MM:SS o decimal a segundos
                if [[ "$duration" =~ ^[0-9]+:[0-9]+m$ ]]; then
                    # Formato nuevo: MM:SS
                    local minutes=$(echo "$duration" | cut -d':' -f1)
                    local seconds=$(echo "$duration" | cut -d':' -f2 | cut -d'm' -f1)
                    local dur_secs=$((minutes * 60 + seconds))
                else
                    # Formato antiguo: decimal (X.XXm)
                    local dur_decimal=$(echo "$duration" | sed 's/m$//')
                    local dur_secs=$(echo "$dur_decimal * 60" | bc | cut -d'.' -f1)
                fi
                total_seconds=$((total_seconds + dur_secs))

                # Mostrar registro en tabla (ajustado para nueva longitud con fecha)
                printf "║  %-93s║\n" "$status  $app_name | $times | $duration"
            fi
        done < "$LOG_FILE"

        # Mostrar separador y total
        echo "╠════════════════════════════════════════════════════════════════════════════════════╣"

        # Convertir total de segundos a MM:SS
        local total_minutes=$((total_seconds / 60))
        local total_secs=$((total_seconds % 60))
        local total_formatted=$(printf "%d:%02d" $total_minutes $total_secs)

        echo "║                                                                                    ║"
        echo "║  📱 Aplicaciones ejecutadas: $app_count                                           "
        echo "║  ⏱️  Tiempo total ejecutado: ${total_formatted}m                                      "
        echo "║                                                                                    ║"
        echo "╚════════════════════════════════════════════════════════════════════════════════════╝"
    else
        echo "║                                                                                    ║"
        echo "║  ℹ️  No hay registros de aplicaciones ejecutadas                                  ║"
        echo "║                                                                                    ║"
        echo "╚════════════════════════════════════════════════════════════════════════════════════╝"
    fi
    echo ""
}

# Función para resetear estadísticas
reset_stats() {
    # Verificar si el archivo de estadísticas existe
    if [ ! -f "$STATS_FILE" ]; then
        echo "ℹ️  No hay estadísticas para resetear"
        return
    fi

    # Mostrar estadísticas actuales antes de resetear
    echo ""
    echo "⚠️  Estadísticas actuales ANTES de resetear:"
    echo "═════════════════════════════════════════════════════════"
    load_stats

    local current_time=$(date +%s)
    local uptime=$((current_time - STATS_START_TIME))
    local uptime_days=$((uptime / 86400))
    local uptime_hours=$(((uptime % 86400) / 3600))
    local uptime_minutes=$(((uptime % 3600) / 60))

    local total_hours=$((STATS_TOTAL_DURATION / 3600))
    local total_minutes=$(((STATS_TOTAL_DURATION % 3600) / 60))
    local total_secs=$((STATS_TOTAL_DURATION % 60))

    local duration_formatted=""
    if [ $total_hours -gt 0 ]; then
        duration_formatted="${total_hours}h ${total_minutes}m ${total_secs}s"
    elif [ $total_minutes -gt 0 ]; then
        duration_formatted="${total_minutes}m ${total_secs}s"
    else
        duration_formatted="${total_secs}s"
    fi

    echo "   Fecha: $STATS_CREATED_DATE"
    echo "   Tiempo activo: ${uptime_days}d ${uptime_hours}h ${uptime_minutes}m"
    echo "   Timers creados: $STATS_TOTAL_TIMERS"
    echo "   Apps ejecutadas: $STATS_TOTAL_APPS"
    echo "   Alertas mostradas: $STATS_TOTAL_ALERTS"
    echo "   Tiempo total: $duration_formatted"
    echo "═════════════════════════════════════════════════════════"
    echo ""

    # Pedir confirmación
    read -p "¿Estás seguro de que deseas RESETEAR todas las estadísticas? (escribe 'sí' para confirmar): " confirmation

    if [ "$confirmation" != "sí" ] && [ "$confirmation" != "si" ]; then
        echo "❌ Operación cancelada. Las estadísticas se mantienen intactas."
        return
    fi

    # Guardar fecha de último reset en el log
    log_message "🔄 RESET | T:$STATS_TOTAL_TIMERS A:$STATS_TOTAL_APPS Al:$STATS_TOTAL_ALERTS D:$duration_formatted"

    # Resetear estadísticas
    init_stats

    echo ""
    echo "╔════════════════════════════════════════════════════════╗"
    echo "║         ✅ ESTADÍSTICAS RESETEADAS CORRECTAMENTE       ║"
    echo "╠════════════════════════════════════════════════════════╣"
    echo "║                                                        ║"
    echo "║  Todas las estadísticas han sido reiniciadas           ║"
    echo "║  Nueva fecha de inicio: $(date '+%Y-%m-%d %H:%M:%S')    "
    echo "║                                                        ║"
    echo "║  Los datos anteriores se conservan en el log           ║"
    echo "║  Puedes consultarlos en ~/timerly.log                 ║"
    echo "║                                                        ║"
    echo "╚════════════════════════════════════════════════════════╝"
    echo ""

    log_message "✅ RESET DE ESTADÍSTICAS COMPLETADO"
}

# Detección automática de configuración: si el primer parámetro no empieza con '-', tratarlo como --config
if [[ $# -gt 0 && "$1" != -* ]]; then
    # Solo aplicar si no es una de las opciones especiales sin parámetros
    if [[ "$1" != "-s" && "$1" != "--status" && "$1" != "-k" && "$1" != "--kill" && "$1" != "-c" && "$1" != "--create-config" && "$1" != "--stats" && "$1" != "--reset-stats" && "$1" != "-h" && "$1" != "--help" ]]; then
        # Reorganizar argumentos: insertar --config antes del primer argumento
        set -- "--config" "$@"
    fi
fi

# Parseo inicial para detectar --config
CUSTOM_CONFIG_TEMP=""
ARGS=("$@")
for ((i=0; i<${#ARGS[@]}; i++)); do
    if [[ "${ARGS[i]}" == "--config" ]]; then
        CUSTOM_CONFIG_TEMP="${ARGS[i+1]}"
        break
    fi
done

# Cargar configuración (personalizada tiene prioridad sobre por defecto)
if [ -n "$CUSTOM_CONFIG_TEMP" ]; then
    load_custom_config "$CUSTOM_CONFIG_TEMP"
else
    load_default_config
fi

# Limpiar log si es un nuevo día
cleanup_log_if_new_day

# Parsear argumentos (los valores por defecto/personalizados se sobreescriben si se especifican)
TIMER_VALUE="${DEFAULT_TIMER_VALUE:-}"
TIME_UNIT="${DEFAULT_TIME_UNIT:-m}"  # Por defecto minutos para compatibilidad
REPEAT_COUNT="${DEFAULT_REPEAT_COUNT:-}"
ALERT_MESSAGE="${DEFAULT_ALERT_MESSAGE:-}"
FINAL_MESSAGE="${DEFAULT_FINAL_MESSAGE:-}"
APPS_STRING="${DEFAULT_APPS_STRING:-}"
NOTIFICATION_TIMEOUT="${DEFAULT_NOTIFICATION_TIMEOUT:-20}"
CUSTOM_CONFIG=""
SHOW_STATUS=false
KILL_TIMER=false
CREATE_CONFIG=false
SHOW_STATS=false
RESET_STATS=false

while [[ $# -gt 0 ]]; do
    case $1 in
        -t|--timer)
            TIMER_VALUE="$2"
            shift 2
            ;;
        -u|--unit)
            TIME_UNIT="$2"
            shift 2
            ;;
        -r|--repeat)
            REPEAT_COUNT="$2"
            shift 2
            ;;
        -m|--message)
            ALERT_MESSAGE="$2"
            shift 2
            ;;
        -f|--final)
            FINAL_MESSAGE="$2"
            shift 2
            ;;
        -a|--apps)
            APPS_STRING="$2"
            shift 2
            ;;
        --config)
            CUSTOM_CONFIG="$2"
            shift 2
            ;;
        -s|--status)
            SHOW_STATUS=true
            shift
            ;;
        -k|--kill)
            KILL_TIMER=true
            shift
            ;;
        -c|--create-config)
            CREATE_CONFIG=true
            shift
            ;;
        --stats)
            SHOW_STATS=true
            shift
            ;;
        --reset-stats)
            RESET_STATS=true
            shift
            ;;
        -h|--help)
            show_help
            exit 0
            ;;
        *)
            echo "❌ Parámetro desconocido: $1"
            show_help
            exit 1
            ;;
    esac
done

# Manejar opciones especiales
if [ "$SHOW_STATUS" = true ]; then
    show_status
    exit 0
fi

if [ "$KILL_TIMER" = true ]; then
    kill_timer
    exit 0
fi

if [ "$CREATE_CONFIG" = true ]; then
    create_default_config
    exit 0
fi

if [ "$SHOW_STATS" = true ]; then
    show_stats
    exit 0
fi

if [ "$RESET_STATS" = true ]; then
    reset_stats
    exit 0
fi

# Verificar si solo se quieren abrir aplicaciones
if [ -n "$APPS_STRING" ] && [ -z "$TIMER_VALUE" ] && [ -z "$REPEAT_COUNT" ] && [ -z "$ALERT_MESSAGE" ]; then
    if is_timer_active; then
        echo "📱 Agregando aplicaciones al timer existente..."
        open_applications "$APPS_STRING"
        echo ""
        show_status
        exit 0
    else
        echo "❌ No hay timer activo. Debes especificar todos los parámetros para crear un nuevo timer."
        exit 1
    fi
fi

# Validar parámetros completos para nuevo timer
if [ -z "$TIMER_VALUE" ] || [ -z "$REPEAT_COUNT" ] || [ -z "$ALERT_MESSAGE" ] || [ -z "$APPS_STRING" ]; then
    echo "❌ Error: Para crear un nuevo timer necesitas todos los parámetros"
    echo ""
    show_help
    exit 1
fi

# Validar número del timer
if ! [[ "$TIMER_VALUE" =~ ^[0-9]+$ ]] || [ "$TIMER_VALUE" -eq 0 ]; then
    echo "❌ Error: El valor del timer debe ser un número entero mayor a 0"
    exit 1
fi

# Validar unidad de tiempo
case "$TIME_UNIT" in
    "s"|"sec"|"seconds"|"m"|"min"|"minutes")
        ;;
    *)
        echo "❌ Error: La unidad debe ser 's' (segundos) o 'm' (minutos)"
        exit 1
        ;;
esac

# Validar número de repeticiones
if ! [[ "$REPEAT_COUNT" =~ ^[0-9]+$ ]] || [ "$REPEAT_COUNT" -eq 0 ]; then
    echo "❌ Error: El número de repeticiones debe ser un número entero mayor a 0"
    exit 1
fi

# Convertir a segundos
TIMER_SECONDS=$(convert_to_seconds "$TIMER_VALUE" "$TIME_UNIT")
TIME_DISPLAY=$(format_time_display "$TIMER_SECONDS")

# Validar tiempo mínimo (evitar spam)
if [ "$TIMER_SECONDS" -lt 1 ]; then
    echo "❌ Error: El tiempo mínimo es 1 segundo"
    exit 1
fi

# Verificar si ya hay un timer activo
if is_timer_active; then
    echo "⚠️  Ya hay un timer activo. Se ejecutarán todas las aplicaciones solicitadas."
    open_applications "$APPS_STRING"
    echo ""
    show_status
    exit 0
fi

# Crear nuevo timer
echo "🆕 Creando nuevo timer..."

# Guardar configuración extendida
cat > "$TIMER_CONFIG_FILE" << EOF
TIMER_VALUE="$TIMER_VALUE"
TIME_UNIT="$TIME_UNIT"
TIMER_SECONDS="$TIMER_SECONDS"
REPEAT_COUNT="$REPEAT_COUNT"
ALERT_MESSAGE="$ALERT_MESSAGE"
FINAL_MESSAGE="$FINAL_MESSAGE"
EOF

# Abrir aplicaciones
open_applications "$APPS_STRING"

# Actualizar estadísticas
update_stats

echo ""
echo "⏱️  Iniciando timer:"
echo "   • Intervalo: $TIME_DISPLAY"
echo "   • Repeticiones: $REPEAT_COUNT"
echo "   • Mensaje: '$ALERT_MESSAGE'"
echo "   • Primera alerta: $(calculate_next_alert_time "$TIMER_SECONDS")"
echo "   • Duración total: $(format_time_display $((TIMER_SECONDS * REPEAT_COUNT)))"
echo ""

# Iniciar daemon en background  
nohup bash -c "
export DISPLAY=\"$DISPLAY\"
export DBUS_SESSION_BUS_ADDRESS=\"$DBUS_SESSION_BUS_ADDRESS\"
export PULSE_RUNTIME_PATH=\"$PULSE_RUNTIME_PATH\"
export XDG_RUNTIME_DIR=\"$XDG_RUNTIME_DIR\"
export PULSE_CONFIG_PATH=\"$PULSE_CONFIG_PATH\"
export USER=\"$USER\"
export HOME=\"$HOME\"
export PULSE_SERVER=\"unix:$XDG_RUNTIME_DIR/pulse/native\"

TIMER_PID_FILE=\"$TIMER_PID_FILE\"
APPS_LIST_FILE=\"$APPS_LIST_FILE\"  
TIMER_CONFIG_FILE=\"$TIMER_CONFIG_FILE\"
LOG_FILE=\"$LOG_FILE\"

timer_seconds=$TIMER_SECONDS
repeat_count=$REPEAT_COUNT  
alert_message=\"$ALERT_MESSAGE\"
final_message=\"$FINAL_MESSAGE\"
notification_timeout=$NOTIFICATION_TIMEOUT
time_display=\"$TIME_DISPLAY\"
sound_file=\"$SCRIPT_DIR/notifications.wav\"

log_message() {
    echo \"\$(date '+%Y-%m-%d %H:%M:%S'): \$1\" >> \"\$LOG_FILE\"
}

play_notification_sound() {
    local sound_file=\"\$1\"
    local attempts=3
    
    for ((i=1; i<=attempts; i++)); do
        # Intentar múltiples métodos de reproducción
        if [ -f \"\$sound_file\" ]; then
            # Método 1: paplay (PulseAudio)
            if command -v paplay &> /dev/null; then
                paplay \"\$sound_file\" 2>/dev/null && break
            fi
            # Método 2: aplay (ALSA)
            if command -v aplay &> /dev/null; then
                aplay \"\$sound_file\" 2>/dev/null && break
            fi
            # Método 3: play (sox)
            if command -v play &> /dev/null; then
                play \"\$sound_file\" 2>/dev/null && break
            fi
            # Método 4: mpv
            if command -v mpv &> /dev/null; then
                mpv --no-video --really-quiet \"\$sound_file\" 2>/dev/null && break
            fi
        fi
        # Método de respaldo: beep del sistema
        echo -e \"\a\" 2>/dev/null
        sleep 0.3
    done
}

play_notification_sound() {
    local sound_file=\"\$1\"
    
    # Verificar si el archivo existe
    if [ ! -f \"\$sound_file\" ]; then
        echo -e \"\a\" 2>/dev/null
        return 1
    fi
    
    # Método 1: paplay (PulseAudio)
    if command -v paplay &> /dev/null; then
        if paplay \"\$sound_file\" 2>/dev/null; then
            return 0
        elif PULSE_SERVER=\"unix:\$XDG_RUNTIME_DIR/pulse/native\" paplay \"\$sound_file\" 2>/dev/null; then
            return 0
        fi
    fi
    
    # Método 2: aplay (ALSA)  
    if command -v aplay &> /dev/null; then
        if aplay \"\$sound_file\" 2>/dev/null; then
            return 0
        fi
    fi
    
    # Método 3: play (sox)
    if command -v play &> /dev/null; then
        if play \"\$sound_file\" 2>/dev/null; then
            return 0
        fi
    fi
    
    # Método 4: mpv
    if command -v mpv &> /dev/null; then
        if mpv --no-video --really-quiet \"\$sound_file\" 2>/dev/null; then
            return 0
        fi
    fi
    
    # Método de respaldo: beep del sistema
    echo -e \"\a\" 2>/dev/null
    return 1
}

cleanup_timer() {
    rm -f \"\$TIMER_PID_FILE\" \"\$TIMER_CONFIG_FILE\" \"\$APPS_LIST_FILE\"
    log_message \"🧹 Limpio\"
}

trap cleanup_timer EXIT INT TERM
echo \$\$ > \"\$TIMER_PID_FILE\"

DAEMON_START_EPOCH=\$(date +%s)

log_message \"▶️ Timer PID:\$\$ | \$time_display x\$repeat_count\"

for ((i=1; i<=repeat_count; i++)); do
    sleep \$timer_seconds

    if [ ! -f \"\$TIMER_PID_FILE\" ]; then
        log_message \"⏹️ Detenido externamente\"
        exit 0
    fi

    # Determinar qué mensaje usar
    current_message=\"\$alert_message\"
    if [ \$i -eq \$repeat_count ] && [ -n \"\$final_message\" ]; then
        current_message=\"\$final_message\"
    fi

    log_message \"🔔 Alerta \$i/\$repeat_count\"
    
    if command -v zenity &> /dev/null; then
        zenity --info --title=\"⏰ Recordatorio\" --text=\"\$current_message\" --timeout=\$notification_timeout 2>/dev/null || true &
        # Reproducir sonido de notificación 3 veces
        for ((j=1; j<=3; j++)); do
            play_notification_sound \"\$sound_file\"
        done
    elif command -v notify-send &> /dev/null; then
        notify-send \"⏰ Recordatorio\" \"\$current_message\" --urgency=critical --expire-time=\$((notification_timeout * 1000)) || true
        # Reproducir sonido de notificación 3 veces
        for ((j=1; j<=3; j++)); do
            play_notification_sound \"\$sound_file\"
        done
    else
        echo \"🔔 \$current_message\"
        play_notification_sound \"\$sound_file\"
    fi
done

# Registrar finalización del daemon
DAEMON_END_EPOCH=\$(date +%s)
DAEMON_DURATION=\$((DAEMON_END_EPOCH - DAEMON_START_EPOCH))

DAEMON_MINUTES=\$(echo \"scale=1; \$DAEMON_DURATION / 60\" | bc)

log_message \"✅ Timer | \$repeat_count alertas | \${DAEMON_MINUTES}m\"

cleanup_timer
" > /dev/null 2>&1 &

echo "✅ Timer iniciado en background"