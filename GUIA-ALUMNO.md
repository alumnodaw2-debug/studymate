# Guía del alumno

Cómo trabajar en este curso de IA generativa: cuentas, herramientas, flujo git por lección y formato de entrega de actividades.

> **Antes de empezar:** echa un vistazo también a [`STYLE.md`](./STYLE.md), [`GLOSARIO.md`](./GLOSARIO.md) y [`ROUTING.md`](./ROUTING.md). Te van a hacer falta antes de la primera entrega.

## 1 · Antes de empezar: cuentas y herramientas

Lo que necesitas instalado o registrado **antes** de la lección 01. No empieces sin esto.

### 1.1 · Cuentas

- **GitHub.** Cuenta personal con tu correo del centro o uno personal (no importa cuál). Activa autenticación en dos pasos.
- **Google AI Studio.** Entra en [aistudio.google.com](https://aistudio.google.com/) con tu cuenta de Google del centro. Te da una API key gratuita para `gemini-2.5-flash` con cuota suficiente para todo el curso. Si no tienes cuenta del centro, una personal vale igual: cambia menos rápido la cuota y la latencia.

### 1.2 · Herramientas locales

- **Java 21 LTS** (Eclipse Temurin recomendado) o superior.
- **Maven 3.9+** (viene integrado con Spring Tools, no hace falta instalarlo aparte si usas el IDE).
- **Spring Tools** (basado en Eclipse) o **IntelliJ IDEA Community**. El curso usa Spring Tools como referencia, IntelliJ funciona igual.
- **Git 2.40+**. Configura `user.name` y `user.email` antes de hacer ningún commit.
- **Bruno** ([usebruno.com](https://www.usebruno.com/)). Cliente REST open source. No usamos Postman porque queremos versionar las colecciones en git como ficheros `.bru`.
- **Ollama** ([ollama.com](https://ollama.com/)). Te enseñaremos a instalarlo en clase para que conozcas la herramienta, pero **no la vas a usar localmente** salvo que tengas una GPU NVIDIA con ≥8 GB de VRAM. El curso usa la GPU del centro (RTX 3090) para todo lo de Ollama; tu portátil sólo lanza peticiones HTTP contra ella.

### 1.3 · Servidor Ollama del centro

Toda la parte local de los modelos corre en un equipo del centro:

```
http://185.193.11.153:11434
```

Comprueba que respondes desde tu equipo**antes** del primer día de Spring AI:

```bash
curl http://185.193.11.153:11434/api/tags
```

Debe devolver un JSON listando modelos. Si no, avisa al profesor: probablemente el servidor está apagado o la red del aula no te deja salir.

## 2 · Configurar `GEMINI_API_KEY`

Tu API key de Google AI Studio se lee desde una variable de entorno del sistema operativo. **Nunca** la pongas en `application.yml` ni en ningún archivo del repo: `git` la enviaría a GitHub al primer push.

### Windows (PowerShell)

```powershell
setx GEMINI_API_KEY "AIzaSy..."
```

`setx` la guarda de forma permanente. **Cierra y vuelve a abrir** Spring Tools / IntelliJ para que la lea: la variable sólo entra en procesos arrancados después.

Verifica desde una **PowerShell nueva**:

```powershell
$env:GEMINI_API_KEY
```

Debe imprimir tu key. Si imprime nada, la terminal sigue siendo la antigua o `setx` falló.

> **Importante.** Si pegas la key con comillas dobles raras (típico copiando desde un PDF), `setx` puede guardarlas dentro del valor. Si Spring AI da `403 Forbidden`, vuelve a fijarla con `setx GEMINI_API_KEY "AIzaSy..."` desde una PowerShell limpia.

(Para macOS y Linux, ver [§9 Apéndice](#9--apéndice-macos-y-linux).)

## 3 · Fork del repo del curso

El repo de referencia es:

```
https://github.com/ichueca/studymate-curso
```

Lo llamaremos **upstream**. Tú no escribes ahí: lo *forkeas* y trabajas en tu copia.

### 3.1 · Hacer el fork

1. Entra en [https://github.com/ichueca/studymate-curso](https://github.com/ichueca/studymate-curso).

2. Pulsa **Fork** (arriba a la derecha). Crea el fork con el mismo nombre bajo tu usuario.

3. Clona tu fork (no el upstream) en tu máquina:
   
   ```bash
   git clone https://github.com/<TU-USUARIO>/studymate-curso.git
   cd studymate-curso
   ```

### 3.2 · Configurar `upstream`

Para que puedas traer las lecciones nuevas que publique el profesor, declara su repo como remoto adicional:

```bash
git remote add upstream https://github.com/ichueca/studymate-curso.git
git remote -v
```

Debe imprimir dos remotos: `origin` (tu fork) y `upstream` (el del profesor).

### 3.3 · Atajo: `setup.ps1` (Windows, recomendado)

En el repo tienes un script que hace §3.2 por ti, además de traer los tags del curso, comprobar Java/Maven/`GEMINI_API_KEY` y avisarte de lo que falte. **Pásalo una sola vez** justo después del clon del §3.1, desde la raíz del repo:

```powershell
./scripts/alumno/setup.ps1
```

Es idempotente: ejecutarlo dos veces no rompe nada. Si cambias de equipo, vuelve a pasarlo en el nuevo. Para macOS/Linux, sigue §3.2 a mano (el script es PowerShell).

## 4 · Flujo por lección

Una lección = una rama = una pull request. Sin excepciones.

### 4.1 · Sincronizar antes de empezar la lección

Cada vez que el profesor publique una lección nueva, **antes** de crear tu rama:

```bash
git checkout main
git fetch upstream
git merge upstream/main
git push origin main
```

Esto trae los cambios del profesor a tu `main` y los empuja a tu fork.

### 4.2 · Salir del tag de partida correcto

Cada lección declara en su cabecera de qué tag git parte. Por ejemplo, L05 parte de `lec-04-refactor-y-router-ok`. Esos tags etiquetan el estado del código en la carpeta `studymate/` del repo (los `.md` no se etiquetan: avanzan con `main`).

Para empezar a trabajar en la lección desde el estado correcto del código:

```bash
cd studymate
git checkout -b lec-05/jdoe lec-04-refactor-y-router-ok
```

Eso crea la rama `lec-05/jdoe` posicionada en el tag de partida. A partir de ahí trabajas y commiteas con normalidad.

### 4.3 · Convención de nombre de rama

Convención: `lec-NN/<TU-USUARIO>`, en minúsculas, con la barra `/` y sin tildes ni espacios. La barra es deliberada (GitHub la trata como carpeta lógica y agrupa visualmente todas tus ramas en su panel). Ejemplos válidos: `lec-05/jdoe`, `lec-12/mlopez`. No válidos: `Lec-05/JDoe`, `lec-5/jdoe`, `lec_05_jdoe`.

### 4.4 · Trabajar y commitear

- Lee primero el `README.md` y el `actividades.md` de la lección entera antes de tocar código.

- Resuelve la **actividad obligatoria** primero. Si te sobra tiempo, ataca las **avanzadas**.

- Commits en español, en imperativo, una unidad lógica por commit:
  
  ```bash
  git commit -m "L05: añade ChatController con validación de longitud"
  git commit -m "L05: configura bean ChatClient para CHAT_SIMPLE"
  ```

### 4.5 · Push y pull request

```bash
git push -u origin lec-05/jdoe
```

GitHub te imprimirá un enlace para abrir la PR. Ábrelo y rellena la plantilla.

**Título:**

```
[L05] <TU-USUARIO> · Primer endpoint de chat
```

**Cuerpo (plantilla):**

```markdown
## Lección
L05 · primer-endpoint-chat

## Qué he hecho
- [x] Actividad obligatoria
- [ ] Avanzada A · Forzar Gemini para `/api/chat/simple`
- [ ] Avanzada B · Informe comparativo Ollama vs. Gemini

## Criterios de evaluación
(copia aquí la lista de checkboxes de `actividades.md` y marca lo que cumples)

## Notas para el profesor
(dudas, decisiones de diseño, lo que necesites aclarar)
```

La PR se abre contra `main` del **upstream**, no contra el `main` de tu fork. **No la mergees tú**: el profesor la revisa, comenta y la cierra cuando ha puntuado.

### 4.6 · Después de la PR

- El profesor deja comentarios en la PR. Si pide cambios, vuelves a tu rama, commiteas y haces `git push`. La PR se actualiza sola.
- La PR se cerrará **sin merge**: tu trabajo no se incorpora al upstream, queda registrado en tu fork como referencia.
- Para empezar la siguiente lección, vuelve a §4.1.

## 5 · Errores frecuentes

> **Antes de pelearte con nada, ejecuta el diagnóstico:**
>
> ```powershell
> ./scripts/alumno/doctor.ps1
> ```
>
> Sólo lee, no toca nada. Comprueba remotos, tags, rama actual, `GEMINI_API_KEY` y conectividad al servidor Ollama del centro. Si vas a pedir ayuda al profesor o abrir un Issue, **pega la salida completa**: ahorra tres mensajes de ida y vuelta.

- *`fatal: refusing to merge unrelated histories`* al hacer `git merge upstream/main`. **Causa:** clonaste el upstream en lugar de tu fork. **Solución:** revisa `git remote -v`; `origin` debe ser tu fork.
- *`! [rejected] main -> main (fetch first)`* al hacer push. **Causa:** alguien (tú desde otro equipo) tocó tu fork. **Solución:** `git pull origin main --rebase` y vuelve a empujar.
- *La PR no aparece en el upstream.* **Causa:** abriste la PR contra `main` de tu propio fork. **Solución:** al crearla, en la barra superior selecciona `base repository: ichueca/studymate-curso` y `base: main`.
- *`Spring fails to start: GEMINI_API_KEY is null`*. **Causa:** lanzaste el IDE antes de hacer `setx`. **Solución:** cierra el IDE entero (no sólo la ventana) y reábrelo desde una PowerShell nueva.
- *`Connection refused: 185.193.11.153:11434`*. **Causa:** estás fuera de la red del centro o el servidor Ollama está caído. **Solución:** prueba `curl` desde la terminal; si falla, avisa al profesor.
- *Conflicto al hacer `git merge upstream/main`*. **Causa:** modificaste algún archivo del upstream que el profesor también modificó. **Solución:** salvo que sepas resolverlo, descarta tus cambios locales en ese archivo (`git checkout upstream/main -- <archivo>`) y vuelve a intentar el merge. Si dudas, pregunta antes de tocar nada.

## 6 · Buenas prácticas que evalúo

- **Nada de credenciales en el repo.** Antes de cada commit, `git diff --staged | findstr -i "AIzaSy"` (Windows) o `grep -i AIzaSy` (Linux/macOS) debe devolver vacío.
- **Mensajes de commit en imperativo y en español.** *"añade …"*, *"corrige …"*, no *"añadí"* ni *"adding …"*.
- **Una unidad lógica por commit.** Diez commits de "wip" cuentan como uno mal escrito.
- **`actividades.md` no se modifica nunca.** Si crees que la actividad está mal planteada, abre un Issue en el upstream, no parchees el archivo.

## 7 · Cómo hacer preguntas

- **Dudas de la lección:** abre un Issue en el upstream con título `[L05] no compila el ChatClientConfig` (o similar). El profesor o un compañero responderá.
- **Dudas técnicas urgentes en clase:** levantando la mano, como siempre.
- **Dudas privadas (notas, faltas):** correo al profesor, no Issue.

## 8 · Material de apoyo del curso

- [`INDICE.md`](./INDICE.md) — orden de las lecciones y dependencias.
- [`STYLE.md`](./STYLE.md) — voz, naming, formato.
- [`GLOSARIO.md`](./GLOSARIO.md) — terminología (token, embedding, RAG, etc.).
- [`ROUTING.md`](./ROUTING.md) — qué modelo se usa en cada tarea y por qué.

## 9 · Apéndice: macOS y Linux

<details>
<summary>Configurar <code>GEMINI_API_KEY</code> en macOS / Linux</summary>

Edita `~/.zshrc` (macOS por defecto) o `~/.bashrc` (Linux):

```bash
export GEMINI_API_KEY="AIzaSy..."
```

Recarga:

```bash
source ~/.zshrc   # o ~/.bashrc
```

Verifica:

```bash
echo $GEMINI_API_KEY
```

Reinicia el IDE para que herede la variable.

</details>
