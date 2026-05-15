# Guía de estilo del curso

Fuente de verdad sobre cómo se redactan los apuntes, las actividades y el código del curso. Cualquier sesión agéntica debe leer este archivo antes de editar contenido.

## Voz y registro

- **Tuteo.** Habla al alumno en segunda persona del singular: *"crea un endpoint"*, *"abre Bruno y prueba"*. Nunca *"se crea"* ni *"el alumno debe"*.
- **Registro técnico-cercano.** Directo, sin paternalismo. El alumno es de 2º curso y ya programa Java y JPA.
- **Sin adjetivos vacíos.** Prohibido *potente*, *increíble*, *mágico*, *fascinante*. Si algo es relevante, explica por qué; no lo califiques.
- **Justifica decisiones.** Cada vez que tomes una decisión técnica (un modelo, una librería, un patrón), explica por qué con una frase. Si no hay razón, no lo metas.

## Convenciones de Markdown

- **H1** sólo para el título de la lección o documento.
- **H2** para secciones principales; **H3** para subsecciones. No bajar de H3 salvo necesidad.
- **Listas** con `-`, no con `*`.
- **Bloques de código** siempre con etiqueta de lenguaje: ` ```java `, ` ```bash `, ` ```yaml `, ` ```sql `, ` ```http `.
- **Comandos de terminal** una línea por comando, sin `$` ni `>` al inicio.
- **Inline code** para identificadores, rutas, nombres de archivo y comandos cortos.
- **Tablas** sólo cuando aportan claridad; no abusar.

## Uso de iconos

Sólo iconos funcionales, no decorativos:

- 🔒 sección o párrafo de seguridad.
- ⚠️ advertencia técnica relevante.
- 💡 pista u observación útil al margen.

No se usan emojis para "alegrar" párrafos.

## Convenciones Java

### Identificadores de dominio

- **Métodos:** prefijo Java estándar (`get`, `set`, `is`, `has`) + sustantivo en español. Ejemplos: `getApuntes()`, `setNombreTutor()`, `isContextoValido()`, `hasRespuesta()`.
- **Clases de dominio:** sustantivo en español. Ejemplos: `Apunte`, `Pregunta`, `Tema`, `Conversacion`.
- **Variables locales:** español si referencian dominio (`apuntes`, `pregunta`); inglés si son técnicas (`request`, `response`, `client`, `chunk`).

### Sufijos e infraestructura en inglés

- `Repository`, `Service`, `Controller`, `DAO`, `DTO`, `Config`, `Mapper`, `Mapper`, `Router`.
- Ejemplos: `ApunteRepository`, `ApunteService`, `ApunteController`, `ChatRequestDTO`, `ModelRouter`.
- **Paquetes en inglés:** `com.studymate.chat`, `com.studymate.notes`, `com.studymate.rag`, `com.studymate.agent`, `com.studymate.shared`. Las piezas transversales (DTOs comunes como `ErrorResponseDTO`, `@ControllerAdvice` global, utilidades) viven en `shared`. Si una pieza es del dominio de un módulo concreto, va en su paquete y no en `shared`.

### Convenciones Spring

- Anotaciones agrupadas, una por línea sobre la firma.
- Inyección por constructor, nunca por campo.
- **`@Autowired` explícito en el constructor**, aunque sea opcional desde Spring 4.3. Hace visible al alumno que la dependencia llega del contenedor de Spring; la legibilidad pesa más que el ahorro de una línea.
- DTOs como `record` cuando sea posible (Java 21+). No usamos Lombok en el curso: el alumno escribe constructores y `equals`/`hashCode` cuando los necesite, o usa `record` si la pieza es inmutable.
- `@Configuration` separado de la lógica; `@Bean` con nombres explícitos cuando hay más de un candidato del mismo tipo.

## Estructura de una lección

Toda lección sigue el mismo orden de secciones, definido en `programacion/_plantillas/leccion.md`. No reordenes ni inventes secciones nuevas sin actualizar la plantilla y `AGENTS.md`.

## Longitud orientativa

- Lección completa (`README.md`): 200–500 líneas. Más allá, parte en dos lecciones.
- "Conceptos clave": no superar 80 líneas; los detalles van a `GLOSARIO.md`.
- Bloques de código en la demo: si superan 60 líneas, mueve el bloque a `recursos/` y enlaza desde el README.
- Actividades: 5–10 líneas por enunciado. Si necesitas más, divide la actividad en dos.

## Nomenclatura de archivos

- Carpetas y archivos en `kebab-case`: `01-que-es-un-llm`, `streaming-sse.md`.
- Prefijo numérico de dos dígitos para ordenar lecciones: `01-…`, `02-…`, …, `19-…`.
- Capturas de pantalla en `recursos/img/` con nombre descriptivo: `bruno-llamada-gemini.png`.

## Salida del curso

La fuente de verdad son los `.md`. La conversión a PDF (Moodle/Classroom) o sitio HTML (Heroku/Render) se genera desde aquí. No se edita el formato de salida directamente; cualquier ajuste de estilo va en este archivo y se regenera la salida.
