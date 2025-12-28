# 👨‍👩‍👧‍👦 Guía de Turnos Equitativos para Familias

## ¿Qué es Timerly y Por Qué Fue Creado?

**Timerly** fue diseñado para resolver un problema común en familias: **¿Cómo repartir equitativamente el tiempo de pantalla entre múltiples hijos que comparten un computador?**

En lugar de peleas y discusiones sobre quién le toca, Timerly:
- ⏰ Controla automáticamente el tiempo
- 📢 Avisa claramente cuándo termina un turno
- 📊 Registra exactamente cuánto tiempo cada hijo usó
- 🎯 Asegura que todos tengan oportunidades justas

---

## 🎮 Visualización del Flujo de Turnos

### Escenario: 3 Hermanos, Tarde de Gaming

```
14:00 ─────────────────────────────────────────── 19:00
│                                                      │
│  DIEGO              MARÍA              CARLOS        │
│  (45 min)           (45 min)           (45 min)      │
│                                                      │
14:00─────────────14:45─────────────15:30─────────────16:15
      ↓                  ↓                  ↓
   TURNO 1           TURNO 2            TURNO 3
   (Gaming)          (Gaming)           (Gaming)
      │                  │                  │
      └──→ ALERTA        └──→ ALERTA       └──→ ALERTA
      "¡Cambio de       "¡Cambio de       "¡Fin de la
       turno!"           turno!"           sesión!"
```

---

## 📝 Configuración Paso a Paso

### OPCIÓN 1: Turnos de 45 Minutos (Hermanos Adolescentes)

**Mejor para**: 2-3 hermanos entre 12-18 años

**Comando**:
```bash
timerly turnos_hermanos
```

**¿Qué pasa?**:
```
14:00:00 - Diego inicia su turno
          (Se abre Steam, Minecraft, Firefox automáticamente)

14:00:00 - 14:45:00 ⏱️ DIEGO JUGANDO

14:45:00 🔔 ALERTA
         "⏰ ¡CAMBIO DE TURNO!"
         "Le toca al siguiente hermano"
         (Diego debe guardar y salir)

14:45:00 - 15:00:00 ⏸️ DESCANSO/CAMBIO

15:00:00 - 15:45:00 ⏱️ MARÍA JUGANDO

15:45:00 🔔 ALERTA
         "⏰ ¡CAMBIO DE TURNO!"

16:00:00 - 16:45:00 ⏱️ CARLOS JUGANDO

16:45:00 🔔 ALERTA
         "✅ ¡Fin de la sesión!"
         "Todos tuvieron tiempo equitativo"
```

---

### OPCIÓN 2: Turnos de 20 Minutos (Niños Pequeños)

**Mejor para**: 2-3 hermanos entre 5-10 años

**Comando**:
```bash
timerly ninos_pequeños
```

**¿Qué pasa?**:
```
15:00:00 - LUCAS (7 años) inicia su turno
          (TuxPaint, Navegador, Gedit abiertos)

15:00:00 - 15:20:00 ⏱️ LUCAS DIBUJANDO

15:20:00 🔔 ALERTA
         "⏸️ Se acabó tu tiempo"
         "¡Le toca a Sofia!"

15:20:00 - 15:40:00 ⏱️ SOFÍA DIBUJANDO

15:40:00 🔔 ALERTA
         "✅ ¡Todos jugaron!"
         "Ahora, a hacer otra cosa"
```

**Ventaja**: Los tiempos cortos evitan frustración y berrinches

---

### OPCIÓN 3: Turnos de 60 Minutos (Gaming Intenso)

**Mejor para**: 2 hermanos adolescentes, sesiones de gaming largas

**Comando**:
```bash
timerly gaming_adolescentes
```

**¿Qué pasa?**:
```
18:00:00 - TOMÁS inicia sesión
          (Steam, Lutris, Firefox abiertos)

18:00:00 - 19:00:00 ⏱️ TOMÁS JUGANDO (1 hora)

19:00:00 🔔 ALERTA
         "⏰ Se acabó el turno"
         "¡A descansar 10 minutos!"

19:10:00 - 20:10:00 ⏱️ JAVIER JUGANDO (1 hora)

20:10:00 🔔 ALERTA
         "✅ ¡Todos jugaron!"
         "Fue una buena sesión"
```

---

## 🛠️ Comandos Prácticos para Padres/Madres

### ▶️ Iniciar los Turnos

```bash
# Opción fácil (recomendado)
timerly turnos_hermanos

# Opción personalizada (si quieres cambiar el mensaje)
timerly turnos_hermanos -m "⏰ Le toca a Diego ahora"
```

### 🕐 Ver Quién Está Jugando Ahora

```bash
timerly -s
```

**Muestra**:
```
🟢 Timer ACTIVO (PID: 12345)
   ⏱️  Intervalo: 45m
   🔁 Repeticiones: 3
   💬 Mensaje: '⏰ ¡CAMBIO DE TURNO! El próximo hermano puede conectarse'
   📱 Aplicaciones activas:
      • steam
      • minecraft
      • firefox
```

### 🛑 Pausar/Detener los Turnos

```bash
# Si necesitas interrumpir (almuerzo, emergencia, etc.)
timerly -k

# Muestra confirmación:
# 🛑 Timer detenido
```

### 📊 Ver Estadísticas de Uso

```bash
timerly --stats
```

**Muestra un resumen como**:
```
╔════════════════════════════════════════════════════════╗
║         📊 HISTORIAL DE APLICACIONES EJECUTADAS       ║
╠════════════════════════════════════════════════════════╣

✅ PID:1234 | steam | 12-28 14:00:15 → 14:45:30 | 45:15m
✅ PID:1235 | minecraft | 12-28 15:00:10 → 15:45:20 | 45:10m
✅ PID:1236 | steam | 12-28 16:00:15 → 16:45:30 | 45:15m

📱 Aplicaciones ejecutadas: 3
⏱️  Tiempo total ejecutado: 135:40m
╚════════════════════════════════════════════════════════╝
```

**Útil para verificar**: Quién jugó cuánto tiempo, si hubo manipulaciones, etc.

---

## 💡 Escenarios Reales y Soluciones

### Escenario 1: Necesito Interrumpir en Medio de un Turno

**Problema**: Se debe ir a almorzar en 20 minutos, pero está en mitad de su turno de 45 min

**Solución**:
```bash
# Opción A: Esperar a que termine el turno
timerly -s  # Ver cuánto falta

# Opción B: Parar ahora y empezar de nuevo después
timerly -k
# Más tarde...
timerly turnos_hermanos
```

### Escenario 2: Quiero Que Solo Diego Juegue Hoy

**Problema**: Solo tengo un hijo disponible, no necesito sistema de turnos

**Solución**:
```bash
# Un único turno de 45 minutos
timerly -t 45 -u m -r 1 -m "¡Se acabó el tiempo!" -a "steam,minecraft"
```

### Escenario 3: Son 4 Hermanos, no 3

**Problema**: Los templates son para 3, pero tengo 4 hijos

**Solución**:
```bash
# Opción 1: Cuatro turnos de 45 minutos
timerly -t 45 -u m -r 4 -m "⏰ ¡CAMBIO DE TURNO!" \
              -f "✅ ¡Todos jugaron!" -a "steam,minecraft,firefox"

# Opción 2: Turnos de 30 minutos
timerly -t 30 -u m -r 4 -m "⏰ ¡CAMBIO!" \
              -f "✅ ¡Terminamos!" -a "steam,minecraft"
```

### Escenario 4: Necesito Diferentes Tiempos para Diferentes Días

**Problema**: Lunes a viernes = 20 min (después de la tarea), Fin de semana = 45 min

**Solución**: Crear templates personalizados

```bash
# Crear templates
cp templates/turnos_hermanos.conf templates/turnos_semana.conf
cp templates/turnos_hermanos.conf templates/turnos_fin_semana.conf

# Editar:
nano templates/turnos_semana.conf      # Cambiar a 20 minutos
nano templates/turnos_fin_semana.conf  # Dejar en 45 minutos

# Usar según el día:
timerly turnos_semana          # Entre semana
timerly turnos_fin_semana      # Fin de semana
```

---

## 📈 Usando Estadísticas para Educar

Las estadísticas pueden usarse para enseñar a los hijos sobre:

### ✅ Equidad
```bash
timerly --stats | grep "Tiempo total"
# Muestra: "⏱️  Tiempo total ejecutado: 135:40m"
# Verificar: Cada uno jugó ~45 minutos (equitativo)
```

### 🎯 Responsabilidad
"Mira, esto registra exactamente cuándo juegas y por cuánto tiempo. No hay discusión posible."

### 📊 Datos
"Jugaste 45:15 minutos, tu hermano 45:10 minutos. Todos equitativos. ✓"

---

## 🎯 Mejores Prácticas para Padres/Madres

| Práctica | Descripción | Beneficio |
|----------|-------------|-----------|
| **Consistencia** | Usa el mismo horario diario | Los hijos lo esperan y respetan |
| **Mensajes claros** | "¡Cambio de turno!" no "Algo" | Evita ambigüedad y peleas |
| **Apps monitoreadas** | Incluye todas las apps de juego | Asegura que cierren todo |
| **Descansos** | 5-10 min entre turnos | Permiten que guarden y desconecten |
| **Revisión semanal** | `timerly --stats` | Detecta si alguien manipula |
| **Flexibilidad** | Permite excepciones ocasionales | Mantiene la confianza |

---

## 🔒 Protecciones Integradas

**¿Qué pasa si intentan burlar el sistema?**

1. **No pueden cambiar el tiempo**: Solo el administrador puede usar Timerly
2. **Queda registrado**: Cada sesión se registra en `~/timerly.log`
3. **Estadísticas auditables**: `timerly --stats` muestra exactamente cuándo jugaron
4. **Única instancia**: No pueden abrir múltiples timers para tener más tiempo

---

## 🚀 Próximos Pasos

1. **Instala Timerly**: Sigue las instrucciones en README.md
2. **Crea tu configuración**: Edita `timer_defaults.conf` con tus horarios
3. **Prueba un turno**: `timerly turnos_hermanos`
4. **Enseña a los hijos**: Muéstrales cómo funciona
5. **Monitorea regularmente**: `timerly --stats` una vez a la semana

---

## ❓ Preguntas Frecuentes

**P: ¿Qué pasa si un hijo no quiere darle el computador al siguiente?**
A: El sistema solo avisa. Los límites deben establecerse en casa (ej: apagar PC, confiscar teclado, etc.)

**P: ¿Puedo cambiar los tiempos después de iniciar?**
A: No durante el turno activo. Debes parar (`timerly -k`) e iniciar uno nuevo.

**P: ¿Funciona si están todos en el mismo usuario de Linux?**
A: Sí, Timerly controla las aplicaciones que abre, no el usuario.

**P: ¿Qué pasa si apagan la PC antes de que termine?**
A: Las estadísticas registran cuándo se cerraron las aplicaciones. Tú puedes ver si fue antes de lo esperado.

**P: ¿Puedo usar esto también para controlar mi propio tiempo de trabajo?**
A: ¡Claro! Úsalo como técnica Pomodoro con `timerly pomodoro`.

---

**¿Necesitas ayuda?** Ejecuta `timerly -h` para ver todos los comandos disponibles.
