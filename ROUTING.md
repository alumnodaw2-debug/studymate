# Routing de modelos

Tabla canónica de qué modelo usa cada tarea del curso y por qué. Cualquier lección que use un modelo distinto al recogido aquí debe justificarlo expresamente.

## Infraestructura disponible

- **Servidor del centro con RTX 3090 (24 GB VRAM).** Ejecuta Ollama con varios modelos cargados simultáneamente. Accesible desde el aula vía red interna. Permite modelos `7B`–`14B` cuantizados con holgura, y `qwen2.5:32b-instruct-q4_K_M` (~20 GB VRAM) como modelo grande de razonamiento para evaluación.
- **Google AI Studio (Gemini).** Cada alumno con su propia API key gratuita en [aistudio.google.com](https://aistudio.google.com/). Modelo `gemini-2.5-flash`. Starter `spring-ai-starter-model-google-genai`. Variable de entorno `GEMINI_API_KEY`.

## Tabla de routing

| `TaskType` | Tarea | Modelo | Proveedor | Por qué |
|---|---|---|---|---|
| `CHAT_SIMPLE` | Chat básico, demo, pruebas locales | `llama3.1:8b-instruct-q8` | Ollama (centro) | Calidad suficiente, latencia baja en RTX 3090, coste cero. |
| — | Taller de prompt engineering | `qwen2.5:7b` | Ollama (centro) | Buen seguimiento de instrucciones; ideal para taller experimental. |
| — | Generación de código en IDE (Copilot) | El que use el IDE del alumno | Externo | Fuera del scope de `ModelRouter`. |
| `EMBEDDING` | Embeddings de documentos | `nomic-embed-text` | Ollama (centro) | Embeddings de calidad razonable, rápidos en GPU, coste cero. |
| `RAG` | Generación con contexto recuperado | `gemini-2.5-flash` | Gemini | Razonamiento sobre contexto largo; los modelos `7B`–`8B` fallan en síntesis multi-chunk. Tier gratuito viable. |
| `TOOL_USE` | Tool use / function calling | `gemini-2.5-flash` | Gemini | Tool use fiable con esquemas medianamente complejos; los modelos pequeños alucinan parámetros. |
| `STRUCTURED` | Salida estructurada compleja | `gemini-2.5-flash` | Gemini | Respeta JSON Schema con consistencia. |
| `JUDGE` | Evaluación (LLM-as-a-judge) | `qwen2.5:32b-instruct-q4_K_M` | Ollama (centro) | Distinto al generador (Gemini) para evitar sesgo de auto-evaluación. Razonamiento muy superior a un `8B` en RTX 3090, coste cero. |
| — | Búsqueda web complementaria al agente | `gemini-2.5-flash` | Gemini | Mismo motor de razonamiento que orquesta el resultado web. |

## Reglas de fallback

- **Ollama no responde** (timeout > 3 s al primer token) en `CHAT_SIMPLE`: pasa a `gemini-2.5-flash` con el mismo prompt. El header `X-Model-Used` debe reflejar el cambio.
- **Ollama no responde en `JUDGE`:** marcar la respuesta como *no evaluada* en lugar de caer a Gemini. El juez debe ser de proveedor distinto al generador; si caemos a Gemini, la evaluación deja de ser fiable y la métrica cambia silenciosamente.
- **Gemini devuelve rate limit:** *backoff* exponencial y reintento. **No caer a Ollama silenciosamente** para tareas `RAG`, `TOOL_USE` o `STRUCTURED`: la calidad cambia y el alumno debe percibirlo. Mostrar el motivo del fallo en la respuesta o en el header.

## Cómo se materializa en código

Existe un bean `ModelRouter` en `studymate/` que recibe un `TaskType` y devuelve el `ChatClient` correspondiente. La configuración real vive en `application.yml` por perfiles (`local` para todo lo de Ollama, `gemini` para Gemini), no hardcoded.

```java
@Service
public class ModelRouter {
    private final Map<TaskType, ChatClient> clientes;
    public ChatClient getCliente(TaskType tarea) {
        return clientes.get(tarea);
    }
}
```

## Cuándo revisar este documento

- Cuando aparezca un modelo nuevo relevante (Llama 4, Qwen 3, Gemini 2.x…).
- Cuando los costes o las cuotas cambien.
- Cuando se detecte en clase que un modelo del routing rinde por debajo de lo esperado para una tarea concreta.

Cualquier cambio aquí implica revisar las lecciones afectadas para mantener coherencia.
