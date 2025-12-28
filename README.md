### Creación exitosa de timer (modo segundos)
```
🆕 Creando nuevo timer...
🚀 Abriendo: gedit
🚀 Abriendo: firefox
✅ Se abrieron 2 nuevas aplicaciones

⏱️  Iniciando timer:
   • Intervalo: 45s
   • Repeticiones: 4
   • Mensaje: 'Recordatorio rápido'
   • Primera alerta: 14:23:45
   • Duración total: 3m

✅ Timer iniciado en background
```

### Estado del timer (con segundos)
```
🟢 Timer ACTIVO (PID: 12345)
   ⏱️  Intervalo: 1m 30s
   🔁 Repeticiones: 3
   💬 Mensaje: 'Verificar postura'
   📅 Iniciado: Sáb Sep  6 14:18:15 2025
   📱 Aplicaciones registradas:
      • firefox
      • code

📊 Últimas entradas del log:
2025-09-06 14:18:15: Timer daemon iniciado (PID: 12345) - 1m 30s, 3 repeticiones
2025-09-06 14:18:15: Abriendo aplicación: firefox
2025-09-06 14:18:16: Abriendo aplicación: code
2025-09-06 14:19:# App Timer Manager

Un script de Bash avanzado para Linux Mint Cinnamon que permite abrir múltiples aplicaciones y configurar recordatorios periódicos con alertas visuales. Ideal para gestión de tiempo, descansos programados y control de aplicaciones.

## 🌟 Características

- **Timer único y persistente**: Solo una instancia de timer puede ejecutarse a la vez
- **Soporte para segundos y minutos**: Flexibilidad total en intervalos de tiempo
- **Múltiples aplicaciones**: Abre varias aplicaciones simultáneamente con un solo comando
- **Agregar aplicaciones dinámicamente**: Añade más aplicaciones al timer existente sin reiniciarlo
- **Alertas visuales personalizables**: Mensajes configurables con diferentes métodos de notificación
- **Mensaje final diferenciado**: Mensaje especial para la última alerta
- **Sonido de notificación**: Reproducción automática de audio personalizado
- **Configuración por defecto**: Archivo de configuración para valores predeterminados
- **Gestión de estado**: Monitoreo del timer activo y aplicaciones registradas
- **Logs detallados**: Registro completo de actividades en `~/app_timer.log`
- **Limpieza automática**: Gestión automática de archivos temporales

## 📋 Requisitos

### Sistema Operativo
- Linux Mint Cinnamon (compatible con otros distribuciones Ubuntu/Debian)

### Dependencias básicas (incluidas por defecto)
- `bash` (versión 4.0+)
- `ps`, `kill`, `sleep` (coreutils)

### Dependencias opcionales (para mejores alertas)
```bash
# Para alertas gráficas avanzadas
sudo apt install zenity

# Para notificaciones del sistema
sudo apt install libnotify-bin
```

## 🚀 Instalación

1. **Descargar el script:**
```bash
wget -O app_timer_manager.sh [URL_DEL_SCRIPT]
# o copiar el código manualmente
```

2. **Hacer ejecutable:**
```bash
chmod +x app_timer_manager.sh
```

3. **Mover a un directorio en PATH (opcional):**
```bash
sudo mv app_timer_manager.sh /usr/local/bin/app-timer
```

## 📖 Uso

### Sintaxis básica
```bash
./app_timer_manager.sh -t TIEMPO -u UNIDAD -r REPETICIONES -m "MENSAJE" -a "APP1,APP2,..."
```

### Parámetros

| Parámetro | Descripción | Requerido | Ejemplo |
|-----------|-------------|-----------|---------|
| `-t, --timer` | Tiempo entre alertas (número) | ✅* | `-t 5` |
| `-u, --unit` | Unidad: 's' (segundos) o 'm' (minutos) | ❌ | `-u s` |
| `-r, --repeat` | Número de veces a repetir la alerta | ✅* | `-r 3` |
| `-m, --message` | Mensaje a mostrar en la alerta | ✅* | `-m "¡Hora de descansar!"` |
| `-f, --final` | Mensaje final para la última alerta | ❌ | `-f "¡Completado!"` |
| `-a, --apps` | Aplicaciones separadas por comas | ✅* | `-a "firefox,code"` |
| `--config` | Archivo de configuración (nombre o ruta completa) | ❌ | `--config pomodoro` |
| `-s, --status` | Mostrar estado del timer | ❌ | `-s` |
| `-k, --kill` | Detener timer activo | ❌ | `-k` |
| `-c, --create-config` | Crear archivo de configuración por defecto | ❌ | `-c` |
| `-h, --help` | Mostrar ayuda | ❌ | `-h` |

*\* Requerido solo si no está definido en la configuración por defecto*

## ⚙️ Sistema de configuración

El script soporta un sistema flexible de configuración que permite definir valores por defecto para todos los parámetros mediante archivos de configuración.

### Crear archivo de configuración
```bash
./app_timer_manager.sh --create-config
```

### Personalizar configuración
Edita el archivo `timer_defaults.conf` creado:

```bash
# Configuración por defecto para app_timer_manager.sh
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
```

### Tipos de configuración

#### 1. Configuración por defecto (`timer_defaults.conf`)
Se carga automáticamente si existe en el directorio del script:

```bash
# Usar TODOS los valores por defecto
./app_timer_manager.sh

# Sobreescribir solo algunos valores
./app_timer_manager.sh -t 10 -u s  # Usa defaults para mensaje, apps, etc.
./app_timer_manager.sh -m "Mensaje personalizado"  # Usa defaults para tiempo, apps, etc.
```

#### 2. Configuración con templates
El script incluye una carpeta `templates/` con configuraciones predefinidas para actividades comunes:

```bash
# Usar templates predefinidos (busca automáticamente en templates/)
./app_timer_manager.sh --config cepillado      # templates/cepillado.conf
./app_timer_manager.sh --config pomodoro       # templates/pomodoro.conf
./app_timer_manager.sh --config ejercicios     # templates/ejercicios.conf
./app_timer_manager.sh --config gaming         # templates/gaming.conf

# También funciona con extensión .conf
./app_timer_manager.sh --config pomodoro.conf

# Combinar template con parámetros específicos
./app_timer_manager.sh --config ejercicios -r 5 -m "Mensaje custom"
```

#### 3. Configuración personalizada externa
Para archivos fuera de templates, usar rutas completas o relativas:

```bash
# Ruta absoluta
./app_timer_manager.sh --config /home/user/mi_config.conf

# Ruta relativa
./app_timer_manager.sh --config ./mi_config.conf
./app_timer_manager.sh --config ../configs/trabajo.conf

# Crear configuración personalizada
cp templates/pomodoro.conf ./mi_config_trabajo.conf
# ... editar mi_config_trabajo.conf ...
./app_timer_manager.sh --config ./mi_config_trabajo.conf
```

#### 4. Lógica inteligente de ubicación
El parámetro `--config` determina automáticamente dónde buscar el archivo:

| Formato | Ubicación | Ejemplo |
|---------|-----------|---------|
| Nombre simple | `templates/NOMBRE.conf` | `--config cepillado` |
| Nombre con .conf | `templates/NOMBRE.conf` | `--config pomodoro.conf` |
| Ruta absoluta | Ruta especificada | `--config /home/user/config.conf` |
| Ruta relativa | Relativa al directorio actual | `--config ./mi_config.conf` |

#### 5. Prioridad de configuración
1. **Parámetros de línea de comandos** (máxima prioridad)
2. **Templates o archivos personalizados** (`--config`)
3. **Archivo de configuración por defecto** (`timer_defaults.conf`)
4. **Valores hardcoded del script** (mínima prioridad)

## 📝 Ejemplos de uso

### 1. Crear timer básico con múltiples aplicaciones
```bash
./app_timer_manager.sh -t 5 -u m -r 3 -m "¡Hora de descansar!" -a "firefox,code,spotify"
```
- Abre Firefox, VS Code y Spotify
- Muestra alerta cada 5 minutos
- Total de 3 alertas

### 2. Timer con segundos y mensaje final
```bash
./app_timer_manager.sh -t 30 -u s -r 4 -m "Trabajando..." -f "¡Descanso completado!" -a "code,slack"
```
- Alerta cada 30 segundos
- 4 repeticiones: 3 con "Trabajando...", 1 con "¡Descanso completado!"

### 3. Agregar aplicaciones al timer existente
```bash
./app_timer_manager.sh -a "discord,telegram"
```
- Agrega Discord y Telegram sin afectar el timer activo

### 4. Casos de uso específicos

#### Técnica Pomodoro
```bash
./app_timer_manager.sh -t 25 -u m -r 4 -m "¡Descanso de 5 minutos!" -f "¡Sesión Pomodoro completada!" -a "code,slack,notion"
```

#### Gaming con recordatorios
```bash
./app_timer_manager.sh -t 30 -u m -r 3 -m "¡Hora de estirar! Cuida tu postura" -a "steam,discord"
```

#### Ejercicios con intervalos cortos
```bash
./app_timer_manager.sh -t 45 -u s -r 8 -m "Cambia de ejercicio" -f "¡Rutina completada!" -a "spotify,timer-app"
```

#### Cepillado de dientes (con configuración personalizada)
```bash
# Crear config_cepillado.conf con:
# DEFAULT_TIMER_VALUE="30"
# DEFAULT_TIME_UNIT="s"
# DEFAULT_REPEAT_COUNT="4"
# DEFAULT_ALERT_MESSAGE="Cambia de cuadrante"
# DEFAULT_FINAL_MESSAGE="¡Cepillado completado!"
# DEFAULT_APPS_STRING="music-app"
# DEFAULT_NOTIFICATION_TIMEOUT="8"

./app_timer_manager.sh --config config_cepillado.conf
```

#### Estudio con herramientas
```bash
./app_timer_manager.sh -t 15 -u m -r 6 -m "Revisa tus notas y toma agua" -a "firefox,anki,libreoffice"
```

#### Abrir archivo específico
```bash
./app_timer_manager.sh -t 10 -u m -r 2 -m "Revisar progreso" -a "gedit /home/user/proyecto.txt,firefox https://github.com"
```

### 5. Templates incluidos

El script incluye templates predefinidos en la carpeta `templates/`:

#### pomodoro.conf
```bash
# Configuración para técnica Pomodoro
DEFAULT_TIMER_VALUE="25"
DEFAULT_TIME_UNIT="m"
DEFAULT_REPEAT_COUNT="4"
DEFAULT_ALERT_MESSAGE="¡Descanso de 5 minutos!"
DEFAULT_FINAL_MESSAGE="¡Sesión Pomodoro completada!"
DEFAULT_APPS_STRING="code,slack,notion"
DEFAULT_NOTIFICATION_TIMEOUT="30"

# Uso: ./app_timer_manager.sh --config pomodoro
```

#### gaming.conf
```bash
# Configuración para descansos durante gaming
DEFAULT_TIMER_VALUE="30"
DEFAULT_TIME_UNIT="m"  
DEFAULT_REPEAT_COUNT="3"
DEFAULT_ALERT_MESSAGE="¡Hora de estirar! Cuida tu postura"
DEFAULT_FINAL_MESSAGE="¡Sesión de gaming saludable!"
DEFAULT_APPS_STRING="steam,discord"
DEFAULT_NOTIFICATION_TIMEOUT="25"

# Uso: ./app_timer_manager.sh --config gaming
```

### 6. Gestión del timer

#### Ver estado actual
```bash
./app_timer_manager.sh -s
```

#### Detener timer
```bash
./app_timer_manager.sh -k
```

#### Crear/actualizar configuración por defecto
```bash
./app_timer_manager.sh --create-config
```

## 🖥️ Tipos de alertas

El script utiliza diferentes métodos de alerta según las herramientas disponibles:

### 1. Zenity (Recomendado)
- Ventanas gráficas con botones
- Opción de detener el timer desde la alerta
- Barras de progreso visual

### 2. Notify-send
- Notificaciones del sistema
- Alertas menos intrusivas
- Se muestran en el área de notificaciones

### 3. Terminal (Fallback)
- Alertas en texto
- Sonido de beep del sistema
- Pausa hasta presionar Enter

## 📁 Archivos del sistema

| Archivo | Ubicación | Propósito |
|---------|-----------|-----------|
| `app_timer.log` | `~/app_timer.log` | Log detallado de actividades |
| `timer_defaults.conf` | Directorio del script | Configuración por defecto |
| `templates/` | Directorio del script | Templates de configuración predefinidos |
| `app_timer_daemon.pid` | `/tmp/` | PID del timer activo |
| `app_timer_config` | `/tmp/` | Configuración del timer actual |
| `app_timer_apps` | `/tmp/` | Lista de aplicaciones registradas |

## 🔧 Solución de problemas

### Timer no inicia
```bash
# Verificar permisos
ls -la app_timer_manager.sh

# Revisar dependencias
which zenity notify-send

# Ver logs para errores
tail -f ~/app_timer.log

# Verificar parámetros de tiempo
./app_timer_manager.sh -t 0 -u s -r 1 -m "test" -a "gedit"  # Error: tiempo debe ser > 0
```

### Configuración no funciona
```bash
# Verificar configuración por defecto
ls -la timer_defaults.conf
./app_timer_manager.sh --create-config  # Recrear si es necesario

# Verificar configuración personalizada
ls -la config_mi_archivo.conf
cat config_mi_archivo.conf  # Verificar sintaxis

# Error: "No se puede encontrar el archivo de configuración"
./app_timer_manager.sh --config /ruta/completa/archivo.conf  # Usar ruta absoluta
./app_timer_manager.sh --config ./archivo.conf  # O ruta relativa correcta
```

### Templates no encontrados
```bash
# Verificar que existe la carpeta templates/
ls -la templates/

# Ver templates disponibles
ls templates/

# Error común: usar ruta cuando debería ser nombre
./app_timer_manager.sh --config ./templates/pomodoro.conf  # ❌ Redundante
./app_timer_manager.sh --config pomodoro                   # ✅ Correcto

# Crear template personalizado
cp templates/pomodoro.conf templates/mi_template.conf
```

### Configuraciones no se aplican
```bash
# Verificar prioridad: CLI > --config > timer_defaults.conf
./app_timer_manager.sh --config pomodoro -t 10  # -t 10 tendrá prioridad

# Verificar que el archivo se está cargando
# El script mostrará: "✅ Configuración personalizada cargada: templates/pomodoro.conf"

# Error de rutas
./app_timer_manager.sh --config /ruta/inexistente.conf     # ❌ Archivo no existe
./app_timer_manager.sh --config template_inexistente      # ❌ Template no existe
```

### Aplicaciones no abren
```bash
# Verificar que el comando existe
which firefox code spotify

# Probar comando manualmente
firefox &

# Verificar sintaxis de aplicaciones con parámetros
./app_timer_manager.sh -t 10 -u s -r 1 -m "test" -a "google-chrome https://example.com"
```

### Problemas con unidades de tiempo
```bash
# Verificar unidad válida
./app_timer_manager.sh -t 30 -u x -r 1 -m "test" -a "gedit"  # Error: unidad inválida

# Unidades aceptadas: s, sec, seconds, m, min, minutes
./app_timer_manager.sh -t 30 -u sec -r 1 -m "test" -a "gedit"  # ✅ Válido
```

### Múltiples timers
```bash
# Ver procesos relacionados
ps aux | grep app_timer

# Limpiar archivos temporales
rm -f /tmp/app_timer_*
```

### Alertas no aparecen
```bash
# Instalar zenity
sudo apt install zenity

# Verificar entorno gráfico
echo $DISPLAY
```

## 📊 Ejemplos de salida

### Creación exitosa de timer (con configuración por defecto)
```
2025-09-06 22:06:35: Configuración por defecto cargada desde timer_defaults.conf
🆕 Creando nuevo timer...
🚀 Abriendo: firefox
🚀 Abriendo: gedit
✅ Se abrieron 2 nuevas aplicaciones

⏱️  Iniciando timer:
   • Intervalo: 5s
   • Repeticiones: 4
   • Mensaje: '¡Hora de tomar un descanso!'
   • Primera alerta: 22:06:42
   • Duración total: 20s

✅ Timer iniciado en background
```

### Creación de configuración por defecto
```
./app_timer_manager.sh --create-config
✅ Archivo de configuración creado: /home/user/tools/timer/timer_defaults.conf
   Puedes editarlo para personalizar los valores por defecto
```

### Uso de template
```
./app_timer_manager.sh --config cepillado
✅ Configuración personalizada cargada: /home/user/tools/timer/templates/cepillado.conf
🆕 Creando nuevo timer...
🚀 Abriendo: music-app
✅ Se abrieron 1 nuevas aplicaciones

⏱️  Iniciando timer:
   • Intervalo: 30s
   • Repeticiones: 4
   • Mensaje: 'Cambia de cuadrante'
   • Primera alerta: 22:34:21
   • Duración total: 2m

✅ Timer iniciado en background
```

### Template Pomodoro con parámetros sobreescritos
```
./app_timer_manager.sh --config pomodoro -r 2 -m "Trabajo concentrado"
✅ Configuración personalizada cargada: /home/user/tools/timer/templates/pomodoro.conf
🆕 Creando nuevo timer...
🚀 Abriendo: code
🚀 Abriendo: slack
🚀 Abriendo: notion
✅ Se abrieron 3 nuevas aplicaciones

⏱️  Iniciando timer:
   • Intervalo: 25m
   • Repeticiones: 2                    # Sobreescrito por -r 2
   • Mensaje: 'Trabajo concentrado'     # Sobreescrito por -m
   • Primera alerta: 23:00:15
   • Duración total: 50m

✅ Timer iniciado en background
```

### Estado del timer
```
🟢 Timer ACTIVO (PID: 12345)
   ⏱️  Intervalo: 5 minutos
   🔁 Repeticiones: 3
   💬 Mensaje: '¡Hora de descansar!'
   📅 Iniciado: Sáb Sep  6 14:18:15 2025
   📱 Aplicaciones registradas:
      • firefox
      • code
      • spotify

📊 Últimas entradas del log:
2025-09-06 14:18:15: Timer daemon iniciado (PID: 12345) - 5 min, 3 repeticiones
2025-09-06 14:18:15: Abriendo aplicación: firefox
2025-09-06 14:18:16: Abriendo aplicación: code
2025-09-06 14:18:17: Abriendo aplicación: spotify
2025-09-06 14:18:17: Se abrieron 3 nuevas aplicaciones
```

## 📊 Monitoreo y Estadísticas

### Comando de Estadísticas
Ver un resumen completo de uso del script:

```bash
./timerly.sh --stats
```

**Salida:**
```
╔════════════════════════════════════════════════════════╗
║               📊 ESTADÍSTICAS DE TIMERLY              ║
╠════════════════════════════════════════════════════════╣
║                                                        ║
║  📅 Fecha de creación: 2025-12-27 12:10:15
║  ⏱️  Tiempo activo: 1d 5h 23m
║                                                        ║
║  📈 RESUMEN GENERAL:                                   ║
║     • Total de timers creados: 42
║     • Total de aplicaciones ejecutadas: 156
║     • Total de alertas mostradas: 168
║     • Tiempo total en timers: 42h 15m 30s
║                                                        ║
║  📊 PROMEDIOS:                                       ║
║     • Apps por timer: 3.7
║     • Alertas por timer: 4
║                                                        ║
║  📋 INFORMACIÓN DEL LOG:                              ║
║     • Líneas de log: 2150
║     • Tamaño del archivo: 256K
║                                                        ║
╚════════════════════════════════════════════════════════╝
```

### Monitoreo de Aplicaciones

El script ahora incluye un sistema avanzado de monitoreo que registra:

#### 1. **Inicio de Aplicación**
```
2025-12-27 12:10:15: ═══════════════════════════════════════════════════════════
2025-12-27 12:10:15: ▶️  APLICACIÓN INICIADA
2025-12-27 12:10:15:    Nombre: firefox
2025-12-27 12:10:15:    PID: 396349
2025-12-27 12:10:15:    Hora: 2025-12-27 12:10:15
2025-12-27 12:10:15:    Timestamp: 2025-12-27T17:10:15Z
```

#### 2. **Cierre de Aplicación**
```
2025-12-27 12:10:20: ═══════════════════════════════════════════════════════════
2025-12-27 12:10:20: ⏹️  APLICACIÓN TERMINADA
2025-12-27 12:10:20:    Nombre: firefox
2025-12-27 12:10:20:    Estado: ✅ EXITOSA
2025-12-27 12:10:20:    Inicio: 2025-12-27 12:10:15
2025-12-27 12:10:20:    Fin: 2025-12-27 12:10:20
2025-12-27 12:10:20:    Duración: 5s (5s exactos)
2025-12-27 12:10:20:    Código de salida: 0
2025-12-27 12:10:20:    Log (líneas): 1753 | Tamaño: 128K
```

#### 3. **Inicio del Timer Daemon**
```
2025-12-27 12:10:16: ═══════════════════════════════════════════════════════════
2025-12-27 12:10:16: ▶️  TIMER DAEMON INICIADO
2025-12-27 12:10:16:    PID: 396405
2025-12-27 12:10:16:    Intervalo: 2s
2025-12-27 12:10:16:    Repeticiones: 1
2025-12-27 12:10:16:    Hora inicio: 2025-12-27 12:10:16
```

#### 4. **Finalización del Timer Daemon**
```
2025-12-27 12:10:20: ═══════════════════════════════════════════════════════════
2025-12-27 12:10:20: ✅ TIMER DAEMON COMPLETADO EXITOSAMENTE
2025-12-27 12:10:20:    Inicio: 2025-12-27 12:10:16
2025-12-27 12:10:20:    Fin: 2025-12-27 12:10:20
2025-12-27 12:10:20:    Duración total: 4s (4s exactos)
2025-12-27 12:10:20:    Alertas procesadas: 1
2025-12-27 12:10:20:    Intervalo por alerta: 2s
```

### Archivos de Monitoreo

| Archivo | Ubicación | Propósito |
|---------|-----------|-----------|
| `app_wrapper.sh` | Directorio del script | Monitorea inicio y cierre de aplicaciones |
| `timerly_stats` | `/tmp/` | Estadísticas acumuladas de uso |
| `timerly.log` | `~/timerly.log` | Log detallado de todas las operaciones |

### Características de Monitoreo

✨ **Nuevas mejoras implementadas:**

- ✅ **Registro detallado de aplicaciones**: Hora exacta de inicio y cierre
- ✅ **Medición de duración**: Tiempo exacto que duró cada aplicación
- ✅ **Códigos de salida**: Registro del código de retorno de cada aplicación
- ✅ **PID de aplicaciones**: Identificador del proceso para debugging
- ✅ **Estadísticas globales**: Totales acumulados y promedios
- ✅ **Información del log**: Líneas totales y tamaño del archivo
- ✅ **Formato mejorado**: Bloques visuales con separadores claros
- ✅ **Timestamps ISO**: Además de formato local para mejor trazabilidad

## 🤝 Contribuciones

¿Encontraste un bug o tienes una idea para mejorar el script?

1. Reporta issues describiendo el problema
2. Sugiere nuevas características
3. Comparte casos de uso interesantes

## 📄 Licencia

Este script es de código abierto y puede ser usado, modificado y distribuido libremente.

## 🙏 Créditos

Desarrollado para Linux Mint Cinnamon con compatibilidad para distribuciones basadas en Ubuntu/Debian.

---

**¿Necesitas ayuda?** Ejecuta `./app_timer_manager.sh -h` para ver la ayuda integrada.