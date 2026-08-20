# Changelog

Todos los cambios relevantes de sooft-ai-standards se documentan en este archivo.

El formato sigue [Keep a Changelog](https://keepachangelog.com/es/1.1.0/) y el versionado es [SemVer](https://semver.org/lang/es/).

---

## [No publicado]

### Agregado

- **Hook de sesión agnóstico a la herramienta.** Hasta ahora el único hook determinista de SOOFT (banner + recordatorio de cargar la skill antes de tocar código) existía solo para GitHub Copilot (`assets/sooft.json`, instalado por `internal/sooft-bootstrap.md`); ni Claude Code ni ninguna otra herramienta tenían un hook equivalente, aunque `SKILL.md` §0.1 ya lo mencionaba como pendiente ("en Claude Code se configuran por otro mecanismo; no los instales acá"). Se agrega `skills/sooft/assets/hooks/session-start.yml` como fuente única de verdad del contenido (banner + `additional_context`), de la que cada herramienta con hooks nativos deriva un adapter — nunca contenido divergente. Se implementa el adapter real para Claude Code (`assets/hooks/claude-settings-fragment.json`, un bloque `hooks.SessionStart` para mergear en `.claude/settings.json` sin pisar configuración propia del equipo) y se documenta el procedimiento de instalación (PASO C.5 de `sooft-bootstrap.md`). Para herramientas sin adapter propio se agrega una regla explícita (PASO C.6): PROHIBIDO inventar el nombre de un evento o el formato de un payload sin confirmarlo contra la documentación real de esa herramienta; si no se puede confirmar, no se instala nada y SOOFT sigue funcionando igual (la misma regla ya vive en las instrucciones always-on). Pendiente como follow-up: instalación automática del adapter de Claude Code desde `sooft-tech agent install` (hoy requiere el bootstrap en vivo de la skill `sooft`, porque el CLI solo copia archivos sueltos y `.claude/settings.json` necesita un merge, no una copia). Modifica: `skills/sooft/SKILL.md` (§0.1), `skills/sooft/internal/sooft-bootstrap.md` (PASOS C.5/C.6), `sooft-overview/index.html` y `sooft-overview/README.md`.

- **Manifests de detección de arquetipo para los 4 stacks backend (Java, Node/NestJS, .NET, Python), 100% genéricos.** El discovery necesitaba resolver el stack de un proyecto contra un manifest (`detection_order` → `detect` → `load`/`on_demand`) para cargar Golden Rules, tech-stack y el agente de migración correspondiente — pero ese mecanismo no existía materializado para ningún stack, y un diseño anterior lo había modelado sobre una distinción de arquetipos internos (`dotnet-pom`/`dotnet-paas`, `node-original`/`node-lite`, un rename `pom.commons.*` en Java) que resultó ser arquitectura propia de la organización de la que se adaptó la metodología — no de Sooft. Se descarta ese diseño y se construyen los 4 manifests (`archetypes/{java,node,dotnet,python}.manifest.yml`) sobre evidencia 100% pública y de mercado: `spring-boot-starter-parent` (Java), `express`/`fastify`/`@nestjs/core` (Node), el SDK `Microsoft.NET.Sdk.Web` (.NET), `fastapi` (Python). Cada stack resuelve a un único arquetipo genérico (salvo Node, que distingue `node-nest` de `node-express-fastify` por framework — ambos públicos). En consecuencia, se reescriben sin asumir ningún paquete/parent interno corporativo: los 3 agentes de migración (`agents/{java,node,dotnet}-migration-agent.md`, que quedan como upgrade genérico de versión de runtime/framework — Java 8→21, Node 14→20, .NET Core 3.1→.NET 8 — sin ningún paso de "reemplazar el paquete base interno viejo por el nuevo"), la tabla de clases y la Fase 1 de `sooft-migrations/SKILL.md`, el envelope de respuesta de `dotnet-create-yaml.md`/`java-create-yaml.md`/`node-create-swagger.md` (renombrado `PomError` → `ApiError`, sin atarlo a ningún paquete "provisto por el arquetipo"), `dotnet-create-tests.md`/`node-create-tests.md` y los 3 bloques de `init.md` que mencionaban el split interno o el envelope "corporativo". **La máquina de estados de SOOFT no cambia** (SC-011): es aditivo sobre el ruteo de arquetipos y la matriz de subagentes de migración, no introduce fases, gates ni transiciones nuevas.

- **Persistencia y compactación de estado entre sesiones (`STATUS.md`)** — `TICKET-2045`. Las sesiones SOOFT no sobrevivían entre días: el agente arrancaba sin contexto y se perdían decisiones, artefactos aprobados y progreso. Se introduce un **snapshot semántico compacto rehidratable** como cuarto artefacto de la constitución, complementario a `state.json` (pointer runtime), `evidence.md` (diario cronológico) y `SELF-REVIEW.md` (entregable de gate 4). El nuevo `docs/{tipo}/{slug}/STATUS.md` es un archivo **versionado** con 7 secciones obligatorias (metadatos, resumen ejecutivo, decisiones clave tomadas, artefactos aprobados, riesgos abiertos, progreso del PLAN, próximo paso), cap de 200 líneas (RNF-02) y actualización **in-place** en cada transición de fase. En paralelo se generan snapshots efímeros rotativos en `.sooft/status/YYYY-MM-DDTHH-MM.md` (formato Windows-friendly, RNF-03) con retención FIFO=10; los snapshots asociados a gates aprobados se mueven a `.sooft/status/gates/` y **no rotan** (auditoría permanente local). Reglas duras: **anti-drift RF-05** (`STATUS.md.phase == state.json.phase` obligatorio, divergencia = HALT), **lista negra RF-08** (sin PII, secretos, transcripts crudos, stack traces), **backfill opt-in RF-07** para workflows legacy con marcador `[inferido de evidence]`. Al iniciar una sesión nueva con `phase != IDLE`, el agente ejecuta un **resume flow** (RF-04): lee `state.json` + `STATUS.md` y reporta ticket, fase, últimas 3 decisiones y próximo paso en 8 líneas antes de pedir confirmación explícita. **La máquina de estados de §4 no cambia** (SC-011): la compaction es un paso operativo transversal, no un estado ni un gate nuevo. Nueva skill `sooft-checkpoint` para compaction manual on-demand sin cambiar `phase`. `sooft-status` extendida para leer `STATUS.md` y reportar drift, decisiones recientes y riesgos abiertos en el JSON estructurado. Nuevos archivos: `skills/sooft/assets/status-template.md`, `skills/sooft-checkpoint/SKILL.md`. Modifica: `skills/sooft/SKILL.md` (§4 nota informativa), `skills/sooft/internal/sooft-implement-task.md` (paso 6 + sección Compaction), `skills/sooft/internal/sooft-code-review-gate.md` (paso 0 pre-check bloqueante), `skills/sooft/internal/sooft-validation.md` (checkbox bloqueante + sección Relación con STATUS.md), los tres drivers (`sooft-development`, `sooft-bugs`, `sooft-security-remediation`) con path por `type`, `skills/sooft-status/SKILL.md` (Paso 3 + Paso 4.5 + JSON extendido con `status_summary.drift_detected`), `AGENTS.md` (bullets resume flow + compaction en SIEMPRE) y `.github/copilot-instructions.md` (sección Persistencia y compaction del estado del proyecto).

### Pendiente / posibles follow-ups (TICKET-2045)

- **F-01** — Helper opcional en `sooft-cli` para automatizar la rotación de snapshots, aplicar la retención FIFO, mover snapshots de gates y validar programáticamente la coherencia `STATUS.md ↔ state.json`. Binario Rust chico que corra en pre-commit o como post-hook de transición. Sacar como ticket separado del backlog.
- **F-02** — Linter automatizado del `STATUS.md` (chequear 7 secciones obligatorias, cap 200 líneas, ausencia de secretos por regex, drift con state.json). Puede vivir en `sooft-cli` o en un GitHub Action. Complementa el chequeo manual actual en `sooft-validation.md`.
- **F-03** — Extender el mecanismo a `sooft-migrations` (build-and-fix loop): agregar snapshots de progreso por sub-fase dentro de `MIGRATING` (parity con el resto). Requiere adaptar RF-03 al loop iterativo con tope de 5 intentos.
- **F-04** — Métricas de adopción: contar `STATUS.md` presentes en repos consumidores para medir uso real. Requiere telemetría opt-in y no persistente por defecto.

### Agregado

- **Artefacto de autoevaluación de código IA antes del gate 4 (`SELF-REVIEW.md`)** — `TICKET-2045`. Formaliza la propuesta del ticket: al llegar al gate 4 (`CODE_REVIEW_PENDING`), el reviewer humano hoy recibe solo el diff, sin saber qué cubrió el agente, qué no, ni con qué confianza. Se agrega un artefacto estructurado que el agente produce en dos capas: (1) sketchpad efímero `.sooft/self-review-scratchpad.md` durante `IMPLEMENTING` con una entrada por cada tarea del PLAN completada (working memory del agente, no se commitea); (2) autoevaluación final versionada en `docs/{tipo}/{slug}/SELF-REVIEW.md` (feat → `docs/feats/`, bug → `docs/bugs/`, security → `docs/security/`), consolidada como último paso operativo de `VALIDATING` antes de transicionar al gate 4. El artefacto tiene cinco secciones obligatorias (cobertura con IDs `[T0XX]` del PLAN, limitaciones, riesgos, nivel de confianza `alto/medio/bajo` + rationale + breakdown por dimensión, señales objetivas provenientes de `sooft-validation.md`) y una opcional (soporte adicional). Reglas duras contra el gaming del nivel de confianza: cap por dimensión (global ≤ mínimo de las tres), cap por señales objetivas (con tests fallando o cobertura bajo umbral el global no puede ser `alto`; con hallazgos SAST high/critical sin remediar el global se fuerza a `bajo`), rationale sustantivo obligatorio. Trazabilidad estricta `PLAN ↔ SELF-REVIEW`: toda tarea `[x]` debe estar cubierta por un ítem de "Cobertura" con su ID. Si el artefacto queda incompleto o inconsistente, el gate 4 no se abre: el flujo vuelve a `IMPLEMENTING` o queda en `BLOCKED` esperando aprobación del desvío. **La máquina de estados no cambia** (§4 de la skill `sooft`): la consolidación es un paso operativo dentro de `VALIDATING`, no un gate ni una fase nueva. Nuevos archivos: `skills/sooft/assets/self-review-template.md`, `skills/sooft/assets/self-review-sketchpad-template.md`. Modifica: `skills/sooft/SKILL.md` (§4, nota), `skills/sooft/internal/sooft-implement-task.md` (sketchpad en el flujo), `skills/sooft/internal/sooft-validation.md` (consolidación como último ítem del checklist, reglas de trazabilidad y anti-gaming), `skills/sooft/internal/sooft-code-review-gate.md` (SELF-REVIEW como entrada bloqueante, checklist de review humano de 5 preguntas, frase canónica ajustada), `skills/sooft-development/SKILL.md`, `skills/sooft-bugs/SKILL.md`, `skills/sooft-security-remediation/SKILL.md` (referencia en la ruta de skills), `AGENTS.md` y `.github/copilot-instructions.md`. Follow-up: extender el mismo mecanismo a la rama migration (`VALIDATING_PARITY` en `sooft-migrations`) — queda fuera de este release.

### Cambiado

- **Las 9 primitivas internas dejan de ser skills y pasan a ser recursos de la constitución `sooft`.** Antes vivían en `skills/internal/<nombre>/SKILL.md` con `metadata.internal: true`; como GitHub Copilot registra **todo** `SKILL.md` instalado como slash command, igual aparecían en el menú como `/sooft-discovery`, `/sooft-validation`, etc. (el flag `metadata.internal` solo las oculta de la discovery de `skills.sh`, no de Copilot). Ahora son **archivos de recurso** `skills/sooft/internal/<nombre>.md` (sin frontmatter, sin `SKILL.md`) que viajan con la skill `sooft` —que se carga siempre— y que los routers y la propia `sooft` cargan **leyendo el archivo** en el momento del flujo. Resultado: **no aparecen como `/sooft-*`** en ningún agente y se elimina el flag `INSTALL_INTERNAL_SKILLS`. Las referencias entre primitivas/routers pasan de "skill `sooft-X`" a "recurso `internal/sooft-X.md` de `sooft`" (path resuelto por la base de la skill `sooft`, sin `../` cross-skill). Archivos: movidos los 9 a `skills/sooft/internal/*.md`, borrado `skills/internal/`, actualizados `skills/sooft/SKILL.md` (índice de primitivas), los 3 routers, assets (`implementation-plan.md`, `bug-reproduction.md`, `copilot-instructions.md`, `compliance-review.md`), `skills/Readme.md`, `README.md` y `AGENTS.md`.

### Agregado

- **Conexión automática al MCP del issue tracker en Copilot.** El init (`/sooft`) ahora escribe `.vscode/mcp.json` con un server MCP remoto (Streamable HTTP) y `.vscode/settings.json` con `chat.mcp.autoStart: true` (Experimental). Con esa setting, VS Code **levanta el server solo** al detectar el `mcp.json` —sin el `MCP: List Servers → Start` manual—; la única interacción que queda es aceptar la **confianza** del server la primera vez (control de seguridad de VS Code, por única vez por proyecto). La experiencia del developer queda en 2 pasos —`npx skills add` + `/sooft`— sin tokens ni configuración manual. Ambos archivos se agregan por **merge** (no pisan otras claves/servers) y se escriben **siempre** durante el init (`settings.json` antes que `mcp.json`).
- **Sección "Copilot (VS Code)" en la documentación del MCP del issue tracker** — documenta el formato `.vscode/mcp.json` (clave `servers`, server remoto HTTP), aclara que `npx skills add` NO instala el MCP, y deja el patrón con `input` `password` para cuando el server sume autenticación.
- **Plantilla `templates/mcp.json`** — `.vscode/mcp.json` de ejemplo con un server de issue tracker. Sirve para que quien administra el repo del piloto lo pre-commitee y los devs tengan el server activo desde el arranque (sin el clic de *MCP: List Servers → Start* de la primera sesión). El flujo del dev sigue siendo `npx skills add` + `/sooft`; si el archivo ya existe, `/sooft` no lo pisa (merge).
- **Plantilla `templates/mcp-cli.json`** — `.mcp.json` de ejemplo para el **CLI de Copilot** (clave `mcpServers`, server de issue tracker con `"tools":["*"]`). Complementa a `templates/mcp.json` (que es el `.vscode/mcp.json` de VS Code, clave `servers`): son los dos archivos que `/sooft` deja para que el MCP arranque solo en ambos clientes.
- **`/sooft` e `install.sh` instalan las instrucciones y los prompt files de Copilot en el proyecto destino.** Antes, `.github/copilot-instructions.md` y `.github/prompts/*.prompt.md` no llegaban con `npx skills add` (que solo baja las skills), así que la GUI del proyecto destino quedaba sin custom instructions always-on ni slash commands. Ahora el auto-setup §0.1 de la skill `sooft` (PASO C.3) y `install.sh` los copian desde `skills/sooft/assets/` al `.github/` del destino, **sin pisar** archivos existentes. Son **stubs que delegan en la skill `sooft`** (no duplican la metodología): habilitan el comportamiento always-on y los comandos `/sooft`, `/sooft-development`, `/sooft-bugs`, `/sooft-security-remediation`, `/sooft-discovery` apuntando a las skills, que siguen siendo la única fuente de verdad. Nuevos archivos: `skills/sooft/assets/copilot-instructions.md` y `skills/sooft/assets/prompts/*.prompt.md`. Aplicado en `skills/sooft/SKILL.md` (§0.1), `plugins/sooft/hooks/install.sh` y `.github/README-copilot.md`.

### Cambiado

- **El init no bloquea por el MCP y el reporte final es breve.** Tras el banner, `/sooft` muestra un reporte corto (3-4 líneas: proyecto/stack, una línea de integraciones + archivos creados, una línea de que el MCP arranca solo, y los próximos pasos) y **no para a esperar** que el server figure **Running**: con `chat.mcp.autoStart` el MCP del issue tracker se levanta solo y el developer arranca a trabajar enseguida (lo único que VS Code puede pedir la primera vez es aceptar la **confianza** del server). Reemplaza el reporte largo y el gate de cierre del init de la iteración anterior. Aplicado en `skills/sooft-init/SKILL.md`, `plugins/sooft/skills/sooft-init/SKILL.md`, `.github/prompts/sooft.prompt.md` y `.github/copilot-instructions.md`.
- **El algoritmo de entrada (§0) se ejecuta en silencio.** El agente ya no narra la clasificación del mensaje (nada de "§0 — Clasificación del mensaje", "Tipo: (A) CONSULTA PURA", "PROHIBIDO abrir/editar archivos"): la clasificación y el ruteo son razonamiento interno. Las únicas salidas visibles del §0 siguen siendo la respuesta, las preguntas de discovery, las frases de gate y los reportes — así, tras el banner, el developer ve pocas líneas y arranca a trabajar. El algoritmo determinista no cambia; solo deja de imprimirse. Aplicado en `skills/sooft/SKILL.md` (§0).
- **Prefijos de ticket no estándar dejan de bloquear.** Un prefijo del issue tracker no reconocido (`STRY`, `TASK`, `PRB`, etc.) **nunca frena el trabajo**: el agente registra el ticket tal cual, infiere el tipo por el contenido y sigue, sin interrogar por el prefijo. Se suma `STRY` (Story) como tipo conocido. La tabla de tipos deja de ser una whitelist bloqueante. Aplicado en la documentación del MCP del issue tracker, `AGENTS.md`, `.github/copilot-instructions.md` y —cerrando el fix— en las dos fuentes canónicas que el agente carga primero: `skills/sooft/SKILL.md` (§6.6 y §7) y las reglas del issue tracker.
- **El agente ya no inventa un "gate de cierre" cuando faltan las tools del MCP.** Si en una sesión las herramientas del server MCP del issue tracker no están registradas (Copilot las toma al *iniciar* la sesión, así que un server levantado en caliente durante `/sooft` recién aparece en una sesión nueva), el agente **no bloquea ni lo trata como error**: ofrece seguir con el contenido del ticket pegado y señala el **botón nativo** de VS Code (el *code lens* **Start** en `.vscode/mcp.json` o el diálogo de **Trust**), sin pedirle al developer que tipee comandos. Aplicado en ambos `init/SKILL.md`, `.github/prompts/sooft.prompt.md` y `.github/copilot-instructions.md`.
- **El agente puede leer el ticket del issue tracker vía MCP.** Con el MCP configurado por `/sooft`, la regla del issue tracker deja de afirmar que «el agente no tiene acceso»: si las tools del server están disponibles en la sesión, el agente lee el ticket directamente; si no, el developer le provee los datos. En ambos casos se mantiene la prohibición de inventar datos o escribir en el issue tracker en nombre del developer (el cierre del ticket sigue siendo manual). Reemplaza la sección «Limitación: el agente no tiene acceso directo» del README. Aplicado en `skills/sooft/SKILL.md` (§6.6) y en las reglas y la documentación del issue tracker.
- **`/sooft` deja el MCP del issue tracker listo en los dos entornos (VS Code y CLI), sin pasos manuales.** Además del `.vscode/mcp.json` de VS Code (clave `servers`), el init ahora escribe **`.mcp.json` en la raíz** (clave `mcpServers`, mismo server con `"tools":["*"]`), que es lo que **sí lee el CLI de Copilot** —el CLI no lee `.vscode/mcp.json`, pero sí `.mcp.json` / `.github/mcp.json`—. Así el server arranca solo en ambos clientes (la única interacción es aceptar la confianza la primera vez). Esto **corrige** dos cosas de la iteración anterior: (1) la afirmación de que el CLI «no lee ningún archivo de proyecto» y quedaba «listo solo en VS Code» (falso: lee `.mcp.json`), y (2) el registro manual descrito como `/mcp add <nombre> <url>` —`/mcp add` abre un **formulario** interactivo (Tab entre campos, Ctrl+S para guardar; no toma la URL inline), y la alternativa por shell es `copilot mcp add <nombre> --type http --url "<URL>" --tools "*"`—. Ese registro manual queda solo como **fallback** para cuando no se corrió `/sooft`. Headers siempre vacíos (un `Authorization: Bearer` rompe con **401**). Aplicado en la documentación del MCP del issue tracker, `skills/sooft/SKILL.md` (§6.6), `.github/copilot-instructions.md`, ambos `init/SKILL.md`, `.github/prompts/sooft.prompt.md` y `.github/README-copilot.md`.

---

## [0.1.4] — 2026-06-08

### Agregado

- **Suite de evals v0.2.0** — migra los 7 escenarios de `evals/v0.1.0/` a tasks autocontenidas con `task.toml`, `instruction.md`, `fixture/`, `verification.md` y `expected/`.
- **Escenarios adversariales** — agrega checks para intento de saltar PRD, aprobacion ambigua y `.sooft/state.json` inconsistente.
- **Contrato de consumo sin runner propio** — documenta como un subagente o harness externo debe preparar fixtures, capturar evidencia y emitir resultados.
- **Schema, rubrica y matriz de migracion** — `evals/v0.2.0/schema.md`, `rubric.md` y `migration.md`.
- **Fixtures materializados y assertions estructuradas** — cada task declara reglas machine-readable de paths/texto y trae archivos sinteticos de estado inicial.

### Cambiado

- `README`, `DOCUMENTATION` y `CONTRIBUTING` ahora declaran `evals/v0.2.0/` como suite vigente y `evals/v0.1.0/` como referencia historica.
- CI de validacion estatica revisa estructura de tasks v0.2.0 y parseo TOML, sin ejecutar evals.
- CI de validacion estatica tambien revisa enums, checks obligatorios, fixtures materializados y hard failures legacy.

---

## [0.1.3] — 2026-06-03

### Agregado

- **Política de TDD (Test-Driven Development)** para el desarrollo de lógica nueva, aplicada durante la implementación, **después** del discovery y del plan aprobado. El TDD es **cómo** se implementa la lógica nueva, no reemplaza al discovery ni a los gates.
- **Casuística por tipo de trabajo**:
  - **Feature nueva (development)** — lógica de negocio, validaciones, cálculos, endpoints nuevos, parsers/regex: **test-first** (rojo → mínimo código para verde → refactor manteniendo verde). **SÍ es TDD.**
  - **Bug / fix (bugs)** — test de **reproducción-first** que falla por el bug primero, después el fix que lo pone en verde. Reproducción-first (no es TDD de diseño; el objetivo es reproducir, no diseñar desde cero).
  - **Refactor / chore** — los tests existentes deben seguir en verde; no se borran ni se reescriben sin justificación. **No es TDD: es regresión.**
  - **Security remediation** — re-scan del hallazgo (el escáner SAST/el análisis estático) + tests existentes en verde. **No es TDD.**
  - **Cambios sin lógica testeable** — HTML/CSS estático, textos, comentarios, configuración pura: no se fuerzan tests; el agente lo indica explícitamente.
- **Mecánica de TDD en una feature nueva** (durante la implementación): por cada unidad de lógica nueva del plan, escribir el test primero y confirmar que falla (rojo), implementar el mínimo para que pase (verde), refactorizar manteniendo verde, marcar el código generado como `[IA-generated]` y correr la suite del stack (JUnit/xUnit/pytest/Jest) tras cada unidad.

---

## [0.1.2] — 2026-06-02

### Agregado

- **Capa de compatibilidad con GitHub Copilot** (`.github/`):
  - `copilot-instructions.md` — las reglas de SOOFT en el formato que Copilot lee (CLI y VS Code), con las 5 preguntas de discovery prominentes.
  - `prompts/` — prompt files que **fuerzan** cada flujo: `sooft-discovery`, `sooft-development`, `sooft-bugs`, `sooft-security-remediation`.
  - `README-copilot.md` — setup (`useInstructionFiles`), verificación con sentinel y troubleshooting.
- Resuelve la diferencia de comportamiento entre el CLI de Copilot (lanzaba las 5 preguntas) y la GUI de VS Code (no las lanzaba por falta de `copilot-instructions.md` + setting).
- Doble cobertura del discovery: instrucción al inicio (Copilot) + enforcement duro en `pre-commit` (no se commitea sin `discovery-checklist.json`).

---

## [0.1.1] — 2026-06-02

Cierre del alcance E3 (Desarrollo) del SDLC de Sooft.

### Agregado

- **Integración del escáner SAST** — validación de seguridad obligatoria antes del PR, complementaria al análisis estático (calidad) y al linter (estilo). Hallazgos Very High/High bloquean el PR.
- **Regla de trazabilidad de código IA** — `plugins/sooft/rules/ai-traceability.md`. Todo código generado se marca `[IA-generated]`, se registra en la evidencia y requiere revisión humana antes del PR.
- **Gate de revisión de código IA-generated** en el skill `sooft-development`, adicional a los gates de PRD/SPEC/PLAN.

### Cambiado

- `pre-pr-check.sh`: agrega verificación del escáner SAST y de marcadores `[IA-generated]`.
- `rules/security.md`: SAST como validación obligatoria.
- Templates `evidence.md`: secciones del escáner SAST y de código IA-generated.
- `development/SKILL.md`: checklist de validación con linter + análisis estático (SAST) + escaneo de dependencias (SCA), tests e2e y tagging IA.
- Docs (`README`, `DOCUMENTATION`, `AGENTS`) alineadas con el alcance E3.

### Máquina de estados y stack

- **`plugins/sooft/state/transitions.md`** — máquina de estados canónica completa: rechazos (`*_REJECTED`), `SECURITY_FINDINGS`, `CODE_REVIEW_PENDING`, `VALIDATING`, `BLOCKED`, `CANCELLED`, y las tres ramas (feat / bug / security) hasta converger en implementación. Ya no es lineal.
- **Stack ampliado a los 5 lenguajes de Sooft**: Java, .NET (C#), Python, TypeScript, JavaScript.
  - `pre-pr-check.sh`: detecta y corre tests de Python (`pytest`) y .NET (`dotnet test`), además de Java y Node.
  - `rules/testing.md`: frameworks por stack (JUnit, xUnit/NUnit, pytest, Jest/Vitest).
  - `skills/init`: detecta `.csproj`/`.sln`, `pyproject.toml`/`requirements.txt`, `tsconfig.json`.
  - `state.json`: agrega campo `type` (feat/bug/security) y campos de bloqueo.

---

## [0.1.0] — 2026-06-02

Primera versión. Metodología SOOFT para desarrollo asistido por IA en Sooft Technology.

### Agregado

- **Plugin SOOFT** — el motor de la metodología, organizado por las 6 fases del ciclo de vida:
  - `01-alcance` — discovery y PRD colaborativo
  - `02-diseño` — especificación técnica y ADRs (condicional)
  - `03-desarrollo` — development, bugs y security-remediation
  - `04-pruebas` — estrategia de tests y validación pre-PR
  - `05-despliegue` — release y notas de deploy
  - `06-operacion-mantenimiento` — incidentes y mantenimiento
- **Skills transversales** — `sooft-init` y `sooft-status`.
- **9 principios fundacionales** heredados de sooft-way, embebidos en cada componente.
- **Switcheo automático de modelos** por complejidad (Haiku / Sonnet / Opus) con `classify-complexity.sh` y `model-routing.md`.
- **Guardrails duros** — hooks `.sh`: `pre-commit` (secretos y PII), `pre-pr-check` (artefactos y tests), `pre-push`, `post-checkout`, más utilidades de estado (`sooft-init`, `sooft-update-state`, `sooft-check-env`) e `install.sh`.
- **Templates** — PRD, SPEC, PLAN, PRINCIPLES, evidence, ADR. Incorporan conceptos de SpecKit: `[NEEDS CLARIFICATION]`, criterios de éxito medibles, verificación de consistencia, change history y update mode.
- **Suite de evals** (`evals/v0.1.0/`) — 7 escenarios con rúbrica de gate-safety.
- **Integraciones** — el issue tracker, GitLab, el análisis estático, MCP, Confluence. SpecKit documentado como fuente de consulta (no motor).
- **Reglas de Sooft** — architecture, security, testing, documentation, issue-tracker.
- **Ejemplos** — backend-service (Java), frontend-app (React), library-migration.
- **Gobernanza** — AGENTS.md, GOVERNANCE.md, SECURITY.md, CONTRIBUTING.md, CODEOWNERS.

### Notas

- Alcance de esta versión: planeación, diseño, implementación (backend y frontend) y pruebas. Las fases de despliegue y operación están definidas pero no son el foco de v0.1.0.
- el análisis estático está documentado en las integraciones pero su enforcement entra en una versión posterior.

[0.1.0]: https://github.com/MauricioLulusis/sooft-ai-standards/releases/tag/v0.1.0
