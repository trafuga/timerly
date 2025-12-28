# Timerly

Un script de Bash avanzado para Linux que proporciona un sistema completo de temporizadores con alertas visuales y sonoras, gestión de aplicaciones y estadísticas detalladas. Ideal para técnicas de productividad (Pomodoro), ejercicio, pausas programadas y más.

## 🌟 Características Principales

- **⏰ Timer único y persistente**: Solo una instancia activa de timer por sesión para evitar conflictos. Permite agregar nuevas aplicaciones sin reiniciar.
- **⏱️ Soporte completo de tiempo**: Funciona con segundos y minutos con validación y conversión automática.
- **🎯 Alertas inteligentes**: Notificaciones visuales (Zenity/Notify-send) + alertas sonoras con fallback a terminal.
- **📱 Gestión de aplicaciones**: Abre múltiples aplicaciones simultáneamente y monitorea su ciclo de vida.
- **⚙️ Sistema flexible de configuración**: Soporta configuración por defecto, templates predefinidos y configuraciones personalizadas.
- **⚡ Sintaxis simplificada**: Ejecuta configuraciones con `timerly pomodoro` en lugar de parámetros complejos.
- **🎬 Mensajes diferenciados**: Soporta mensaje normal para alertas intermedias y mensaje final opcional para la última alerta.
- **📊 Estadísticas acumuladas**: Seguimiento de timers creados, apps ejecutadas, alertas mostradas y tiempo total.
- **📝 Logs detallados con timestamps**: Registro completo en `~/timerly.log` (se limpia automáticamente cada día).
- **🧹 Limpieza automática**: Gestión inteligente de archivos temporales y logs diarios.

## 📋 Requisitos

### Sistema Operativo
- **Linux**: Cualquier distribución moderna (Mint, Ubuntu, Debian, Fedora, Arch, etc.)
- Compatible con escritorios que usen variables de entorno estándar (DISPLAY, DBUS_SESSION_BUS_ADDRESS, etc.)

### Dependencias Requeridas
- `bash` (versión 4.0+)
- `coreutils`: `ps`, `kill`, `sleep`, `nohup`, `date`, `basename`
- `bc` (para cálculos matemáticos en estadísticas)

### Dependencias Opcionales (Recomendadas)

#### Para Alertas Gráficas
```bash
# Mejor opción: alertas gráficas interactivas con botones
sudo apt install zenity
```

#### Para Notificaciones del Sistema (fallback si Zenity no disponible)
```bash
# Notificaciones en escritorio
sudo apt install libnotify-bin
```

#### Para Reproducción de Sonido (elige al menos una)
```bash
# Opción 1: PulseAudio (recomendado para sistemas modernos)
sudo apt install pulseaudio-utils  # comando: paplay

# Opción 2: ALSA (audio nativo del kernel)
sudo apt install alsa-utils        # comando: aplay

# Opción 3: SoX (flexible)
sudo apt install sox               # comando: play

# Opción 4: Reproductor multimedia versátil
sudo apt install mpv
```

**Nota**: El script intenta reproducir sonido usando todos los reproductores disponibles. Si ninguno funciona, emite un beep del sistema como fallback.

## 🚀 Instalación

### Paso 1: Obtener los archivos
Clona este repositorio o descarga los siguientes archivos manteniendo la estructura:
```
timer/
├── timerly.sh              # Script principal
├── app_wrapper.sh          # Wrapper para monitoreo de apps
├── timer_defaults.conf     # Configuración por defecto
├── templates/              # Carpeta con configuraciones predefinidas
│   ├── pomodoro.conf
│   ├── gaming.conf
│   └── test.conf
└── notifications.wav       # Archivo de sonido (opcional pero recomendado)
```

### Paso 2: Permisos de ejecución
```bash
chmod +x timerly.sh app_wrapper.sh
```

### Paso 3: Acceso global (opcional pero recomendado)
Para ejecutar `timerly` desde cualquier directorio sin especificar ruta:
```bash
sudo ln -s /ruta/completa/a/timerly.sh /usr/local/bin/timerly
```

Luego podrás usar simplemente:
```bash
timerly pomodoro
timerly -t 30 -u s -r 5 -m "Recordatorio" -a "firefox,code"
```

## 📖 Uso

### Flujo de Configuración

Timerly carga la configuración en el siguiente orden (cada nivel sobrescribe el anterior):

1. **Configuración por defecto** (`timer_defaults.conf` en el directorio del script)
2. **Configuración personalizada** (si se especifica con `--config` o sintaxis simplificada)
3. **Parámetros de línea de comandos** (sobrescriben todo lo anterior)

### Sintaxis Simplificada (Recomendada)

Si usas una configuración template, puedes ejecutar simplemente:
```bash
# Usar directamente el nombre del template
./timerly.sh pomodoro          # Carga templates/pomodoro.conf
./timerly.sh gaming            # Carga templates/gaming.conf
./timerly.sh test              # Carga templates/test.conf

# O con alias global (después de linked a /usr/local/bin)
timerly pomodoro
```

### Sintaxis Completa (Parámetros individuales)

Para máxima flexibilidad, especifica todos los parámetros:
```bash
./timerly.sh -t TIEMPO -u UNIDAD -r REPETICIONES -m "MENSAJE" [-f "MENSAJE_FINAL"] -a "APP1,APP2,..."
```

El parámetro `-f` (mensaje final) es **opcional**. Si se omite, se usa el mismo mensaje para todas las alertas.

### Parámetros Disponibles

| Parámetro | Descripción | Requerido | Ejemplo |
|-----------|-------------|-----------|---------|
| `-t, --timer` | Tiempo entre alertas (número entero > 0) | ✅\* | `-t 25` |
| `-u, --unit` | Unidad de tiempo: `s`/`sec`/`seconds` o `m`/`min`/`minutes` | ❌ | `-u m` |
| `-r, --repeat` | Número de alertas a mostrar (> 0) | ✅\* | `-r 4` |
| `-m, --message` | Mensaje para las alertas (excepto la última) | ✅\* | `-m "¡Tomar descanso!"` |
| `-f, --final` | Mensaje especial para la última alerta | ❌ | `-f "¡Completado!"` |
| `-a, --apps` | Apps a abrir (separadas por comas) | ✅\* | `-a "firefox,code"` |
| `--config` | Usar configuración template o archivo personalizado | ❌ | `--config pomodoro` |
| `-s, --status` | Mostrar estado actual del timer activo | ❌ | `-s` |
| `-k, --kill` | Detener el timer activo | ❌ | `-k` |
| `-c, --create-config` | Crear `timer_defaults.conf` con valores de ejemplo | ❌ | `-c` |
| `--stats` | Mostrar estadísticas acumuladas de uso | ❌ | `--stats` |
| `--reset-stats` | Resetear estadísticas (pide confirmación) | ❌ | `--reset-stats` |
| `-h, --help` | Mostrar pantalla de ayuda completa | ❌ | `-h` |

\*\* **Requerido solo si no está definido en la configuración cargada** (default, template o personalizada).

**Nota sobre `-u`**: Si se omite, por defecto usa minutos (`m`) para compatibilidad.

## ⚙️ Sistema de Configuración

Timerly utiliza un sistema de configuración en **3 niveles** con precedencia decreciente:

### Nivel 1: Configuración Global (`timer_defaults.conf`)
Es la configuración "por defecto" que se carga automáticamente cada vez que ejecutas Timerly.

**Crear archivo de configuración:**
```bash
./timerly.sh --create-config
# Crea timer_defaults.conf en el mismo directorio de timerly.sh
```

**Contenido de ejemplo:**
```bash
DEFAULT_TIMER_VALUE="25"
DEFAULT_TIME_UNIT="m"
DEFAULT_REPEAT_COUNT="4"
DEFAULT_ALERT_MESSAGE="¡Tomar descanso!"
DEFAULT_FINAL_MESSAGE="¡Sesión completada!"
DEFAULT_APPS_STRING="firefox,code"
DEFAULT_NOTIFICATION_TIMEOUT="20"
```

### Nivel 2: Templates (Configuraciones Predefinidas)
Son archivos `.conf` guardados en la carpeta `templates/` con configuraciones pre-hechas para casos específicos.

**Estructura esperada:**
```
timer/
└── templates/
    ├── pomodoro.conf       # Técnica Pomodoro (25m x4)
    ├── gaming.conf         # Sesiones de gaming (45m x2)
    ├── test.conf           # Para pruebas rápidas
    └── tu_config.conf      # Tus propias configuraciones
```

**Usar un template:**
```bash
# Sintaxis simplificada
./timerly.sh pomodoro

# Con parámetros que sobrescriben el template
./timerly.sh pomodoro -m "Pomodoro intensivo"
./timerly.sh gaming -a "discord,spotify"
```

**Crear un template personalizado:**
Copia el contenido de `timer_defaults.conf` a `templates/miconfig.conf` y edítalo según necesites.

### Nivel 3: Parámetros de Línea de Comandos
Los argumentos pasados directamente al script tienen la **máxima prioridad**.

```bash
# Sobrescribe todo (timer_defaults.conf, template, etc)
./timerly.sh -t 15 -u m -r 3 -m "Mensaje custom" -a "app1,app2"
```

### Agregar Aplicaciones a Timer Activo

Si ya hay un timer ejecutándose, puedes agregar más aplicaciones sin interrumpir el timer:

```bash
# En otra terminal, mientras el timer está activo
./timerly.sh -a "discord,spotify"

# Resultado: Se abren discord y spotify, el timer continúa normalmente
```

Esta característica es útil para agregar aplicaciones de forma dinámica sin perder el progreso del timer.

## 📝 Ejemplos Prácticos de Uso

### Usando Templates (Recomendado - Más simple)

```bash
# Ejecutar técnica Pomodoro predefinida
timerly pomodoro
# Abre: code, slack, notion
# Timer: 25m x4 alertas

# Usar template gaming
timerly gaming
# Timer: 45m x2 alertas (sin apps específicas)

# Sobrescribir parámetros del template
timerly pomodoro -m "Pomodoro + Spotify"
timerly gaming -a "discord,spotify"
```

### Syntax Completa (Máxima Flexibilidad)

```bash
# Timer de 25 minutos, 4 repeticiones (Pomodoro manual)
./timerly.sh -t 25 -u m -r 4 -m "Descanso Pomodoro" -a "code,firefox"

# Timer rápido de 30 segundos x10 (para pruebas/ejercicios)
./timerly.sh -t 30 -u s -r 10 -m "Cambio de movimiento" -a "gedit"

# Timer con mensaje final diferenciado
./timerly.sh -t 5 -u m -r 3 -m "Seguir trabajando" -f "¡Session completada!" -a "firefox"

# Timer sin unidad especificada (usa minutos por defecto)
./timerly.sh -t 15 -r 2 -m "Pausa" -a "spotify"
```

### Gestión del Timer Activo

```bash
# Ver estado del timer en ejecución
timerly -s
timerly --status

# Agregar aplicaciones al timer actual (sin detenerlo)
timerly -a "discord,telegram"

# Detener timer activo
timerly -k
timerly --kill

# Ver estadísticas acumuladas
timerly --stats

# Resetear estadísticas (con confirmación)
timerly --reset-stats
```

### Administración de Configuraciones

```bash
# Crear archivo de configuración por defecto local
timerly --create-config

# Usar archivo de configuración personalizado
timerly --config /ruta/a/mi_config.conf
timerly --config ./config_personal.conf

# Ayuda completa
timerly -h
timerly --help
```

## 📊 Monitoreo y Estadísticas

Timerly incluye un sistema avanzado de logging y estadísticas acumuladas.

### Estado Actual del Timer

```bash
timerly --status
timerly -s
```

**Información mostrada:**
- 🟢/🔴 Estado del timer (activo/inactivo)
- PID del proceso daemon
- ⏱️ Intervalo configurado
- 🔁 Número de repeticiones
- 💬 Mensaje de alerta
- 📅 Fecha de inicio del timer
- 📱 Aplicaciones registradas
- 📊 Últimas 5 líneas del log

**Ejemplo de salida:**
```
🟢 Timer ACTIVO (PID: 12345)
   ⏱️  Intervalo: 25m
   🔁 Repeticiones: 4
   💬 Mensaje: '¡Tomar descanso!'
   📅 Iniciado: Mon Dec 28 10:45:30 2025
   📱 Aplicaciones registradas:
      • code
      • firefox

📊 Últimas entradas del log:
10:45:30 ▶️ Timer PID:12345 | 25m x4
10:50:45 ⏳ 1/4: -12m
10:55:30 🔔 Alerta 1/4
```

### Estadísticas Acumuladas

```bash
timerly --stats
```

**Información mostrada:**
- 📅 Fecha de creación de estadísticas
- ⏱️ Tiempo activo acumulado (días, horas, minutos)
- 📱 Número total de aplicaciones ejecutadas
- ⏱️ Tiempo total ejecutado (en formato MM:SS)
- Una tabla ASCII con todos los registros de ejecución de aplicaciones

**Campos por aplicación:**
- ✅/⚠️ Estado (éxito o warning)
- PID del proceso
- Nombre de la aplicación
- Hora inicio → fin
- Duración exacta

**Ejemplo:**
```
╔════════════════════════════════════════════════════════════════════╗
║               📊 HISTORIAL DE APLICACIONES EJECUTADAS             ║
╠════════════════════════════════════════════════════════════════════╣

📅 Fecha de creación: 2025-12-25 09:15:20
⏱️  Tiempo activo: 3d 4h 22m

✅ PID:1234 | code | 12-25 09:15:30 → 14:30:45 | 5:15m
✅ PID:1235 | firefox | 12-25 09:15:45 → 14:45:20 | 5:29m
⚠️  PID:1236 | spotify | 12-26 10:20:10 → 11:45:30 | 1:25m

📱 Aplicaciones ejecutadas: 47
⏱️  Tiempo total ejecutado: 142:35m
╚════════════════════════════════════════════════════════════════════╝
```

### Resetear Estadísticas

```bash
timerly --reset-stats
```

**Comportamiento:**
1. Muestra el resumen de estadísticas actuales
2. Pide confirmación (escribe `sí` o `si`)
3. Reinicia el contador de estadísticas
4. Guarda un resumen en el log antes de resetear

**Nota importante:** Los datos anteriores se conservan siempre en `~/timerly.log`, solo se reinician los contadores.

### Logs y Registros

**Archivo principal:**
- `~/timerly.log`: Registro persistente de todas las operaciones del sistema
  - Se limpia automáticamente cada **nuevo día**
  - Contiene timestamps precisos (YYYY-MM-DD HH:MM:SS)
  - Logs por aplicación con formato compacto: `✅ PID:XXXX | APP | inicio → fin | duración`

**Ejemplo de contenido del log:**
```
2025-12-28 10:45:30: ▶️ Timer PID:12345 | 25m x4
2025-12-28 10:45:30: ⚙️ Config: pomodoro.conf
2025-12-28 10:45:35: 🚀 code
2025-12-28 10:45:36: 🚀 firefox
2025-12-28 10:45:37: 📱 Apps: 2
2025-12-28 10:50:30: ⏳ 1/4: -20m
2025-12-28 11:10:30: 🔔 Alerta 1/4 | 25m
2025-12-28 11:10:31: ✅ PID:5678 | code | 12-28 10:45:35 → 11:10:31 | 24:56m
2025-12-28 11:10:32: ✅ PID:5679 | firefox | 12-28 10:45:36 → 11:10:32 | 24:56m
```

## 📁 Archivos del Sistema

### Archivos Permanentes (En el directorio de instalación)

| Archivo | Propósito | Tipo |
|---------|-----------|------|
| `timerly.sh` | Script principal (daemon, config, alertas) | Ejecutable bash |
| `app_wrapper.sh` | Wrapper que monitorea inicio/cierre de apps | Ejecutable bash |
| `timer_defaults.conf` | Configuración global por defecto | Configuración |
| `templates/` | Carpeta con configuraciones predefinidas | Directorio |
| `templates/pomodoro.conf` | Template Pomodoro (25m x4) | Configuración |
| `templates/gaming.conf` | Template Gaming (45m x2) | Configuración |
| `templates/test.conf` | Template para pruebas rápidas | Configuración |
| `notifications.wav` | Archivo de sonido para alertas (opcional) | Audio WAV |

### Archivos de Usuario (Persistentes)

| Archivo | Ubicación | Propósito | Limpieza |
|---------|-----------|-----------|----------|
| `timerly.log` | `$HOME/timerly.log` | Log acumulado de todas operaciones | Automática cada día |
| `timerly_log_date` | `/tmp/timerly_log_date` | Fecha del último reset de log | Diaria |

### Archivos Temporales (Se borran al terminar/detener timer)

| Archivo | Ubicación | Propósito | Duración |
|---------|-----------|-----------|----------|
| `timerly_daemon.pid` | `/tmp/timerly_daemon.pid` | PID del proceso daemon activo | Mientras el timer está activo |
| `timerly_config` | `/tmp/timerly_config` | Configuración actual en ejecución | Mientras el timer está activo |
| `timerly_apps` | `/tmp/timerly_apps` | Lista de aplicaciones registradas | Mientras el timer está activo |
| `timerly_stats` | `/tmp/timerly_stats` | Almacenamiento de estadísticas | Persistente entre sesiones |

### Estructura Recomendada de Instalación

```
/home/usuario/tools/timer/
├── timerly.sh                   # Script principal
├── app_wrapper.sh               # Wrapper de monitoreo
├── timer_defaults.conf          # Config por defecto
├── notifications.wav            # Sonido (opcional)
├── templates/
│   ├── pomodoro.conf           # Template Pomodoro
│   ├── gaming.conf             # Template Gaming
│   ├── test.conf               # Template Test
│   └── miconfig.conf           # Tus configuraciones
└── README.md                    # Documentación

# Archivo de usuario (home)
~/ timerly.log                   # Log persistente

# Archivos temporales (se crean automáticamente)
/tmp/timerly_daemon.pid
/tmp/timerly_config
/tmp/timerly_apps
/tmp/timerly_stats
/tmp/timerly_log_date
```

## 🔧 Solución de Problemas

### 🔊 El timer no reproduce sonido

**Solución:**

1. Verifica que tengas instalado al menos uno de los reproductores soportados:
   ```bash
   # Comprobar cuáles tienes instalados
   which paplay aplay play mpv
   ```

2. Si ninguno está instalado, instala PulseAudio (recomendado):
   ```bash
   sudo apt install pulseaudio-utils
   ```

3. Verifica que `notifications.wav` exista en el directorio del script:
   ```bash
   ls -la /ruta/a/timerly/notifications.wav
   ```

4. Prueba reproducción manual:
   ```bash
   paplay /ruta/a/timerly/notifications.wav
   ```

5. Si PulseAudio está desactivado, intenta:
   ```bash
   pulseaudio --start
   ```

**Fallback automático:** Si no está disponible ningún reproductor, el script emite un beep del sistema (`\a`).

### 📱 No se abren las aplicaciones

**Solución:**

1. Verifica que las aplicaciones estén instaladas:
   ```bash
   which code firefox spotify  # Comprueba si existen en tu PATH
   ```

2. Si la app no está en PATH, especifica la ruta completa:
   ```bash
   timerly -a "/usr/bin/code,firefox"
   ```

3. Para verificar si una app se ejecutó, revisa el log:
   ```bash
   tail -20 ~/timerly.log
   ```

4. Algunas apps necesitan parámetros especiales (ej: Flatpak):
   ```bash
   timerly -a "flatpak run com.spotify.Client"
   ```

### ⚙️ Permisos de ejecución

**Error:** `Permission denied`

**Solución:**
```bash
chmod +x /ruta/a/timerly.sh /ruta/a/app_wrapper.sh
```

### ⏱️ El timer no se inicia o aparece error

**Posibles causas:**

1. **Parámetros inválidos:**
   ```bash
   # ✅ Correcto
   timerly -t 25 -u m -r 4 -m "Mensaje" -a "app1,app2"

   # ❌ Incorrecto (valores <= 0)
   timerly -t 0 -u m -r 0 -m "Mensaje" -a "app1,app2"
   ```

2. **Ya hay un timer activo:**
   ```bash
   # Ver si hay timer activo
   timerly -s

   # Si quieres detenerlo
   timerly -k
   ```

3. **Falta el archivo `app_wrapper.sh`:**
   ```bash
   # Verifica que exista en el mismo directorio que timerly.sh
   ls -la /ruta/a/app_wrapper.sh
   ```

### 📝 El log está lleno o contiene información antigua

**Limpiar manualmente:**
```bash
# El log se limpia automáticamente cada día
# Pero si quieres limpiarlo manualmente:
> ~/timerly.log

# Para ver el log actual
tail -30 ~/timerly.log
```

### 🐛 Debugging

Para obtener más información sobre errores:

1. **Mostrar ayuda completa:**
   ```bash
   timerly -h
   timerly --help
   ```

2. **Ver estado del timer:**
   ```bash
   timerly -s
   timerly --status
   ```

3. **Revisar log en tiempo real:**
   ```bash
   tail -f ~/timerly.log
   ```

4. **Verificar archivos temporales:**
   ```bash
   ls -la /tmp/timerly_*
   ```

5. **Ejecutar con salida detallada:**
   ```bash
   bash -x ./timerly.sh -t 5 -u s -r 2 -m "Test" -a "gedit"
   ```

### ✨ Tips Útiles

- **Crear alias para comandos frecuentes:**
  ```bash
  alias pomodoro='timerly pomodoro'
  alias gaming='timerly gaming'
  ```

- **Limpiar estadísticas si se corrompen:**
  ```bash
  rm /tmp/timerly_stats
  timerly --stats  # Se reinicializarán automáticamente
  ```

- **Usar templates personalizados:**
  ```bash
  # Copiar y editar un template
  cp templates/pomodoro.conf templates/mipomodoro.conf
  nano templates/mipomodoro.conf

  # Usar tu template
  timerly mipomodoro
  ```

---

## 📞 ¿Necesitas Ayuda?

1. Consulta la ayuda integrada:
   ```bash
   timerly -h
   ```

2. Revisa el archivo de log para ver qué sucedió:
   ```bash
   tail -50 ~/timerly.log
   ```

3. Verifica el estado actual:
   ```bash
   timerly -s
   ```

4. Para reportar un problema, incluye:
   - Salida de `timerly -h`
   - Contenido de `~/timerly.log` (últimas líneas)
   - Tu distribución Linux (`cat /etc/os-release`)
   - Los parámetros que usaste cuando falló