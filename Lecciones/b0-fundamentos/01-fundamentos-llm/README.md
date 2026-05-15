# Lección 01 · Fundamentos de los LLM

> **Bloque:** B0 · Fundamentos
> **Duración estimada:** 4 h
> **Modelo principal:** Gemini · `gemini-2.5-flash` (cuota gratuita generosa, sin infraestructura local, modelo del que dependerán las lecciones de RAG y agentes)
> **Tag git de partida:** `inicial` (estado del repositorio antes de empezar el curso).
> **Tag git de llegada:** `inicial` (esta lección no modifica `studymate/`: introduce conceptos y experimentos sueltos. La siguiente lección parte del mismo tag.)

Primer contacto con un LLM. Antes de escribir una sola línea de Java, antes de Spring AI: entiendes qué es un modelo de lenguaje, cómo se le habla por HTTP, qué es la temperatura, qué significa que tenga una *fecha de corte*, y qué riesgos asumes cuando le envías información. Cierras la lección con una API key de Gemini en tu sistema y la primera petición real respondida.

## Objetivos

- Definir operativamente qué es un LLM y qué hace en una llamada.
- Crear una cuenta en Google AI Studio y obtener una API key personal de Gemini.
- Configurar `GEMINI_API_KEY` como variable de entorno de tu sistema y usarla desde `curl` y desde Bruno.
- Observar el efecto de la temperatura sobre la respuesta y cuándo conviene cada valor.
- Reconocer las dos limitaciones que más impactan al diseñar un producto: **no determinismo** y **fecha de corte**.
- Identificar tres riesgos de seguridad típicos: filtración de API key, envío de PII (Personally Identifiable Information), retención de datos y mitigarlos antes de seguir.

## Conceptos clave

### LLM, en una frase práctica

Una caja a la que le mandas texto y te devuelve texto. Por dentro es un modelo de redes neuronales entrenado para predecir el siguiente *token* dado lo anterior; eso es todo lo que sabe hacer. Todo lo demás (responder preguntas, escribir código, traducir) emerge de hacer esa predicción muchas veces seguidas sobre una entrada bien construida. Definiciones canónicas en [`GLOSARIO.md`](../../../GLOSARIO.md).

### Token, contexto y ventana de contexto

- **Token.** Pieza mínima que el modelo procesa. ~3 caracteres en español. Ni la facturación ni el límite del modelo cuentan caracteres ni palabras: cuentan tokens.
- **Contexto.** Todo lo que el modelo "ve" en una llamada: tu mensaje + (cuando los haya) historial + system prompt + datos recuperados.
- **Ventana de contexto.** Límite máximo de tokens que el modelo acepta en una llamada. `gemini-2.5-flash` admite ~1 000 000 de tokens; `llama3.1:8b` se queda en 128 000. Cuando cierras una conversación larga sin gestión de historial, no es magia: es un buffer.

### Temperatura

Parámetro entre 0 y 2 que regula cuánta aleatoriedad mete el modelo al elegir el siguiente token. Aproximaciones útiles:

- `0.0` → respuesta lo más determinista posible. Ideal para extraer datos, generar JSON, responder a preguntas con respuesta única.
- `0.7`–`1.0` → respuesta variada pero coherente. Ideal para chat conversacional.
- `1.5`–`2.0` → respuesta creativa, a veces incoherente. Ideal para *brainstorming* o ficción; pésimo para producción.

### Fecha de corte

Los pesos del modelo se entrenan hasta una fecha y se congelan. Todo lo posterior **el modelo no lo sabe**. Si le preguntas, puede:

- Reconocer que no tiene esa información (caso bueno).
- Inventar una respuesta plausible que es falsa (*alucinación*).

`gemini-2.5-flash` tiene fecha de corte ~enero 2025 según Google. Esa fecha y sus consecuencias las exploras a fondo en la avanzada A.

### No determinismo

Con `temperature > 0`, **dos llamadas idénticas pueden devolver respuestas distintas**. Eso rompe asunciones clásicas de software:

- Tests basados en igualdad de cadenas: no funcionan.
- Cacheado por hash del input: cuestionable.
- Reproducibilidad de un *bug*: difícil sin congelar la temperatura.

Lo verás en directo en el laboratorio guiado.

## Punto de partida

Si haces `git checkout inicial` ves el repositorio del curso recién forkeado: los `.md` de la raíz, la carpeta `programacion/` con las lecciones, las plantillas y las guías. **No existe** la carpeta `studymate/` (se crea en la lección 03). Tampoco hay variables de entorno configuradas en tu sistema. Lo único que necesitas para esta lección es:

- Una cuenta de Google personal o de centro educativo.
- [Bruno](https://www.usebruno.com/) instalado (ya lo usaremos en todo el curso).
- `curl` disponible en terminal (en Windows viene con Git Bash y con PowerShell 5+).

## Demo guiada

### Paso 1 · Crear la API key de Gemini

1. Entra en [aistudio.google.com](https://aistudio.google.com/) e inicia sesión con tu cuenta de Google.
2. Acepta los términos de uso para desarrolladores. La cuenta del centro vale; la cuenta personal también.
3. Pulsa **Get API key → Create API key in new project**. Google te muestra una cadena del estilo `AIzaSy...` de 39 caracteres.
4. **Cópiala una vez y guárdala en lugar seguro.** Si se te olvida, no se puede recuperar: hay que regenerarla.

### Paso 2 · Configurarla como variable de entorno

En **Windows (PowerShell)**, de forma persistente:

```powershell
[Environment]::SetEnvironmentVariable("GEMINI_API_KEY", "AIzaSy...tu-clave...", "User")
```

Cierra y reabre la terminal (y el IDE) para que la lea.

En **Linux/macOS**, añade al final de `~/.bashrc` o `~/.zshrc`:

```bash
export GEMINI_API_KEY="AIzaSy...tu-clave..."
```

Y luego `source ~/.bashrc` o reabre la terminal. Verifica con `echo $GEMINI_API_KEY` (Linux/macOS) o `echo $env:GEMINI_API_KEY` (PowerShell). Debe imprimir tu clave; si imprime vacío, no la ha cargado.

### Paso 3 · Primera llamada con `curl`

```bash
curl "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent" \
  -H "Content-Type: application/json" \
  -H "x-goog-api-key: $GEMINI_API_KEY" \
  -d "{\"contents\":[{\"parts\":[{\"text\":\"Explícame qué es un LLM en dos frases\"}]}]}"
```

> OJO: Hay que ejecutarlo desde un terminal `git bash` o de `WSL`

Pasamos la API key por **header**, no por query string `?key=...`. El motivo: las URLs aparecen en logs de proxies, en el historial del shell y en herramientas de monitorización; los headers no.

La respuesta es un JSON con un campo `candidates[0].content.parts[0].text`. Esa es la respuesta del modelo.

### Paso 4 · La misma llamada con Bruno

Abre [`recursos/bruno/`](./recursos/bruno/) en Bruno, selecciona el entorno `local` y lanza `gemini-hola-mundo`. Debes ver el mismo JSON, pero formateado y navegable. Mantendremos Bruno como herramienta principal para el resto del curso.

### Verificación

Lanza tres veces seguidas `gemini-hola-mundo` con la temperatura por defecto. Compara las tres respuestas:

- El significado se mantiene.
- Las palabras concretas y el orden cambian.

Eso es **no determinismo en directo**. No es un bug.

## Laboratorio guiado

### Enunciado

Compara la misma pregunta lanzada con `temperature: 0.0` y con `temperature: 1.5`, tres ejecuciones de cada una. Anota qué cambia y qué se mantiene. Ya tienes ambas peticiones preparadas en la colección Bruno (`gemini-temperatura-baja` y `gemini-temperatura-alta`).

### Pasos

1. Lanza `gemini-temperatura-baja` tres veces seguidas. Copia las tres respuestas a un editor de texto.
2. Lanza `gemini-temperatura-alta` tres veces seguidas. Copia las tres respuestas.
3. Anota: con `0.0`, ¿son idénticas las tres? ¿Casi idénticas? ¿Distintas? ¿Y con `1.5`?
4. Lanza `gemini-fecha-corte`, que pregunta por un evento de 2025 o posterior. Anota si el modelo reconoce no saberlo o si se lo inventa.

### Resultado esperado

- Con `temperature: 0.0` las tres respuestas son idénticas o casi idénticas (palabra por palabra).
- Con `temperature: 1.5` el contenido sigue siendo coherente pero el orden, los ejemplos y las palabras cambian sustancialmente.
- En `gemini-fecha-corte`, lo más habitual con `gemini-2.5-flash` es que el modelo declare honestamente no tener información de esa fecha. Si en cambio se inventa un evento concreto, has visto tu primera **alucinación**.

## Seguridad

🔒 **Tu API key es un secreto con valor económico.** Si se filtra a un repositorio público, bots de scraping la encuentran en minutos y la usan hasta agotar tu cuota o cargarla a tu cuenta. Reglas no negociables:

- **Nunca** commitees la clave en el repo. Vive en `GEMINI_API_KEY`, una variable de entorno de tu sistema. No en `application.yml`. No en un `.env` versionado. No en un comentario "temporal".
- Si por accidente subes la clave (en cualquier rama, incluso en una eliminada después): considérala comprometida. Ve a AI Studio, **revócala** y genera otra. El historial de Git es para siempre.
- En este curso `GEMINI_API_KEY` aparece en `application.yml` siempre con la sintaxis `${GEMINI_API_KEY}`, que Spring resuelve en tiempo de arranque desde la variable de entorno.

🔒 **Lo que envías al modelo no es privado.** Google procesa tu petición en sus servidores. Lee la [política de uso de datos de Gemini API](https://ai.google.dev/gemini-api/terms) antes de mandarle nada. Reglas mínimas para este curso:

- **No envíes PII real**: nombres, DNIs, correos, datos académicos identificables. Si necesitas datos de prueba, invéntalos.
- **No envíes apuntes confidenciales** del centro ni material protegido por derechos de autor de tus profesores sin permiso.
- **No envíes credenciales de ningún sistema**, ni para que el modelo "te ayude a entender el error". El modelo no necesita ver la contraseña para explicarte el error.

🔒 **Cuotas y abuso.** El tier gratuito de Gemini tiene límites por minuto y por día. Si te excedes, el modelo devuelve `429 Too Many Requests`. No es un bug ni un fallo de tu código. Espera y vuelve a probar; o, si trabajas en grupo, distribuye llamadas.

## Estado del proyecto al terminar

- **Tag:** `inicial` (esta lección no añade código a `studymate/`).
- **Cambios introducidos en tu entorno (no en el repo):**
  - Cuenta de Google AI Studio activa con una API key personal.
  - Variable de entorno `GEMINI_API_KEY` configurada y persistente.
  - Bruno instalado y abriendo la colección de la lección.
- **Cambios en tu rama de trabajo (`lec-01/<tu-usuario>`):**
  - `INFORME-L01.md` en la raíz del repo con los resultados de la actividad obligatoria.
- **Dependencias añadidas:** ninguna. Aún no hay `pom.xml`.
- **Variables de entorno requeridas:** `GEMINI_API_KEY`.

## Actividades

Las actividades de esta lección están en [`actividades.md`](./actividades.md). Resuélvelas antes de pasar a la lección 02.

## Errores frecuentes

- *`curl` devuelve `403 Forbidden` o `API key not valid`.* **Causa:** la variable `GEMINI_API_KEY` está vacía (no se cargó) o la copiaste con espacios al inicio o al final. **Solución:** vuelve a comprobarla con `echo`. En PowerShell, las variables fijadas con `SetEnvironmentVariable` sólo aparecen en terminales **nuevas**.
- *`429 Too Many Requests` en pleno laboratorio.* **Causa:** la cuota gratuita por minuto está saturada (toda la clase llamando a la vez). **Solución:** espera 60 segundos. No regeneres la API key: no es un problema de credenciales.
- *Bruno responde `Network Error` sin más detalle.* **Causa:** el entorno seleccionado no tiene `geminiApiKey` resuelta porque tu Bruno no está leyendo `process.env`. **Solución:** abre la pestaña *Environments* en Bruno y comprueba que `geminiApiKey` se resuelve. Si no, edita el entorno y pega tu clave directamente, marcándola como *secret* para que Bruno no la guarde en disco junto al `.bru` versionado.
- *El modelo me cuenta detalles de un evento de 2025 muy concreto y muy convencido.* **Causa esperada:** alucinación. **No es un error**: es el material de la avanzada A.

## Recursos y referencias

- [`recursos/bruno/`](./recursos/bruno/): cuatro peticiones de la demo y del laboratorio.
- Documentación de [Gemini API · Generate content](https://ai.google.dev/api/generate-content).
- [OWASP LLM Top 10](https://genai.owasp.org/llm-top-10/) — lectura recomendada para el bloque de seguridad.
- [GLOSARIO del curso](../../../GLOSARIO.md): definiciones canónicas de token, contexto, temperatura, alucinación.
