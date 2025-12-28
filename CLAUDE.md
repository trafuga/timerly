# Instrucciones para Claude - Proyecto Timerly

## Contexto del Proyecto

**Timerly** es un sistema de timer/recordatorios para Linux que:
- Ejecuta alertas periódicas configurables (visual + sonoro)
- Gestiona múltiples aplicaciones simultáneamente
- Implementa daemon en background con monitoreo completo
- Casos de uso: Pomodoro, ejercicios, cepillado dental, gaming

**Arquitectura**:
- `timerly.sh` - Script principal (daemon, configuración, alertas)
- `app_wrapper.sh` - Wrapper que monitorea inicio/cierre de aplicaciones
- `templates/*.conf` - Configuraciones predefinidas
- Sistema de estadísticas acumuladas y logging estructurado

## Archivos Críticos

| Archivo | Propósito | Tamaño |
|---------|-----------|--------|
| `timerly.sh` | Script principal (daemon, config, alertas) | 1050 líneas |
| `app_wrapper.sh` | Monitoreo de aplicaciones | 81 líneas |
| `app_timer_readme.md` | Documentación completa | 23KB |
| `timer_defaults.conf` | Configuración por defecto | - |
| `templates/*.conf` | Templates de configuración | - |
| `~/timerly.log` | Log del sistema (persistente) | - |
| `/tmp/timerly_*` | Archivos temporales (PID, config, apps, stats) | - |

## Convenciones del Código

- **Nombres**: snake_case para funciones y variables
- **Logging**: Bloques con `═══` + emojis (▶️ inicio, ⏹️ fin, ✅ éxito, ⚠️ warning)
- **Timestamps**: Formato `YYYY-MM-DD HH:MM:SS`
- **Estadísticas**: Tablas ASCII art con marcos (`╔══╗`)
- **Configuración**: Variables `DEFAULT_*` en archivos .conf
- **Funciones**: Comentario descriptivo antes de cada función

## Reglas de Documentación

**Actualizar `app_timer_readme.md` cuando**:
- Cambies UX o funcionalidad visible
- Agregues nuevos comandos o parámetros
- Modifiques sistema de configuración
- Agregues nuevos templates

**Actualizar `show_help()`** al agregar/modificar:
- Parámetros de línea de comandos
- Opciones especiales (--stats, --reset-stats, etc.)

**Crear templates de ejemplo**:
- Para nuevas configuraciones, agregar .conf en `/templates/`
- Documentar en README con ejemplo de uso

## Validaciones Requeridas

Siempre validar antes de ejecutar:
- Tiempo > 0
- Unidad en: s, sec, seconds, m, min, minutes
- Repeticiones > 0
- Apps string no vacío (al crear timer)

## Comportamiento del Sistema

- **Single instance**: Solo un timer puede estar activo a la vez
- **Daemon desacoplado**: Usar `nohup` para ejecutar en background
- **Preservar logs**: NUNCA borrar `~/timerly.log`
- **Estadísticas acumuladas**: Mantener histórico en `/tmp/timerly_stats`
- **Agregar apps dinámicamente**: Permite agregar apps sin reiniciar timer activo
