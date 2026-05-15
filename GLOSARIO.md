# Glosario del curso

Terminología canónica. Cuando dos términos compiten, gana el que aparece como **forma preferente**. Las formas alternativas se aceptan al leer pero no se usan al redactar.

## Modelos y arquitectura

- **LLM** (*Large Language Model*). Modelo de lenguaje grande. Predice el siguiente token a partir del contexto.
- **Token.** Unidad mínima que procesa un LLM. ~4 caracteres en inglés, ~3 en español. La facturación y el límite de contexto se miden en tokens.
- **Contexto.** Toda la información que el modelo "ve" en una llamada: system prompt + historial + mensaje del usuario + (opcional) datos recuperados.
- **System prompt.** Instrucción de alto nivel que define el rol y las reglas del modelo. Se envía con el rol `system`.
- **Temperatura.** Parámetro entre 0 y 2 que regula la aleatoriedad de la respuesta. 0 ≈ determinista, 1 ≈ creativo.
- **Embedding.** Vector de números reales que representa un texto en un espacio semántico. Textos parecidos producen vectores cercanos.
- **Ventana de contexto.** Tamaño máximo de tokens que el modelo puede procesar en una llamada. Varía según modelo (8K–1M).
- **Alucinación.** Forma preferente. Respuesta del modelo que afirma con seguridad información falsa, normalmente porque el modelo no tiene los datos pero sí ha aprendido a producir texto plausible sobre el tema.
- **Fecha de corte** (*knowledge cutoff*). Forma preferente. Fecha hasta la que el modelo fue entrenado. Información posterior a esa fecha no la conoce; intentar obtenerla suele provocar alucinación.
- **No determinismo.** Propiedad de los LLM con `temperature > 0`: dos llamadas con la misma entrada pueden devolver respuestas distintas. Implica que los tests basados en igualdad textual no son fiables sin fijar la temperatura.

## RAG y datos

- **RAG** (*Retrieval Augmented Generation*). Forma preferente. Patrón que recupera fragmentos relevantes de una base de conocimiento y los inyecta en el prompt antes de generar la respuesta.
- **Base vectorial.** Forma preferente (frente a *vector store*). Sistema que almacena embeddings y permite búsquedas por similaridad. En el curso: PGVector sobre PostgreSQL.
- **Chunk.** Forma preferente (frente a *fragmento*). Trozo de texto sobre el que se calcula un embedding. Es el término que usan los frameworks.
- **Chunking.** Proceso de partir un documento en chunks.
- **Similaridad coseno.** Medida de cercanía entre dos vectores. Va de -1 a 1; cerca de 1 indica textos semánticamente parecidos.
- **K (top-K).** Número de chunks recuperados en una búsqueda vectorial.
- **Solapamiento (*overlap*).** Tokens compartidos entre chunks consecutivos para evitar perder contexto en los bordes.

## Agentes

- **Tool use.** Forma preferente (frente a *function calling*, que es sinónimo). Capacidad del modelo de decidir cuándo llamar a funciones del sistema con argumentos estructurados.
- **Tool.** Función expuesta al modelo, con nombre, descripción y esquema de parámetros.
- **ReAct** (*Reason + Act*). Bucle de razonamiento: el modelo piensa, decide una acción (tool), observa el resultado, y repite hasta resolver la tarea.
- **Agente.** Sistema que combina LLM + tools + memoria + bucle ReAct para resolver tareas multi-paso.
- **MCP** (*Model Context Protocol*). Protocolo abierto que estandariza cómo un LLM accede a tools y recursos externos. Sustituye al tool use propietario por una interfaz común.
- **Servidor MCP.** Proceso que expone tools y recursos siguiendo el protocolo.
- **Cliente MCP.** Proceso que consume tools de un servidor MCP (el agente, otro LLM…).

## Salidas y evaluación

- **Salida estructurada.** Forma preferente (frente a *structured output*). Respuesta del modelo conforme a un esquema (JSON Schema, POJO).
- **LLM-as-a-judge.** Patrón que usa un LLM para evaluar la calidad de la respuesta de otro LLM. En el curso, `qwen2.5:32b-instruct` en la RTX 3090 actúa como juez. Es un modelo distinto al generador (`gemini-2.5-flash`) para evitar sesgo de auto-evaluación.
- **Faithfulness.** Métrica RAG: en qué medida la respuesta se apoya en el contexto recuperado y no en conocimiento previo del modelo.
- **Precisión@K.** Métrica RAG: porcentaje de los K chunks recuperados que son relevantes para la pregunta.

## Seguridad

- **Prompt injection (directo).** Forma preferente. Ataque en el que el usuario inyecta instrucciones que tratan de sobreescribir el system prompt.
- **Indirect prompt injection.** Forma preferente. Variante en la que las instrucciones maliciosas vienen de contenido recuperado por el sistema (un PDF subido, un resultado web).
- **Mínimo privilegio.** Principio: una tool sólo expone los datos y operaciones estrictamente necesarios.
- **Sanitización.** Filtrado de la entrada o del contexto recuperado antes de pasarlo al modelo.

## Streaming y APIs

- **SSE** (*Server-Sent Events*). Mecanismo HTTP de envío unidireccional del servidor al cliente. Lo usa Spring AI para streaming de tokens.
- **Streaming.** Envío progresivo de la respuesta del LLM token a token, antes de tenerla completa.
- **Tokens/s.** Métrica de velocidad de generación. `gemini-2.5-flash` ronda 150–250 t/s vía API; un modelo `7b` en RTX 3090 ronda 80–120 t/s; un `32b` cuantizado en la misma GPU baja a 20–35 t/s; en CPU pura un `7b` cae a 20–40 t/s.

## Routing

- **ModelRouter.** Bean del proyecto StudyMate que recibe un `TaskType` y devuelve el `ChatClient` adecuado. Centraliza las decisiones de routing.
- **TaskType.** Enum del proyecto: `CHAT_SIMPLE`, `RAG`, `TOOL_USE`, `STRUCTURED`, `JUDGE`, `EMBEDDING`. Cada valor mapea a un modelo concreto en `ROUTING.md`.
