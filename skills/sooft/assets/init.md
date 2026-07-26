> Parte de sooft. No invocar directamente.

# Init — Inicialización de sooft-ai-standards

Este skill inicializa sooft-ai-standards en el proyecto del developer.
NO arranca un workflow de feature o bug — solo prepara el entorno.

## Modo silencioso durante el arranque (OBLIGATORIO)

Todo el `sooft-init` (auto-setup de hooks + detección + escritura de `.sooft/`) se ejecuta **en silencio**:

- Emití **una sola línea al comenzar**: `⏳ Inicializando SOOFT…` y NADA más hasta el reporte final.
- **PROHIBIDO narrar pasos** ("voy a validar…", "ahora reviso…", "completé…") ni explicar cada comando.
- Hacé la detección del proyecto en **un solo barrido** (una pasada de lectura/comando); **no repitas** chequeos.
- La salida visible del init es: la línea inicial, y al final el **reporte** (Fase 6). Nada en el medio.
- **Excepción:** las preguntas de discovery (Fase 3) y las frases canónicas de gate **SIEMPRE se muestran** — no son verborragia, son la interacción del flujo. El modo silencioso NO las suprime.

---

## Fase 0 — Auto-setup de hooks y custom agents (vía la constitución `sooft`)

Antes de inicializar el proyecto, la constitución `sooft` ya tiene que haber corrido su
**auto-setup de hooks** (§0.1 de la skill `sooft`). Como `/sooft` carga primero `sooft` y
después este asset, normalmente ya está hecho. Verificá y, si falta, disparalo:

- Si **NO** existe `~/.copilot/hooks/sooft.json`, o **NO** existe `.github/hooks/sooft.json`
  en la raíz del proyecto, o **NO** existe `.github/agents/sooft-discovery.agent.md`
  → seguí el procedimiento §0.1 de `sooft` (instala hooks, instrucciones, prompts y custom
  agents en las ubicaciones funcionales, idempotente, sin preguntar). No dupliques la lógica
  acá: es la misma.

Esto deja a Copilot listo (banner + trigger de carga de la skill + subagentes en `.github/agents/`)
tanto en el **CLI** como en la **GUI de VS Code**. Los hooks toman efecto en la **próxima** sesión;
los agents quedan disponibles para Copilot CLI desde el proyecto destino.

---

## Fase 1 — Leer el contexto del proyecto

Leé los siguientes archivos si existen (no fallar si no están):

- `README.md` o `README.adoc` — nombre del proyecto, descripción, instrucciones de build
- `package.json` — JavaScript/TypeScript (Node): scripts (test, lint, build); `tsconfig.json` indica TS
- `pom.xml` — Java Maven: artifactId, build plugins
- `build.gradle` o `build.gradle.kts` — Java/Kotlin Gradle: tasks definidas
- `*.csproj` / `*.sln` — .NET (C#): target framework, paquetes
- `pyproject.toml` / `requirements.txt` / `setup.py` — Python: dependencias, runner de tests
- `.git/config` — remote origin del repositorio
- Archivos de CI (workflows / pipelines del proyecto) — integraciones de CI si las hay

Inferí del código:
- **Lenguaje y framework** — uno de los stacks de Sooft: Java (Spring Boot), .NET (ASP.NET Core), Python (FastAPI), Node.js (Express/Fastify) o NestJS.
- **Nombre del proyecto** (directorio raíz o campo name en manifest)
- **Rama target** (buscar `main`, `master`, `develop` en git o referencias en CI)
- **Stack y dependencias en uso** — derivalo de la evidencia real del proyecto, no lo asumas:
  - `package.json` → framework (Express/Fastify/NestJS), versión de Node en `engines`, y las dependencias clave (ORM, cliente HTTP, testing).
  - `pom.xml` / `build.gradle` → versión de Java, Spring Boot, y plugins de build.
  - `*.csproj` → `<TargetFramework>` (ej. `net8.0`) y los `<PackageReference>` principales.
  - `pyproject.toml` / `requirements.txt` → versión de Python, FastAPI y librerías clave.
  - Anotá la versión del runtime para saber si está vigente o es un stack heredado candidato a migración.

> **Resolución del arquetipo (carga acotada al stack).** Con esa evidencia, resolvé el arquetipo
> del stack detectado en `archetypes/backend-service/{java,dotnet,node,nest,python}/` (o
> `archetypes/frontend-app/` para SPA) y, si lo inferís acá, guardalo en `state.json` (campo
> `archetype`). La regla es **traer solo el contexto del stack detectado** — nunca más de uno. El
> mecanismo completo (orden de detección, resolver una sola vez) está en
> `internal/sooft-discovery.md`, paso 1.a.

> **Si detectás un stack backend (Java, .NET, Node, NestJS o Python), las Golden Rules de backend
> son la línea base técnica del proyecto.** Cubren arquitectura (separación de capas API → Application
> → Domain → Adapters, contrato de errores consistente, config por entorno, resiliencia) y
> convenciones de nombres, cross-stack con notas por tecnología. La fuente canónica es
> `archetypes/backend-service/golden-rules.md`, con el detalle por stack en
> `archetypes/backend-service/{java,dotnet,node,nest,python}/`. En la Fase 5 se materializan en
> `.sooft/PRINCIPLES.md` para que el agente las respete en cada sesión.

> **Catálogo de arquetipos (qué hay y qué no).** El inventario canónico de arquetipos de Sooft vive
> en `archetypes/README.md`: backend service (Java, .NET, Node, NestJS, Python), frontend app y
> library/runtime migration. **El discovery manda, el catálogo acompaña**: primero detectás de la
> evidencia real del proyecto (framework, versión de runtime, dependencias) qué stack y qué librerías
> ya usa; recién después cruzás ese hallazgo contra el catálogo para proponer estructura y decisiones.
> Sobre esa base se decide qué se reutiliza y qué se construye.

---

## Fase 2 — Detectar integraciones (sin bloquear si no están)

Para cada integración, marcá `found` o `not_found` basándote en evidencia concreta:

| Integración            | Cómo detectarla                                                                                 |
| ---------------------- | ----------------------------------------------------------------------------------------------- |
| **Git**                | Siempre presente si hay `.git/`                                                                 |
| **Issue tracker**      | Buscar patrones de ticket (`ABC-123`, `#123`) en commits recientes, docs o CI config             |
| **Repositorio remoto** | Remote origin del repositorio (Git)                                                             |
| **Confluence / wiki**  | Referencias a URLs de Confluence u otra wiki en README o docs                                    |
| **Jira / GitHub Issues** | Patrones de ticket tipo `ABC-123` (Jira) o `#123` (GitHub/GitLab) en commits o docs           |

Regla: **no asumir el issue tracker si no hay evidencia explícita.**

---

## Fase 3 — Preguntas (máximo 5, solo lo que no se pudo inferir)

Hacé únicamente las preguntas cuya respuesta no pudiste inferir del código.
Nunca hacés más de 5 preguntas en total. Agrupalas en un solo mensaje.

> **Los gates NO se preguntan.** SOOFT es **siempre `strict`** (no se avanza sin aprobación
> explícita en cada fase). Es un invariante de la metodología, no una preferencia configurable.
> `gate_strictness` se escribe fijo en `"strict"`; nunca lo ofrezcas como opción.

Preguntas candidatas (seleccioná solo las necesarias):

1. **Tracker de tickets** — "¿Qué sistema de tickets usás para este proyecto? (el issue tracker / Jira / GitHub Issues / ninguno)"
2. **Rama target** — "¿Cuál es la rama target para tus PRs? (main / master / develop / otra)"
3. **Comando de tests** — "¿Cuál es el comando para correr los tests? (ej: `npm test`, `mvn test`, `./gradlew test`)"
4. **Comando de lint/build** — "¿Hay un comando de lint o build que deba correr antes de un PR? (ej: `npm run lint`, `mvn package`)"

---

## Fase 4 — Crear .sooft/ si no existe

Verificá si existe el directorio `.sooft/` en la raíz del proyecto.
Si no existe, crealo.

---

## Fase 4.5 — Asegurar el `.gitignore` del proyecto (estado local de SOOFT fuera de Git)

`.sooft/` y `.worktrees/` son **estado local y efímero de SOOFT**, no parte del entregable: NO se
commitean. Si quedan trackeados, `git worktree add` los **materializa en cada worktree** (un worktree
es un checkout completo del árbol trackeado), rompiendo el aislamiento y **bifurcando el estado** (el
agente termina escribiendo `state.json`/`evidence.md` en la copia del worktree en vez de la raíz).

Por eso el init **asegura el `.gitignore`** de la raíz del proyecto (merge, sin pisar lo existente):

1. Mirá si existe `.gitignore` en la raíz.
   - Si **NO** existe → crealo con el bloque de abajo.
   - Si **YA** existe → agregá solo las líneas que falten, sin tocar el resto. Si ya están, no las dupliques.

```gitignore
# Estado local de SOOFT (no se commitea)
.sooft/
.worktrees/
.agents/
```

2. **Si `.sooft/` o `.worktrees/` ya están trackeados** (aparecen en `git ls-files`), el `.gitignore`
   solo no alcanza: destrackealos sin borrar la copia de trabajo →
   `git rm -r --cached .sooft .worktrees`. Es seguro y reversible (no toca los archivos en disco). **NO**
   destrackees `.agents/` ni `docs/` solo: SOOFT no los genera, así que si están trackeados es decisión
   del developer — avisalo en el reporte y dejá que decida.

> **`docs/` NO se ignora.** El árbol `docs/` (`docs/feats/`, `docs/bugs/`, `docs/migrations/`,
> `docs/security/`) es el **rastro de auditoría** (principio #9): se trackea a propósito y va al repo.
> Que aparezca checkouteado en un worktree es comportamiento normal de Git e inofensivo — el PLAN se
> escribe en `docs/` **antes** de crear el worktree. Un worktree no puede excluir selectivamente
> carpetas trackeadas; la única forma de mantener algo afuera es no trackearlo, y eso aplica solo al
> estado local de SOOFT.

Es config de gobernanza, no código del entregable: no dispara gates.

---

## Fase 5 — Escribir .sooft/config.json y .sooft/state.json

Con toda la información recolectada, escribí los dos archivos.

**`.sooft/config.json`** — configuración persistente del proyecto:

```json
{
  "version": "0.1.0",
  "project": "<nombre del directorio>",
  "target_branch": "<rama configurada o inferida>",
  "worktree_root": ".worktrees",
  "integrations": {
    "tracker": "<servicenow|jira|github|none|unknown>",
    "repository": "<git|unknown>",
    "docs": "<confluence|none|unknown>"
  },
  "validation": {
    "test_command": "<comando o null>",
    "lint_command": "<comando o null>",
    "build_command": "<comando o null>"
  },
  "gate_strictness": "strict"
}
```

**`.sooft/state.json`** — estado inicial del pipeline:

```json
{
  "phase": "IDLE",
  "ticket": null,
  "owner": "<email del developer si está disponible, sino null>",
  "created_at": "<fecha de hoy ISO 8601>",
  "last_step": "init",
  "next_step": null,
  "archetype": "<id del arquetipo resuelto del manifest, o null si no aplica>",
  "context_loaded": []
}
```

> **`archetype` y `context_loaded` — carga de contexto acotada al stack.** El campo `archetype`
> guarda el `id` que se resuelve contra el manifest del stack detectado
> (`archetypes/node.manifest.yml` para Node, `archetypes/java.manifest.yml` para Java,
> `archetypes/dotnet.manifest.yml` para .NET)
> a partir de la evidencia detectada (scope en `package.json` y versión de Node, `<parent>` del
> `pom.xml` y `java.version`, o `<PackageReference>` a `el paquete base del arquetipo`/`el paquete base del arquetipo` en un
> `.csproj` y `<TargetFramework>`). En el init podés
> dejarlo precargado si ya lo inferiste (ej. `node-original`, `conjunto de librerías-web-v2`, `dotnet-paas`); si no, queda
> `null` y lo resuelve el discovery la primera vez. **La regla es traer SOLO el contexto del stack
> detectado**: si el proyecto es Node, se cargan únicamente las referencias Node del bundle `load`
> de ese arquetipo — NUNCA las de Java o .NET que el proyecto no usa (eso sobrecarga el
> contexto al pedo). `context_loaded` registra las rutas ya cargadas para no repetirlas. El
> detalle del mecanismo (resolver una sola vez, `on_demand` perezoso) está en
> `internal/sooft-discovery.md`, paso 1.a.

Usá Write para escribir ambos archivos. No invoques scripts externos ni hooks de shell.

**`.sooft/PRINCIPLES.md`** — principios técnicos del proyecto (opcional pero recomendado):

Si el proyecto no tiene `.sooft/PRINCIPLES.md`, ofrecé crearlo a partir de la plantilla canónica `skills/sooft/assets/templates/PRINCIPLES.md`, completando lo que se haya detectado del stack y las integraciones. Es el contrato técnico estable que el agente respeta en cada feature. Si el developer prefiere posponerlo, dejalo para después — no es bloqueante para inicializar.

> **Si el stack es backend (Java + Spring, Node + NestJS o .NET + ASP.NET Core), sembrá
> `.sooft/PRINCIPLES.md` con las Golden Rules de backend** — así viajan al proyecto y el agente las
> lee en cada sesión (no quedan solo como referencia en sooft-ai-standards). Incluí, adaptadas al
> stack detectado:
>
> - **Arquitectura:** separación de capas `Controller → Service → Client/Repository` (sin lógica de
>   negocio en controllers, sin acceso a datos desde el controller, sin dependencias al revés); el
>   BFF es **pasamanos** (orquesta POM/core, no es fuente de verdad; si hay base, es caché); el
>   **arquetipo es obligatorio** (no se reimplementa logging/http/tracing/errores/claims/health —
>   en Node, paquete `paas` full por defecto, no lib por lib); **envelope corporativo** `meta`/`data`
>   (siempre array)/`errors` en toda respuesta, sin stack traces al cliente.
> - **Naming + tests + seguridad:** convenciones de nombres por capa, cobertura de tests del proyecto
>   y las restricciones no negociables de seguridad (sin secretos hardcodeados, sin PII en logs).
>
> La fuente canónica completa es `archetypes/backend-service/golden-rules.md` (cross-stack) más el
> detalle por stack en `archetypes/backend-service/{java,node,dotnet}/`. Referenciala en
> `PRINCIPLES.md` para que el developer pueda profundizar. No dupliques el archivo entero: sembrá lo
> esencial y citá la fuente.

---

## Fase 5.5 — Servidores MCP del proyecto (`.mcp.json`) — opcional

SOOFT es **agnóstico al IDE** y compatible con el estándar **MCP** (Model Context Protocol): si el
equipo usa servidores MCP (por ejemplo, un issue tracker, una base de conocimiento o una API interna),
se declaran en un `.mcp.json` estándar en la raíz del proyecto, que funciona en cualquier cliente
compatible (Claude CLI, Copilot CLI, etc.).

Por defecto SOOFT **no impone ningún servidor**: deja el `.mcp.json` con `mcpServers` vacío para que
cada proyecto agregue los suyos. No se conecta nada a espaldas del developer.

**Procedimiento (merge, sin pisar lo existente):**

Si `.mcp.json` no existe, crealo con la estructura base. Si existe, dejalo como está (no lo pises).

```jsonc
{
  "mcpServers": {}
}
```

> Cuando el equipo agregue un servidor MCP, va dentro de `mcpServers`. Nunca se hardcodean secretos:
> los tokens se pasan por variables de entorno o `inputs` con `password: true`, jamás en texto plano.

El `.mcp.json` no es código del entregable: es configuración de tooling. No requiere el flujo de
gates ni dispara el predicado de escritura de código.

---

## Fase 5.6 — Instalar PR Template estándar (si no existe)

Si en la Fase 2 no se detectó un PR Template (`not_found`), instalá el template estándar de Sooft en el repo del developer.

**Ruta de instalación:** `.github/pull_request_template.md`

**Procedimiento:**
1. Creá la carpeta `.github/` si no existe.
2. Copiá el contenido de `assets/templates/pull_request_template.md` al archivo destino.
3. Es idempotente: si el archivo ya existe, **no lo sobreescribas**. Anotá en el reporte que ya existía.

El template es un artefacto de gobernanza del repo — sigue el mismo patrón que `.mcp.json` y los hooks de Copilot: se instala en silencio durante el init, sin preguntar, y se menciona en el reporte.

---

## Fase 6 — Banner + reporte final

**Primero, mostrá el banner SOOFT.** Antes de cualquier otra salida de esta fase,
imprimí el banner de SOOFT (si está disponible en el proyecto) o un encabezado simple
'SOOFT — Sooft Engineering AI Rails', reproducido **dentro de un bloque de código
con triple backtick**. El bloque de código es **obligatorio**: sin él, el IDE colapsa
los espacios y el ASCII art se rompe; con él, la alineación se conserva.

**Luego**, mostrá un reporte **breve** (sin bloques largos) con este formato:

```
== sooft-ai-standards inicializado ==

Proyecto: <nombre> · Stack: <lenguaje>/<framework> · Rama: <rama> · Gates: strict
Integraciones: <las encontradas, separadas por " · " — o "ninguna">   ·   Creados: .sooft/ · .gitignore · .mcp.json · hooks · PR Template
<solo si el stack es backend> Golden Rules de backend activas (arquitectura + naming) · materializadas en .sooft/PRINCIPLES.md

SOOFT activo, ya podés trabajar → /sooft-development · /sooft-bugs · /sooft-security-remediation
```

**No es un gate: no pares ni esperes confirmación.** El developer ya puede arrancar cualquier flujo
apenas ve el reporte. Si alguna integración quedó como `unknown`, mencionalo en una línea y seguí:
se configura después editando `.sooft/config.json`.

> **Si en una sesión las tools del MCP no aparecen, NUNCA lo trates como un gate ni como un error
> del init.** El CLI registra las tools del MCP **al iniciar la sesión**: si el server se levantó
> recién (durante `/sooft`), esta sesión todavía no las tiene. Para tomarlas, **abrí una sesión nueva
> del CLI** y aceptá la confianza en la fuente MCP la primera vez — no hace falta reinstalar ni
> reconfigurar nada. Mientras tanto **no bloquees**: si el developer pega el contenido del ticket,
> arrancás el discovery con eso. Solo si falta el `.mcp.json` se registra a mano: `/mcp add` abre un
> **formulario** (Tab entre campos, Ctrl+S para guardar; no toma la URL en la misma línea) o, desde
> la shell, `copilot mcp add servicenow --type http --url "<URL>" --tools "*"` (headers vacíos — un
> `Authorization: Bearer` rompe con 401).

---

## Qué NO hacer

- No bloquear la inicialización porque falta una integración opcional
- No hacer más de 5 preguntas — inferir lo que se pueda del código
- No arrancar ningún workflow de desarrollo (feat, bug, sec, migrate) durante el init
- No asumir el issue tracker si no hay evidencia explícita de tickets
- No modificar archivos de **código** del proyecto. Los únicos archivos fuera de `.sooft/`
  que init escribe son configuración/gobernanza, no código: los hooks de Copilot
  (`.github/hooks/sooft.json`), el `.mcp.json` de la raíz (MCP del issue tracker) y el template
  de PR (`.github/pull_request_template.md`).
- No pisar un `.mcp.json` existente ni sus otros servers: se agrega por **merge**.
- No hardcodear tokens ni headers en `.mcp.json` (el server actual no tiene auth; un
  `Authorization: Bearer` rompe con 401; si en el futuro la suma, va por `input`).
- No crear carpetas ni archivos específicos de ningún IDE (`.vscode/`, `.idea/`, etc.): SOOFT es
  agnóstico al IDE.
