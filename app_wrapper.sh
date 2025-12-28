#!/bin/bash
# app_wrapper.sh - Monitorea inicio y cierre de aplicaciones
# Registra en una línea compacta: PID | APP | inicio | fin | duración (min)

APP_NAME="$1"
LOG_FILE="$2"
APP_PID=$$

# Función para extraer nombre corto de la aplicación
get_short_app_name() {
    local app_name="$1"

    # Si contiene "flatpak", extraer el identificador de la app
    if [[ "$app_name" == *"flatpak"* ]]; then
        # El identificador suele estar en el último parámetro o el penúltimo
        local last=$(echo "$app_name" | awk '{print $NF}')
        # Si parece un ID de flatpak (contiene punto), extraer el último componente
        if [[ "$last" == *"."* ]]; then
            echo "$last" | awk -F'.' '{print $NF}'
        else
            echo "$last"
        fi
    else
        # Para aplicaciones normales, extraer solo el nombre base
        basename "$app_name" 2>/dev/null || echo "$app_name"
    fi
}

log_msg() {
    echo "$1" >> "$LOG_FILE"
}

START_DATE=$(date '+%m-%d')
START_TIME=$(date '+%H:%M:%S')
START_EPOCH=$(date +%s)

# Ejecutar la aplicación
shift 2
"$@"
EXIT_CODE=$?

END_TIME=$(date '+%H:%M:%S')
END_EPOCH=$(date +%s)
DURATION_SECONDS=$((END_EPOCH - START_EPOCH))

# Convertir a formato MM:SS
DURATION_MINUTES=$((DURATION_SECONDS / 60))
DURATION_SECS=$((DURATION_SECONDS % 60))
DURATION_FORMATTED=$(printf "%d:%02d" $DURATION_MINUTES $DURATION_SECS)

# Extraer nombre corto de la app
SHORT_APP_NAME=$(get_short_app_name "$APP_NAME")

# Determinar estado
if [ $EXIT_CODE -eq 0 ]; then
    STATUS="✅"
else
    STATUS="⚠️"
fi

# Registrar en una única línea compacta con fecha
log_msg "$STATUS PID:$APP_PID | $SHORT_APP_NAME | $START_DATE $START_TIME → $END_TIME | ${DURATION_FORMATTED}m"

exit $EXIT_CODE
