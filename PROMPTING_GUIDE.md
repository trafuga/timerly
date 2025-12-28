# Guía de Prompting para Timerly

Esta guía te ayudará a comunicarte efectivamente con Claude para trabajar en el proyecto Timerly.

## ¿Por qué esta guía?

Un buen prompting permite:
- ✅ Resultados más precisos y rápidos
- ✅ Menos iteraciones innecesarias
- ✅ Código mejor documentado
- ✅ Menos errores y regresiones

## Principios de Comunicación con Claude

### 1. Comunicación Clara y Específica

**Sé específico sobre archivos y funciones**:
- ❌ "Mejora el logging"
- ✅ "Agrega logging del cierre del daemon en timerly.sh:920"

**Indica el tipo de cambio**:
- ❌ "Cambia esto"
- ✅ "Fix: el timer no registra el cierre correcto" (bug)
- ✅ "Feature: agregar comando --export-stats" (nueva funcionalidad)
- ✅ "Refactor: separar función show_stats en módulos" (mejora)

**Define el criterio de éxito**:
- ❌ "Haz que funcione mejor"
- ✅ "Debe registrar el PID y timestamp en ~/timerly.log al cerrar"

### 2. Exploración Antes de Implementación

**Permite que Claude explore primero**:
- ✅ "Analiza cómo funciona el sistema de estadísticas antes de modificarlo"
- ✅ "Explora dónde se registran las alertas y sugiere mejoras"

**Pregunta antes de asumir**:
- ✅ "¿Qué archivos necesito modificar para agregar esta funcionalidad?"
- ✅ "¿Hay algún patrón existente que deba seguir?"

### 3. Contexto Progresivo

**Divide tareas grandes**:
- ❌ "Implementa sistema completo de exportación a CSV, JSON y HTML"
- ✅ "Paso 1: Agrega función para exportar stats a CSV"
- ✅ "Paso 2: Prueba la exportación con datos reales"
- ✅ "Paso 3: Agrega soporte para JSON"

**Confirma comprensión**:
- ✅ "Antes de implementar, explica tu plan"
- ✅ "¿Entiendes lo que necesito? Resume el objetivo"

**Itera, no perfecciones de una vez**:
- ✅ "Implementa versión básica primero"
- ✅ "Ahora mejora el formato de salida"
- ✅ "Finalmente, agrega manejo de errores"

### 4. Testing y Validación

**Especifica casos de prueba**:
- ✅ "Prueba con un timer de 5 segundos"
- ✅ "Verifica que funcione tanto con -u s como -u m"
- ✅ "Prueba el caso donde no hay estadísticas previas"

**Solicita verificación de logs**:
- ✅ "Después de implementar, revisa que se registre en ~/timerly.log"
- ✅ "Verifica que el formato de log siga el estándar del proyecto"

**Considera edge cases**:
- ✅ "¿Qué pasa si cancelo el timer a mitad?"
- ✅ "¿Funciona si las estadísticas están en 0?"

### 5. Documentación Consistente

**Pide documentación junto con el código**:
- ✅ "Agrega esta funcionalidad y actualiza el README"
- ✅ "Incluye esta opción en show_help()"

**Solicita ejemplos de uso**:
- ✅ "Documenta con 2-3 ejemplos de uso en el README"

## Workflows Recomendados

### Workflow Estándar
```
1. Explorar → Claude analiza código existente
2. Planear → Claude propone approach
3. Confirmar → Tú apruebas el plan
4. Implementar → Claude hace cambios
5. Probar → Verificar funcionamiento
6. Documentar → Actualizar README si aplica
```

### Workflow para Bugs
```
1. Describir síntoma → "El timer no se detiene al cancelar"
2. Reproducir → "Ocurre al ejecutar: timerly -k mientras está activo"
3. Diagnóstico → Claude analiza el problema
4. Fix → Claude corrige
5. Verificar → Probar que el bug desapareció
6. Regresión → Verificar que no rompió nada más
```

### Workflow para Features
```
1. Describir necesidad → "Quiero exportar estadísticas a CSV"
2. Explorar → Claude revisa sistema actual
3. Proponer → Claude sugiere implementación
4. Implementar → Claude hace cambios
5. Testing → Probar casos de uso
6. Documentar → Actualizar README y help
```

## Tips Específicos para Timerly

### Testing Rápido
```bash
# Usa timers de segundos para pruebas rápidas
timerly -t 5 -u s -r 2 -m "Test" -a "echo test"
```

### Verificar Logs
```bash
# Monitorear logs en tiempo real
tail -f ~/timerly.log

# Ver últimas entradas
tail -50 ~/timerly.log | grep -A 5 "DAEMON\|APLICACIÓN"
```

### Probar Diferentes Notificaciones
```bash
# Verificar que funcione con zenity
which zenity && timerly -t 3 -u s -r 1 -m "Test Zenity" -a "echo test"

# Verificar que funcione con notify-send
which notify-send && timerly -t 3 -u s -r 1 -m "Test Notify" -a "echo test"
```

### Estado del Sistema
```bash
# Ver estado actual
timerly -s

# Ver estadísticas
timerly --stats

# Detener timer activo
timerly -k
```

## Ejemplos de Buenos vs Malos Prompts

### Ejemplo 1: Agregar Funcionalidad

❌ **Malo**: "Agrega algo para ver estadísticas"

✅ **Bueno**: "Implementa comando `--stats` que muestre en formato tabla ASCII:
- Total de timers creados
- Total de aplicaciones ejecutadas
- Tiempo total acumulado
- Promedios
Debe seguir el formato visual del proyecto (marcos con ╔══╗)"

### Ejemplo 2: Fix de Bug

❌ **Malo**: "El log no funciona"

✅ **Bueno**: "Bug: app_wrapper.sh no registra la hora de cierre de la aplicación en ~/timerly.log. Cuando cierro firefox manualmente, no aparece entrada de 'APLICACIÓN TERMINADA'. Debe registrar: nombre, hora cierre, duración, código de salida."

### Ejemplo 3: Mejora

❌ **Malo**: "Mejora el código"

✅ **Bueno**: "Refactor: La función show_stats() tiene 80 líneas y hace demasiado. Sepárala en:
1. calculate_stats_summary() - cálculos
2. format_stats_output() - formateo
3. show_stats() - coordinación
Mantén el mismo output visual."

## Recordatorios Finales

- 📖 **Lee el README**: Antes de pedir algo, revisa si ya existe
- 🧪 **Prueba con segundos**: Usa `-t 5 -u s` para testing rápido
- 📊 **Verifica logs**: `tail ~/timerly.log` es tu mejor amigo
- 🔍 **Explora primero**: Deja que Claude entienda antes de cambiar
- 📝 **Documenta siempre**: Si cambias UX, actualiza README
- 🎯 **Sé específico**: Cuanto más claro, mejor resultado
