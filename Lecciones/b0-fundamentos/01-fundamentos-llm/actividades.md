# Actividades · Lección 01 · Fundamentos de los LLM

> **Lección asociada:** [`README.md`](./README.md)
> **Tag git de partida:** `inicial` (al terminar la demo y el laboratorio guiado).
> **Tiempo estimado obligatorio:** 45 min.
> **Tiempo estimado avanzado:** 1 h 30 min adicionales.

Una actividad obligatoria que asegura que dominas la API de Gemini desde Bruno, entiendes el efecto de la temperatura y reconoces respuestas no deterministas. Dos actividades avanzadas opcionales para profundizar en alucinaciones, fecha de corte y comparación entre modelos de una misma familia.

## Cómo se evalúa

- **Actividad obligatoria:** evaluación binaria por criterio. Si cumples todos los criterios, la lección queda superada con un **10** sobre 10.
- **Actividades avanzadas (opcionales):** cada una suma **+0,5 puntos** sobre la nota base. Sólo cuentan si la obligatoria está superada.

Para el flujo git y el formato de entrega, consulta [`GUIA-ALUMNO.md`](../../../../GUIA-ALUMNO.md).

## Entrega

- **Formato:** rama `lec-01/<tu-usuario>` en tu repo del curso. Pull request al `main` de tu propio repo.
- **Plazo:** antes del inicio de la lección 02.
- **Contenido del PR:** `INFORME-L01.md` en la raíz del repo. (Esta lección no toca código Java; sólo añadirás el informe.)

---

## Actividad obligatoria · Catálogo de cinco preguntas a dos temperaturas

**Tiempo estimado:** 45 min

### Enunciado

Diseña **cinco preguntas** a Gemini que cubran cinco tipos de tarea distintos:

1. **Hechos verificables** (p. ej. *"¿En qué año se introdujeron los `record` en Java?"*).
2. **Razonamiento** (p. ej. *"Si tengo 10 millones de elementos y necesito búsqueda O(1), ¿qué estructura uso y por qué?"*).
3. **Generación de código** (p. ej. *"Escribe en Java un método que valide un IBAN español"*).
4. **Tarea creativa** (p. ej. *"Escribe un haiku sobre el `garbage collector` de la JVM"*).
5. **Cálculo numérico** (p. ej. *"¿Cuántos segundos hay en un año bisiesto? Razona el cálculo paso a paso."*).

Lanza cada pregunta **dos veces**: una con `temperature: 0.0` y otra con `temperature: 1.5`. Documenta las 10 respuestas en `INFORME-L01.md` con la siguiente estructura por pregunta:

```markdown
### Pregunta N · <tipo>
- Texto: ...
- Respuesta con `temp=0.0`: ...
- Respuesta con `temp=1.5`: ...
- Observación: una frase sobre qué cambia entre las dos respuestas.
```

Cierra el informe con una **conclusión personal** (~10 líneas) sobre qué temperatura recomendarías para cada uno de los cinco tipos de tarea, razonando.

### Criterios de evaluación

- [ ] `INFORME-L01.md` existe en la raíz del repo y tiene las cinco preguntas con los cinco tipos de tarea distintos.
- [ ] Cada pregunta se ha lanzado a las dos temperaturas; las dos respuestas literales aparecen transcritas.
- [ ] La sección *Observación* de cada pregunta no se limita a "son distintas": describe **qué** cambia (longitud, ejemplos, orden, exactitud).
- [ ] La conclusión recomienda una temperatura por tipo de tarea y la justifica en una frase. Las cinco temperaturas no pueden ser la misma; debe haber al menos dos valores distintos en el conjunto.
- [ ] Ninguna pregunta contiene PII ni datos confidenciales (revisa antes de lanzarla; revisa otra vez antes de commitear).

### Pistas

- Para cambiar la temperatura desde Bruno, abre la petición y modifica el campo `generationConfig.temperature` del body. Las dos peticiones de la demo (`gemini-temperatura-baja` y `gemini-temperatura-alta`) ya tienen los valores fijados; duplica una de ellas y ajusta.
- Si una pregunta de cálculo numérico te da resultados distintos en las dos temperaturas, **no asumas que la de `temp=0` es la correcta**. Verifica con calculadora.
- Documentar la respuesta literal incluye los errores. No corrijas. La gracia de la actividad es ver lo que ocurre, no lo que debería ocurrir.

---

## Actividades avanzadas (opcionales)

> Cada actividad superada suma +0,5 puntos sobre la nota base de la lección. No las hagas si la obligatoria no está cerrada.

### Avanzada A · Cazar la fecha de corte

**Tiempo estimado:** 45 min
**Bonus:** +0,5 puntos

#### Enunciado

Determina empíricamente cuál es la **fecha de corte** efectiva de `gemini-2.5-flash` y documenta al menos **una alucinación clara** que provoque preguntar por información posterior a esa fecha.

Procedimiento sugerido:

1. Pregunta al modelo por un evento conocido público de cada uno de los últimos doce meses (uno por mes), de más reciente a más antiguo. Mantén `temperature: 0.0`.
2. Anota para cada uno: ¿el modelo lo conoce con detalles correctos? ¿Lo desconoce y lo declara? ¿Inventa detalles?
3. Identifica el mes en el que el comportamiento cambia: la fecha de corte aproximada del modelo.
4. Diseña al menos **una pregunta** que provoque al modelo a inventarse información (típicamente, pedirle datos muy concretos sobre un evento posterior a la fecha de corte). Documenta la respuesta inventada y por qué sabes que es falsa.

Documenta el procedimiento, los resultados mes a mes y la alucinación cazada en `INFORME-FECHA-CORTE.md` en la raíz del repo. Cierra con una reflexión: **¿cómo afecta una fecha de corte de hace N meses al diseño de un tutor de programación?** ¿Qué partes del módulo (Java, Spring, JPA, librerías externas) envejecen más rápido?

#### Criterios de evaluación

- [ ] `INFORME-FECHA-CORTE.md` existe con la tabla mes a mes.
- [ ] La fecha de corte estimada está justificada con datos: al menos un evento *anterior* que el modelo conoce y un evento *posterior* que desconoce o inventa.
- [ ] Hay al menos una alucinación documentada con el texto literal del modelo y la prueba (enlace, cita) de que es falsa.
- [ ] La reflexión final menciona explícitamente al menos un riesgo concreto para un tutor educativo (versiones de librerías, sintaxis nueva del lenguaje, vulnerabilidades recientes…).

#### Pistas

- Eventos públicos verificables: lanzamientos de versiones del JDK, releases mayores de Spring Boot, conferencias técnicas (Google I/O, JavaOne…), eventos deportivos de gran difusión.
- Cuanto más concreto sea el detalle que pides, más probable es que el modelo alucine cuando no sabe. *"¿Qué pasó en el JavaOne de mayo de 2025?"* es mejor cebo que *"¿Qué pasó en 2025?"*.
- Si te quedas sin cuota antes de cubrir 12 meses, prioriza los meses cercanos al cambio: 6–8 meses recientes son suficientes para localizar la fecha de corte.

---

### Avanzada B · `flash` vs `flash-lite`: el coste de la calidad

**Tiempo estimado:** 45 min
**Bonus:** +0,5 puntos
**Requiere:** la actividad obligatoria terminada (las cinco preguntas reutilizables).

#### Enunciado

Compara `gemini-2.5-flash` con `gemini-2.5-flash-lite` (o el modelo equivalente más barato disponible en AI Studio en el momento de hacer la lección) sobre las cinco preguntas de la actividad obligatoria. Lanza cada pregunta **dos veces** contra cada modelo (`temperature: 0.0`) y documenta:

- Tiempo de respuesta percibido (Bruno lo muestra en el panel de respuesta).
- Calidad subjetiva en escala 1–5 con una frase de justificación.
- Diferencias observables: longitud, exactitud factual, calidad del código generado.

Cierra con una conclusión: **¿en qué tipo de pregunta el modelo `lite` es suficiente, y en cuál no?** ¿Qué implicaciones tendría usar `lite` en producción para un tutor educativo, en términos de coste y de calidad?

#### Criterios de evaluación

- [ ] `INFORME-FLASH-VS-LITE.md` existe en la raíz del repo con una tabla comparativa de las 5 preguntas × 2 modelos.
- [ ] La calidad subjetiva está justificada por pregunta, no asignada al azar.
- [ ] La conclusión identifica al menos un tipo de pregunta donde `lite` basta y al menos uno donde no.
- [ ] La conclusión menciona el coste por millón de tokens de cada modelo (consultable en la documentación oficial de Google al hacer la actividad) y razona el *trade-off*.

#### Pistas

- En Bruno, duplica el archivo `gemini-temperatura-baja.bru`, cambia el modelo en la URL (`gemini-2.5-flash` → `gemini-2.5-flash-lite`) y guárdalo como `gemini-lite-prueba.bru`.
- "Tiempo de respuesta percibido" no es una métrica fina; sirve para órdenes de magnitud. Si quieres ser preciso, usa el reloj del sistema antes y después.
- El coste por millón de tokens lo publica Google en la página de pricing; cambia con el tiempo. Apunta la fecha de consulta en el informe.

---

## Para la siguiente lección

Antes de empezar la lección 02 debes tener:

- `GEMINI_API_KEY` configurada y funcionando desde Bruno y desde `curl`.
- `INFORME-L01.md` en la raíz del repo + (opcional) `INFORME-FECHA-CORTE.md` y/o `INFORME-FLASH-VS-LITE.md`.
- Tu PR `lec-01/<tu-usuario>` abierta contra el `main` de tu propio repo.
- Las dudas que no hayas resuelto, escritas para preguntar al inicio de la siguiente sesión.
