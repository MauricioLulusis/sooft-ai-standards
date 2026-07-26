---
name: sooft
description: Cargá esta skill SIEMPRE, como PRIMER paso, ANTES de leer, analizar, buscar, abrir, tocar o escribir cualquier código en un proyecto de Sooft Technology, y ANTES de cualquier otra skill SOOFT. Define el algoritmo de entrada obligatorio, los gates de aprobación, la máquina de estados, el switcheo de modelos y las reglas no negociables de seguridad, testing, arquitectura y trazabilidad. Es la constitución de la metodología SOOFT (Sooft Engineering AI Rails) y se aplica de forma determinista, no opcional.
---

# sooft — Constitución de SOOFT (reglas deterministas)

Esta skill es la **fuente única de verdad** de SOOFT. Todas las demás skills se apoyan en lo que está acá y la citan **por nombre**, no por path. Los **routers** (`sooft-development`, `sooft-bugs`, `sooft-security-remediation`, `sooft-migrations`) conducen cada rama y delegan en **primitivas** chicas. El router `sooft-migrations` (rama `type=migration`) está **guiado por el discovery** (origen y destino, definidos con el dev) y forkea el **subagente especialista** correcto según el stack detectado: `java-migration-agent` (upgrade Java, motor OpenRewrite + Maven), `node-migration-agent` (upgrade Node, motor npm-check-updates + jscodeshift) o `language-migration-agent` (port entre tecnologías distintas, sin motor AST). Las **primitivas internas** NO son skills ni slash commands: son **archivos de recurso** que viven dentro de esta misma skill, en `sooft/internal/<nombre>.md`, y viajan con `sooft` (que se carga siempre). Como no tienen `SKILL.md`, no se exponen como `/sooft-*` ni requieren `INSTALL_INTERNAL_SKILLS`; los routers las cargan **leyendo el archivo** correspondiente cuando el flujo lo pide. Las **multi-router** (cargadas desde más de un router) son `internal/sooft-discovery.md`, `internal/sooft-implement-task.md`, `internal/sooft-code-review-gate.md`, `internal/sooft-validation.md`, `internal/sooft-evidence.md`. Las **de fase/artefacto** son `internal/sooft-adr.md` (al surgir una decisión de arquitectura significativa en `sooft-development`), `internal/sooft-test-strategy.md` (en el planning de `sooft-development`/`sooft-bugs`), `internal/sooft-release.md` (tras aprobarse el PR), `internal/sooft-maintenance.md` (trabajo tipo chore en `sooft-development`); las invoca el agente en el momento correcto, NO el developer. Las **single-router** son assets embebidos en cada router (`assets/prd.md`, `assets/technical-spec.md`, `assets/implementation-plan.md` en `sooft-development`; `assets/bug-analysis.md`, `assets/bug-reproduction.md`, `assets/fix-plan.md` en `sooft-bugs`; `assets/security-findings.md`, `assets/security-scope.md`, `assets/remediation-plan.md` en `sooft-security-remediation`). El init del proyecto es `assets/init.md` (este skill). Las únicas skills developer-invocables adicionales (con slash command propio) son `sooft-status` y `sooft-incident-response`.

### Índice de primitivas internas (recursos de esta skill)

No son skills: son archivos en `sooft/internal/`. Cuando el flujo lo pida, **leé el archivo** indicado.

| Recurso | Se carga cuando |
|---|---|
| `internal/sooft-discovery.md` | arranca cualquier flujo — discovery obligatorio antes de tocar nada |
| `internal/sooft-implement-task.md` | hay que ejecutar una tarea aprobada del plan |
| `internal/sooft-validation.md` | validación pre-PR (`/review`) |
| `internal/sooft-code-review-gate.md` | gate de aprobación humana del código `[IA-generated]` |
| `internal/sooft-evidence.md` | hay que registrar evidencia en `.sooft/evidence.md` |
| `internal/sooft-adr.md` | surge una decisión de arquitectura significativa |
| `internal/sooft-test-strategy.md` | se define qué y cómo testear durante el planning |
| `internal/sooft-release.md` | el PR fue aprobado y hay que preparar el deploy |
| `internal/sooft-maintenance.md` | el trabajo es tipo chore/mantenimiento |

Las reglas de este documento son **deterministas**: cada condición tiene una acción única y obligatoria. Donde dice `OBLIGATORIO`, `PROHIBIDO`, `SIEMPRE`, `NUNCA`, `HALT` o "si y solo si", no hay criterio ni excepción salvo la que el propio texto enumere. Ante un caso no cubierto: `HALT` y preguntá al developer; PROHIBIDO improvisar.

---

## §0.0. Primera activación en la sesión (banner)

La PRIMERA vez que cargás `sooft` en una sesión (solo la primera, no en los mensajes siguientes):

1. **Banner (fallback — costo cero por defecto).** Normalmente el banner ASCII lo muestra el **hook `sessionStart`**, que hace `cat` de `~/.copilot/hooks/banner.txt` — lo imprime el harness, **0 tokens**. Por eso:
   - Si **ya existe** `~/.copilot/hooks/banner.txt` → **NO lo imprimas vos**; de eso se encarga el hook.
   - Solo imprimilo vos como **fallback** cuando el hook NO está (primera sesión antes de instalarlo, Claude Code, o entornos sin hook): leé el archivo `assets/banner.txt` de esta skill y reproducí su contenido EXACTO como primera acción visible, en bloque de código (triple backtick). `assets/banner.txt` es la **única fuente de verdad** del arte ASCII — no lo copies ni lo reescribas en el SKILL.

   > **OBLIGATORIO (solo en el caso fallback):** imprimir el banner es una tarea mecánica (SIMPLE, ver §5). En Claude Code, si lo renderiza el LLM, hacelo **con Haiku** (`claude-haiku-4-5-20251001`) — delegá a un subagente `model: haiku`. NUNCA gastes Sonnet ni Opus en el banner. (En Copilot/otros modelos, simplemente imprimilo.)

2. **Auto-setup de hooks** (ver §0.1): si los hooks no están instalados, instalalos **siempre, sin preguntar**.
3. **Inicialización del proyecto.** Mirá si existe `.sooft/` en la raíz:
   - Si **NO** existe → es un proyecto sin inicializar. Leé y seguí `assets/init.md` (crea `.sooft/`, detecta stack e integraciones). Es lo que hace que `/sooft` sea el **único comando de arranque**: banner + hooks + init, todo en uno. (`/sooft` se mapea a ESTA skill; sin el init no quedaría `.sooft/`.)
   - Si **ya** existe → NO reinicialices; seguí al punto 4.
4. **Seguí con el §0**: el algoritmo de entrada (que arranca, para trabajo de código, por el discovery obligatorio).

> **Modo silencioso en el arranque.** El banner, el auto-setup de hooks (§0.1) y el `sooft-init` se ejecutan **sin narración**: NO escribas "voy a…/ahora…/completé…" ni expliques cada comando. A lo sumo `⏳ Inicializando SOOFT…` al comenzar, y después el **reporte final** del `sooft-init`. Nada en el medio. **Excepción:** las preguntas de discovery y las frases canónicas de gate SIEMPRE se muestran.

> Esto cubre la **primera sesión** a nivel skill, cuando el hook todavía no existe: el banner, el auto-setup, el `sooft-init` y —vía §0— el discovery se disparan igual. De la segunda sesión en adelante, el hook `sessionStart` ya hace el banner y el trigger de carga de forma determinista.

---

## §0. Algoritmo de entrada — ejecutalo EN ORDEN ante CADA mensaje del developer

```
PASO 1 — Clasificar el mensaje. Es exactamente uno de estos tipos:
  (A) CONSULTA PURA  → solo pide información, NO deriva en un cambio de código
                       ("explicame X", "qué es Y", "cómo funciona Z").
  (B) TRABAJO DE CÓDIGO → cualquier otra cosa que toque o vaya a tocar el código:
                       feature, bug, refactor, hotfix, Y TAMBIÉN "analizá",
                       "encontrá", "revisá", "arreglá", "mirá este archivo",
                       "fijate por qué falla".
  (C) META           → sooft-init, sooft-status, next, review (operación del pipeline).

PASO 2 — Rutear por tipo:
  SI (A): respondé. PROHIBIDO abrir/editar archivos del trabajo. FIN.
  SI (C): cargá la skill correspondiente (sooft-init/sooft-status/...) y seguila. FIN.
  SI (B): continuá al PASO 3. (Si empezó como (A) y deriva en cambio → pasá a (B).)

PASO 3 — [OBLIGATORIO antes de leer/abrir UN SOLO archivo del trabajo]
  Leé y seguí el recurso `internal/sooft-discovery.md` de esta skill. PROHIBIDO leer, analizar, buscar o abrir
  archivos del trabajo antes de completar el discovery.

PASO 4 — Clasificar la rama (campo `type` de `.sooft/state.json`):
  feature/refactor            → `type=feat`     → cargá la skill `sooft-development`
  bug/regresión/incidente     → `type=bug`      → cargá la skill `sooft-bugs`
  vulnerabilidad/hallazgo     → `type=security` → cargá la skill `sooft-security-remediation`
  migración de stack/versión  → `type=migration`→ cargá la skill `sooft-migrations`
  (migración = subir versión de plataforma: Java 8→21, Spring Boot 2→3, etc.,
   preservando la semántica. Un cambio funcional con migración incidental sigue siendo `feat`.)

PASO 5 — Recorrer los gates EN ORDEN (§3). En cada gate: emitir la frase
  canónica textual y HALT hasta aprobación explícita del developer.

PASO 6 — Escribir código SOLO si se cumple el predicado de §2. Si no se
  cumple: HALT. PROHIBIDO escribir.
```

Este algoritmo es la parte determinista central: dado el mismo mensaje, la secuencia de pasos es siempre la misma.

> **El §0 se ejecuta EN SILENCIO — NUNCA lo narres.** La clasificación (PASO 1), el ruteo (PASO 2) y los pasos siguientes son razonamiento **interno**: PROHIBIDO imprimir encabezados tipo "§0 — Clasificación del mensaje", "Tipo: (A) CONSULTA PURA…", "PROHIBIDO abrir/editar archivos", ni enumerar los pasos. El developer no ve el algoritmo, ve el **resultado**. Las ÚNICAS salidas visibles del §0 son: la **respuesta** (tipo A), las **preguntas de discovery** (tipo B), las **frases canónicas de gate** y los **reportes**. Para una consulta pura, respondé directo —sin preámbulo de clasificación—; para trabajo de código, arrancá directo con las preguntas de discovery. Objetivo: tras el banner, el developer ve pocas líneas y ya puede trabajar.

---

## §0.1. Auto-setup de los hooks (una sola vez — Copilot CLI y VS Code GUI)

La **primera vez** que cargás `sooft` en la sesión (§0.0 punto 2), instalá los hooks y los archivos que la GUI de VS Code necesita: **leé y seguí el recurso `internal/sooft-bootstrap.md`** de esta skill, EN ORDEN. Ahí está el procedimiento completo (PASOS A–D: idempotencia, instalación sin preguntar, copia de `assets/` a user-level y repo-level, y el HALT si faltan los assets).

Resumen de lo que deja instalado:

- `~/.copilot/hooks/sooft.json` + `~/.copilot/hooks/banner.txt` → user-level (CLI y GUI).
- `.github/hooks/sooft.json` → repo-level (versionado, viaja con el repo).
- `.github/copilot-instructions.md` + `.github/prompts/*.prompt.md` → custom instructions always-on y slash commands de la GUI (REGLA DE NO PISAR: si ya existen, no los sobreescribas).

Estos archivos son **stubs que delegan en las skills**; NO duplican la metodología. La fuente de verdad es siempre esta skill `sooft` y las que cita por nombre. En **Claude Code** los hooks se configuran por otro mecanismo (`settings.json`); no los instales acá.

---

## §0.2. Subagentes Copilot CLI — delegación controlada

Cuando el entorno sea **GitHub Copilot CLI** y existan custom agents en `.github/agents/`, el orquestador SOOFT delega trabajo especializado a esos subagentes para usar contexto aislado, tools acotadas y modelos por rol: siempre que haya un subagente aplicable, lo usa antes de resolver con el agente principal. El agente principal conserva la orquestación, `.sooft/state.json`, gates, frases canónicas, evidencia y aprobaciones humanas.

**Investigación/discovery:** si el pedido del developer implica investigar, explorar, analizar, revisar, encontrar o diagnosticar código/contexto, usá `sooft-discovery` para la exploración read-only siempre que esté disponible; el orquestador sintetiza el resultado a partir del handoff. Invocación explícita en Copilot CLI: `@sooft-discovery <pedido>` en sesión interactiva, o `copilot --agent sooft-discovery -p "<pedido de discovery read-only>"` en una corrida automatizada. Solo ejecutá el recurso directamente si el subagente no existe, no está disponible o el pedido es una consulta pura que no requiere leer el repo; en ese caso registrá el fallback.

**Reglas duras:**

- Los subagentes **NO reemplazan** a los skills principales ni a esta constitución.
- Un subagente **NUNCA** aprueba PRD, SPEC, PLAN, código IA-generated, excepciones de seguridad ni PR.
- Un subagente con `edit` solo puede escribir los artefactos que el orquestador le pida y solo si el predicado de §2 lo permite para archivos del entregable.
- Si un modelo no está disponible, aplicá `.github/agents/MODELS.md`; no inventes modelos.
- Para routing determinista por agente, evitá `model: auto` en la sesión principal de Copilot CLI.

**Mapa de delegación por fase/recurso SOOFT:**

| Fase / recurso SOOFT | Subagente Copilot CLI |
|---|---|
| `internal/sooft-discovery.md` | `sooft-discovery` |
| `sooft-development/assets/prd.md` | `sooft-prd-writer` |
| `sooft-development/assets/technical-spec.md` | `sooft-spec-architect` |
| `sooft-development/assets/implementation-plan.md` | `sooft-plan-writer` |
| `sooft-bugs/assets/bug-analysis.md`, `bug-reproduction.md`, `fix-plan.md` | `sooft-bug-analyst` |
| `internal/sooft-test-strategy.md` | `sooft-test-strategist` |
| Seguridad / SAST / findings | `sooft-security-reviewer` |
| `internal/sooft-validation.md`, `internal/sooft-code-review-gate.md` | `sooft-code-reviewer`, `sooft-security-reviewer` |
| `internal/sooft-evidence.md` | `sooft-evidence-writer` |
| `internal/sooft-release.md` | `sooft-release-writer` |

Si los agentes no están disponibles, seguí el flujo normal con los recursos internos: la delegación no es precondición para cumplir SOOFT en entornos sin custom agents.

### Handoff to SOOFT orchestrator

Todo subagente Copilot CLI que participe en un flujo SOOFT debe devolver un handoff estructurado al orquestador. El handoff no aprueba gates ni reemplaza `.sooft/state.json`; solo entrega evidencia para que el orquestador continúe el flujo determinista.

Formato estándar obligatorio:

```markdown
## Handoff to SOOFT orchestrator

### Resultado
[Qué hizo el subagente y conclusión principal.]

### Evidencia usada
[Archivos, comandos, diffs, logs o artefactos usados como evidencia.]

### Archivos leídos
[Lista de rutas inspeccionadas o N/A.]

### Archivos modificados
[Lista de rutas editadas o N/A.]

### Riesgos o bloqueos
[Riesgos, dudas abiertas, validaciones pendientes o N/A.]

### Requiere gate humano
[Sí/No y cuál gate aplica: PRD, SPEC, PLAN, código IA-generated, seguridad o PR.]

### Próximo paso sugerido
[Acción recomendada para el orquestador SOOFT.]
```

El orquestador decide la transición de estado, registra evidencia y emite la frase canónica del gate cuando corresponda. Un subagente **NUNCA** aprueba PRD, SPEC, PLAN, código IA-generated, excepciones de seguridad ni PR.

---

## §1. Los 9 principios fundacionales

1. **Gate-driven** — no avanzás en un punto crítico sin aprobación explícita del developer.
2. **PRD colaborativo** — el scope se afina con un ida y vuelta breve antes de cerrarlo.
3. **Spec cuando importa** — SPEC técnica solo para cambios complejos o riesgosos; lo simple va directo al plan.
4. **Artefactos por tipo** — el trabajo deja rastro en `docs/feats/`, `docs/bugs/` o `docs/security/`.
5. **Worktree-first** — trabajás en `.worktrees/{tipo}-{slug}` aislado, nunca sobre la rama compartida.
6. **Nombres tipo Git** — los tipos de trabajo son `feat`, `fix`, `hot-fix`, `chore`, `security`.
7. **Tool-agnostic** — las herramientas de Sooft se detectan o configuran por proyecto; no asumís proveedores.
8. **Security-by-default** — todo cambio pasa por validación, tests y los controles de seguridad de Sooft.
9. **Auditabilidad** — cada trabajo deja decisión, plan, evidencia e historial rastreables.

---

## §2. Predicado de escritura de código (binario)

**Escribís código en el proyecto SI Y SOLO SI:**

```
state.phase ∈ { PLAN_APPROVED, FIX_PLAN_APPROVED, REMEDIATION_PLAN_APPROVED, MIGRATION_PLAN_APPROVED, IMPLEMENTING, MIGRATING }
```

- En **cualquier otro** valor de `phase`: **PROHIBIDO** escribir, crear o modificar un solo archivo del entregable (ni código, ni HTML, ni config, ni `index.html`, ni `tsconfig.json`, nada).
- Únicos archivos que SÍ podés escribir antes de ese predicado: los artefactos del propio proceso SOOFT (`discovery-checklist`, `PRD.md`, `SPEC.md`, `PLAN.md`) y `.sooft/`.
- **PROHIBIDO** el patrón "plan informal + empezar a crear". El plan se presenta formalmente (§3) y se aprueba antes de tocar el filesystem del entregable.

Responsabilidades fijas: el **developer** describe, responde discovery y **aprueba** (PRD, SPEC, PLAN, código IA, PR). El **agente** genera artefactos, implementa bajo el predicado de arriba y corre validaciones. El developer **nunca** necesita escribir código.

---

## §3. Gates de aprobación

Recorrelos EN ORDEN. En cada gate: escribí la **frase canónica textual** y HALT.

| Orden | Gate | Artefacto (path de salida) | Aprueba | Se omite si |
|---|---|---|---|---|
| 1 | PRD | `docs/{tipo}/{slug}/PRD.md` | Developer | nunca |
| 2 | SPEC | `docs/{tipo}/{slug}/SPEC.md` | Developer / Tech Lead | el cambio NO es complejo (criterio en `assets/technical-spec.md` de `sooft-development`) |
| 3 | PLAN | `docs/{tipo}/{slug}/PLAN.md` | Developer / Tech Lead | nunca |
| 4 | Código IA-generated | (el diff, antes del PR) | Developer | nunca |

**Frase canónica de los gates 1–3 (textual, reemplazando los corchetes):**

> **`"[artefacto] listo en [path]. Revisá antes de que continúe."`**
> → **HALT. No avances hasta que el developer diga OK explícito.**

**Frase canónica del gate 4 (textual):**

> **`"El siguiente código fue generado por IA y está marcado como [IA-generated]. Revisalo y aprobalo antes de que arme el PR."`**
> → **HALT. No se arma el PR hasta la aprobación del código IA-generated.**

Reglas: PROHIBIDO inferir un "sí". PROHIBIDO saltar un gate aunque el developer lo pida. El gate 4 es OBLIGATORIO aunque el PLAN ya esté aprobado.

---

## §4. Máquina de estados

`state.phase` toma **únicamente** uno de los valores enumerados abajo. El campo `type` (`feat` · `bug` · `security`) determina la rama. PROHIBIDO inventar estados fuera de esta lista; un `phase` no enumerado o una transición no listada → **HALT**.

### Estados comunes
`IDLE`, `REQUIREMENT_LOADED`, `IMPLEMENTING`, `VALIDATING`, `SECURITY_FINDINGS`, `CODE_REVIEW_PENDING`, `REVIEW_DONE`, `PR_OPEN`, `DONE` (terminal), `BLOCKED` (transversal), `CANCELLED` (terminal).

### Rama FEATURE (`type=feat`, skill `sooft-development`)
`ANALYZED → PRD_PENDING ⇄ PRD_REJECTED → PRD_APPROVED → [SPEC_PENDING ⇄ SPEC_REJECTED → SPEC_APPROVED] → PLAN_PENDING ⇄ PLAN_REJECTED → PLAN_APPROVED → IMPLEMENTING`

### Rama BUG (`type=bug`, skill `sooft-bugs`)
`BUG_DOCUMENTED → BUG_ANALYZED → BUG_REPRODUCED → FIX_PLAN_PENDING ⇄ FIX_PLAN_REJECTED → FIX_PLAN_APPROVED → IMPLEMENTING`

### Rama SECURITY (`type=security`, skill `sooft-security-remediation`)
`FINDINGS_DOCUMENTED → SCOPE_PENDING → SCOPE_CONFIRMED → REMEDIATION_PLAN_PENDING ⇄ REMEDIATION_PLAN_REJECTED → REMEDIATION_PLAN_APPROVED → IMPLEMENTING`

### Rama MIGRATION (`type=migration`, skill `sooft-migrations`)
`MIGRATION_REQUIREMENT_LOADED → ARCHEOLOGY_DONE → MIGRATION_PLAN_PENDING ⇄ MIGRATION_PLAN_REJECTED → MIGRATION_PLAN_APPROVED → MIGRATING → VALIDATING_PARITY → CODE_REVIEW_PENDING`
- Flujo lean **guiado por el discovery**: SIN PRD ni SPEC. El discovery fija origen y destino (tecnología y versión de cada lado) con el dev; el análisis del proyecto + el PLAN reemplazan al PRD. El PLAN es el único gate de planificación.
- Dos clases (definidas en el PLAN según origen/destino): **upgrade de versión mismo-lenguaje** (motor AST + build loop) y **port entre tecnologías** (traducción guiada, sin motor AST).
- `MIGRATING` es el estado de escritura de código (loop ejecutado por el subagente especialista que `sooft-migrations` forkeó según el stack).
- `VALIDATING_PARITY`: verifica paridad funcional (regresión en clase A; tests portados en clase B, sin cambio de comportamiento) antes de converger al tronco común.
- `MIGRATION_BLOCKED` (transversal): 5 intentos de build **o arranque** fallidos, conflicto de Git que no compila, o hallazgo que requiere intervención humana. Guarda `previous_phase` y solo vuelve a ese estado tras el OK del developer.

### Tronco común (las cuatro ramas convergen)
`IMPLEMENTING/MIGRATING → VALIDATING (o VALIDATING_PARITY) → ( SAST con hallazgos críticos/altos ⇒ SECURITY_FINDINGS → remediar → VALIDATING ) → CODE_REVIEW_PENDING → REVIEW_DONE → PR_OPEN → DONE`

> **Autoevaluación de código IA:** como último paso operativo de `VALIDATING` (antes de transicionar a `CODE_REVIEW_PENDING`), el agente consolida `.sooft/self-review-scratchpad.md` —mantenido durante `IMPLEMENTING/MIGRATING`— en `docs/{tipo}/{slug}/SELF-REVIEW.md`. Es un paso operativo, **no un estado nuevo**: la máquina de estados no cambia. Reglas de consolidación (trazabilidad con el PLAN, anti-gaming del nivel de confianza, comportamiento cuando queda incompleto) en el recurso `internal/sooft-validation.md`. Template: `skills/sooft/assets/self-review-template.md`.

> **Persistencia y compaction del estado del proyecto (STATUS.md):** en cada transición de fase de la máquina de estados, además de actualizar `state.json` y `evidence.md`, el agente actualiza in-place `docs/{tipo}/{slug}/STATUS.md` (snapshot semántico compacto rehidratable, versionado) y escribe una copia efimera en `.sooft/status/YYYY-MM-DDTHH-MM.md` con retención FIFO=10 (los snapshots de gates aprobados se mueven a `.sooft/status/gates/` y no rotan). Al iniciar una sesión nueva con `phase != IDLE`, el agente ejecuta el **resume flow**: lee `state.json` + `STATUS.md` y reporta la fase, decisiones clave y próximo paso antes de pedir confirmación al developer. Es un paso operativo transversal, **no un estado nuevo**: la máquina de estados no cambia. Contrato: `skills/sooft/assets/status-template.md`. Compaction manual on-demand: skill `sooft-checkpoint` (no cambia `phase`).

### Reglas de transición (deterministas)
1. **No se salta un gate.** No se llega a `IMPLEMENTING`/`MIGRATING` sin el estado de plan aprobado de la rama (`PLAN_APPROVED` / `FIX_PLAN_APPROVED` / `REMEDIATION_PLAN_APPROVED` / `MIGRATION_PLAN_APPROVED`). Violación → HALT.
2. **Todo `*_REJECTED` vuelve al `*_PENDING` correspondiente.** Nunca termina el pipeline.
3. **`VALIDATING` con hallazgos críticos/altos del SAST ⇒ `SECURITY_FINDINGS` OBLIGATORIO.** PROHIBIDO saltearlo.
4. **`CODE_REVIEW_PENDING` es OBLIGATORIO** antes de `PR_OPEN`, aunque el plan esté aprobado.
5. **`BLOCKED` / `MIGRATION_BLOCKED` guardan `previous_phase`** y solo transicionan de vuelta a ese estado.
6. **En la rama migration, el build-and-fix loop tiene tope de 5 intentos fallidos (compile o arranque de la app)** ⇒ `MIGRATION_BLOCKED` OBLIGATORIO. PROHIBIDO seguir iterando a ciegas.
7. **`REVIEW_DONE → PR_OPEN` NO es automático — requiere confirmación explícita del developer.** El agente NUNCA pushea la rama ni abre el PR por iniciativa propia. PROHIBIDO `git push` (en cualquier variante: `--set-upstream`, `-u`, `push origin`), `pull_request_create` o cualquier publicación de la rama sin que el developer lo pida o lo confirme. Terminado el code review, el agente PARÁ y preguntá: *"Código aprobado. ¿Pusheo la rama `<rama>` y abro el PR, o lo hacés vos?"* → Stop. Sin ese OK explícito, la rama **queda local**.

### Formato exacto de `.sooft/state.json`
```json
{
  "phase": "VALIDATING",
  "type": "feat",
  "ticket": "TICKET-2045",
  "owner": "<usuario>",
  "created_at": "<fecha ISO-8601>",
  "last_step": "implement",
  "next_step": "run-validations",
  "blocked_reason": null,
  "previous_phase": null
}
```

---

## §5. Switcheo de modelos por complejidad

Base: **Sonnet**. Antes de actuar, clasificá el pedido y elegí modelo con esta tabla. El developer no decide esto.

| Nivel | Disparadores (cualquiera ⇒ ese nivel) | Modelo |
|---|---|---|
| **COMPLEX** | arquitectura, seguridad, auth, cifrado, migración, concurrencia, PII, refactor grande, performance crítico, rollback | Opus (`claude-opus-4-8`) |
| **SIMPLE** | typo, renombrar, formatear, comentario, status, "qué es", "cómo funciona", pedido < 7 palabras | Haiku (`claude-haiku-4-5-20251001`) |
| **STANDARD** | todo lo demás (default) | Sonnet (`claude-sonnet-4-6`) |

**Regla de prioridad determinista:** evaluá COMPLEX primero. **Si hay CUALQUIER disparador COMPLEX, el nivel es COMPLEX**, aunque también haya disparadores SIMPLE. Recién si no hay ninguno COMPLEX evaluás SIMPLE; si tampoco, STANDARD. La rama `sooft-security-remediation` es **siempre** Opus. **NUNCA** degrades a Haiku algo que toca seguridad, arquitectura o escritura de código de producción. Al escalar a Opus: decílo explícitamente y por qué.

---

## §6. Reglas no negociables

Cada ítem es `OBLIGATORIO` o `PROHIBIDO`. Sin criterio intermedio.

> **Fuente de verdad.** La política completa de seguridad, testing y Git vive en `assets/policies/security-guidelines.md`, `assets/policies/testing-guidelines.md` y `assets/policies/git-guidelines.md` (esta skill, `sooft`). Cargá el archivo correspondiente cuando el flujo lo pida. Toda skill que toque seguridad, testing o Git los referencia por nombre, sin recopiar las reglas.

### §6.1 Seguridad
Política completa en `assets/policies/security-guidelines.md`. Ante cualquier cambio que toque seguridad, auth, cifrado, PII o dependencias: cargá ese archivo.

### §6.2 Testing
Política completa en `assets/policies/testing-guidelines.md`. Ante cualquier cambio que requiera tests (features, bugs, refactors): cargá ese archivo.

### §6.3 Arquitectura
- OBLIGATORIO respetar la arquitectura en capas del arquetipo: API > Servicio > Dominio > Repositorio. Cada capa depende SOLO de la inmediata inferior.
- OBLIGATORIO: lógica de negocio en Servicio/Dominio. PROHIBIDO lógica de negocio en controllers, filtros, interceptores o config. PROHIBIDO acceder a repositorios/datasources/HTTP clients desde el paquete `domain`.
- PROHIBIDO dependencias circulares entre módulos. PROHIBIDO mezclar patrones dentro de un módulo.
- PROHIBIDO sin un ADR aprobado (recurso `internal/sooft-adr.md`): cambiar el patrón arquitectónico, cambiar el protocolo de comunicación (REST↔gRPC, sync↔eventos), cambiar la estrategia de persistencia, romper un contrato de API de forma retroincompatible. OBLIGATORIO versionar las APIs (v2, v3) en vez de romper la v1.
- OBLIGATORIO usar solo frameworks/librerías del catálogo aprobado por Arquitectura. Fuera del catálogo → marcar la tarea BLOCKED y documentar.

### §6.4 Trazabilidad del código IA
- OBLIGATORIO marcar todo código generado: `// [IA-generated] SOOFT — revisar antes de mersooft. Ticket: <TICKET-XXXXX>` (ajustá el comentario al lenguaje: `//` Java/JS/TS/C#, `#` Python).
- OBLIGATORIO trailer en commits con código IA: `AI-Generated: true` y `AI-Reviewed-By: <usuario>`.
- OBLIGATORIO revisión humana (gate 4 de §3) antes del PR. La IA propone; el developer es responsable. OBLIGATORIO registrar en `.sooft/evidence.md` qué archivos son IA-generated y quién revisó.
- PROHIBIDO remover los marcadores `[IA-generated]` para ocultar el origen.

### §6.5 Documentación
- OBLIGATORIO: comentarios explican el **por qué**, no el qué. PROHIBIDO comentarios que repiten el nombre del método/variable.
- OBLIGATORIO `.sooft/evidence.md` completo antes del PR (qué se implementó, cómo se verificó, decisiones). PROHIBIDO dejarlo vacío, con plantilla sin completar o ausente al abrir el PR.
- OBLIGATORIO versionar el contrato OpenAPI/Swagger en el MISMO commit que el código. PROHIBIDO en commit separado posterior.
- Si el cambio altera comportamiento documentado del proyecto (contratos públicos, comandos, instalación, estructura o uso descrito en el README u otra doc), el **PLAN** incluye una tarea explícita para actualizar esa doc. Cambios internos sin impacto en la doc NO la tocan. PROHIBIDO actualizar doc por fuera de una tarea del plan aprobado.
- PROHIBIDO documentar comportamiento aún no implementado como si existiera.

### §6.7 Git
Política completa en `assets/policies/git-guidelines.md`. Ante commits, branches, PRs o code review: cargá ese archivo.

### §6.6 el issue tracker
- Prefijos conocidos: **INC, RITM, CHG, REQ, STRY** (y otros que use la instancia). Un prefijo no reconocido **NO bloquea**: registrá el ticket tal cual, inferí el tipo de trabajo por el contenido y seguí. PROHIBIDO frenar o interrogar por el prefijo.
- Lectura del ticket: si el **MCP del issue tracker** está disponible en la sesión (sus tools aparecen), leé el ticket con esas tools.
- Si el MCP **no** está disponible, NO bloquees: pedí que el developer pegue el contenido del ticket y arrancá el discovery con eso. **NUNCA sugerás abrir una nueva sesión como solución en un contexto de trabajo** (eso solo aplica la primera vez, justo después de correr `/sooft` por primera vez — de eso se ocupa el init). Si los archivos `.vscode/mcp.json` y `.mcp.json` ya existen (los dejó `/sooft`), el problema **no es de sesión** sino de entorno: el Trust del server en VS Code no fue aceptado (un clic en el diálogo de confianza cuando VS Code lo muestra por primera vez) o el servidor no es alcanzable desde la red del developer. Repetir "abrí una sesión nueva" en este caso crea un loop infinito — no lo hagas. El registro manual de un servidor se hace con `/mcp add` (abre un formulario, Tab/Ctrl+S; nunca toma la URL en la misma línea) o, desde la shell, `copilot mcp add <nombre-del-tracker> --type http --url "<URL>" --tools "*"`, siempre con headers vacíos salvo que el server requiera auth (un `Authorization: Bearer` da 401 si no la tiene).
- En cualquier caso: PROHIBIDO inventar, inferir o completar datos que no figuren en el ticket; PROHIBIDO escribir en el issue tracker en nombre del developer.
- El ticket es **opcional y no bloqueante** para arrancar. Si existe, OBLIGATORIO registrarlo en `.sooft/state.json`, `.sooft/evidence.md`, el nombre de rama (`{tipo}/<TICKET>-<desc>`) y el PR.

---

## §7. Contexto de Sooft (fijo)

- **Tickets:** el issue tracker (INC, RITM, CHG, REQ, STRY y otros prefijos de la instancia) — opcional, no bloqueante.
- **Integración activa:** el issue tracker (tickets). El repositorio es Git; otras integraciones (calidad, SAST) se suman cuando el proyecto las configure.
- **Stack:** Java, .NET (C#), Python, TypeScript, JavaScript — detectá el del proyecto y usá su runner y framework de tests.
- **Idioma:** español rioplatense (vos/usá) en todo output y artefacto.

---

## §8. SIEMPRE / NUNCA (binario)

**SIEMPRE:** leés `.sooft/state.json` al inicio y mostrás la fase; ejecutás el algoritmo de §0; usás el slug del ticket como carpeta (`docs/{tipo}/{slug}/`); actualizás `.sooft/evidence.md` al completar cada paso; mostrás el `next_step`; marcás el código generado con `[IA-generated]`.

**NUNCA:** escribís código fuera del predicado de §2; saltás un gate aunque el developer lo pida; hardcodeás secretos; logueás PII; asumís una aprobación sin confirmación explícita; creás archivos fuera de `docs/`, `.sooft/` o `.worktrees/` sin instrucción; avanzás con `phase` inconsistente o no enumerado.

---

## Qué NO hacer

- PROHIBIDO tratar esta skill como opcional: es el PASO 1 de todo trabajo de código (§0).
- PROHIBIDO usar un `phase` que no esté enumerado en §4.
- PROHIBIDO modificar las frases canónicas de §3.
- PROHIBIDO degradar a Haiku algo que toque seguridad, arquitectura o código de producción (§5).
- Ante cualquier caso no cubierto por estas reglas: **HALT** y preguntá al developer.
