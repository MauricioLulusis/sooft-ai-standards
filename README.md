# sooft-ai-standards v0.1.0

Repo central de estándares de IA para Sooft Technology. Define cómo trabajan los agentes en el ciclo de desarrollo: qué pueden hacer, qué está prohibido, qué evidencia generan y cómo se integran con las herramientas de Sooft.

El corazón es **SOOFT** (Sooft Engineering AI Rails): la metodología que impone un pipeline con gates de aprobación humana, organizado por las fases del ciclo de vida del software. Se distribuye como **skills** (`skills/<nombre>/SKILL.md`) instalables con `npx skills add`.

---

## Los 3 principios (síntesis)

> Esta es la síntesis operativa para quien recién llega. El detalle completo son los **9 principios fundacionales** más abajo — estos 3 son cómo se perciben en el día a día, no un set alternativo.

**1. Sin vibe coding**
El agente no escribe una línea de código sin un PLAN aprobado. Sin aprobación explícita del developer, no avanza.

**2. Determinismo**
Templates fijos, skills con pasos exactos, evals que verifican comportamiento. El agente no improvisa donde el proceso debe ser exacto.

**3. Accesible para cualquier developer**
No se necesita saber prompting. El skill guía cada paso. El developer solo aprueba o rechaza.

---

## Sobre qué se construye

sooft-ai-standards no inventa desde cero ni copia una sola herramienta: **sintetiza tres fuentes en una metodología propia de Sooft.**

| Fuente | Qué aporta |
|--------|-----------|
| **sooft-way** | Los 9 principios fundacionales de la metodología |
| **SpecKit** (referencia) | `[NEEDS CLARIFICATION]`, criterios de éxito medibles, verificación de consistencia, change history, update mode |
| **SOOFT** (propio) | Las 6 fases del ciclo de vida, el switcheo de modelos por complejidad, las integraciones de Sooft y los guardrails duros |

### Los 9 principios fundacionales

```
1. Gate-driven         → no se avanza en un punto crítico sin aprobación explícita
2. PRD colaborativo    → el scope se afina con un ida y vuelta breve antes de cerrarlo
3. Spec cuando importa → SPEC técnica solo para cambios complejos o riesgosos
4. Artefactos por tipo → docs/feats/, docs/bugs/, docs/security/, docs/incidents/
5. Worktree-first      → trabajo aislado en .worktrees/ antes de tocar ramas compartidas
6. Nombres tipo Git    → feat, fix, hot-fix, chore, security
7. Tool-agnostic       → las herramientas se detectan o configuran, no se asumen
8. Security-by-default → todo cambio pasa por validación, tests y controles de seguridad
9. Auditabilidad       → cada trabajo deja decisión, plan, evidencia e historial
```

Estos principios están **embebidos en cada componente** del sistema (skills, reglas, hooks, templates), no en un manual aparte. El detalle de la metodología y de dónde se hace cumplir cada principio está en [`skills/Readme.md`](skills/Readme.md) y en la skill [`sooft`](skills/sooft/SKILL.md) (la constitución).

---

## Switcheo automático de modelos

SOOFT separa **orquestación** de **ejecución especializada** para no gastar capacidad de más en tareas mecánicas:

| Superficie | Cómo decide modelo | Fuente |
|---|---|---|
| Skills principales | El orquestador clasifica complejidad: simple, estándar o compleja | [`skills/sooft/SKILL.md`](skills/sooft/SKILL.md) |
| Copilot CLI subagents | Cada custom agent define `model` y fallbacks por rol | [`.github/agents/MODELS.md`](.github/agents/MODELS.md) |

Los **skills principales** siguen gobernando discovery, gates, estado y aprobación humana. Los **custom agents de Copilot CLI** en `.github/agents/` solo cubren primitivas especializadas —por ejemplo PRD, SPEC, PLAN, testing, security review o evidence— con modelo y tools acotadas por rol.

El sesgo sigue siendo conservador: ante cualquier señal de seguridad o arquitectura, se usa un modelo fuerte o su fallback documentado.

---

## Cómo interactúa el developer

| Comando | Cuándo usarlo |
|---|---|
| `/sooft` | Inicializar el proyecto por primera vez (crea `.sooft/state.json`) |
| `/sooft-development` | Feature nueva o refactor — carga el skill de desarrollo |
| `/sooft-migrations` | Migrar de versión o tecnología (Java 8→21, Node, .NET) — carga el skill de migraciones |
| `/sooft-bugs` | Bug reportado o reproducible — carga el skill de bugs |
| `/sooft-security-remediation` | Vulnerabilidad o hallazgo de SAST/análisis estático — carga el skill de seguridad |
| `/sooft-status` | Consultar la fase actual del pipeline, artefactos y bloqueos |
| `/sooft-incident-response` | Incidente en producción que requiere hotfix urgente |
| `/sooft-checkpoint` | Forzar un snapshot de `STATUS.md` sin cambiar de fase (compaction manual) |

Estos **8 son los únicos slash commands** que invoca el developer. La revisión pre-PR (validación de seguridad, arquitectura y tests) corre **dentro** del flujo de cada router, no como comando aparte. Los skills se cargan solo cuando se necesitan; también se puede interactuar en lenguaje natural y el agente identifica la fase y el skill correcto.

---

## Flujo del ciclo de vida — fases SOOFT

| Fase | Descripción |
|---|---|
| `01-alcance` | Descubrir qué hay que hacer: cargar el requerimiento, analizar, generar y aprobar el PRD |
| `02-diseño` | Especificación técnica y decisiones de arquitectura para features complejas (SPEC) |
| `03-desarrollo` | Implementar el código según el PLAN aprobado, corregir bugs, remediar vulnerabilidades |
| `04-pruebas` | Estrategia de tests, validación de cobertura y revisión pre-PR |
| `05-despliegue` | Release, notas de deploy y evidencia de salida a producción |
| `06-operacion-mantenimiento` | Incidentes en producción, mantenimiento correctivo y mejoras operativas |

Cada fase del ciclo de vida se cubre con una o varias **skills** en `skills/` (instrucciones deterministas para el agente). Las skills se referencian entre sí por nombre; la constitución `sooft` es la fuente de verdad.

---

## Responsabilidades de código

| Acción | Developer | Agente |
|---|---|---|
| Escribir código | No (salvo correcciones menores) | Si — solo con `phase == PLAN_APPROVED` o `IMPLEMENTING` |
| Aprobar PRD | Si — obligatorio | No |
| Aprobar SPEC | Si — obligatorio (si aplica) | No |
| Aprobar PLAN | Si — obligatorio | No |
| Generar artefactos (PRD, SPEC, PLAN, TASKS) | No | Si |
| Ejecutar hooks y checks automáticos | No | Si |
| Aprobar o rechazar el resultado de la validación pre-PR | Si | No |
| Abrir el PR en el repositorio | Si — acción manual | No |

---

## Estructura del repo

```
sooft-ai-standards/
├── README.md                         → este archivo (punto de entrada + glosario)
├── AGENTS.md                         → reglas para el agente (Claude Code)
├── GOVERNANCE.md                     → controles, aprobaciones y auditoría
├── SECURITY.md                       → restricciones de seguridad
├── CONTRIBUTING.md · CHANGELOG.md · NOTICE.md
├── .github/                          → capa de compatibilidad con GitHub Copilot
│   ├── copilot-instructions.md       → mismas reglas para Copilot (CLI y VS Code)
│   ├── agents/                       → custom agents de Copilot CLI para primitivas SOOFT + MODELS.md
│   ├── hooks/                        → hooks de Copilot (banner + guardrails deterministas)
│   ├── CODEOWNERS
│   └── README-copilot.md             → setup y uso en Copilot
├── .vscode/                          → settings + mcp.json (server el issue tracker) para VS Code
├── .mcp.json                         → server MCP del issue tracker para el CLI de Copilot
├── skills/                           → la metodología SOOFT como skills
│   │                                    (cada skill trae SKILL.md + workflow.yml — máquina de
│   │                                    estados declarativa, agnóstica a la herramienta)
│   ├── sooft/                         → constitución (SKILL.md) + assets
│   │   └── assets/
│   │       ├── prompts/             → prompt files (/sooft, /sooft-development, …)
│   │       ├── templates/            → PRD, SPEC, PLAN, PRINCIPLES, evidence, ADR, discovery-checklist
│   │       ├── drivers/              → prompts base por tarea (code-review, technical-design…)
│   │       ├── reviews/              → checklists de revisión (arquitectura, seguridad, compliance)
│   │       ├── archetypes/           → arquetipos de proyecto por tipo (backend/frontend/migración)
│   │       ├── internal/             → primitivas internas como recursos .md (NO skills, NO slash commands):
│   │       │                           discovery, implement-task, code-review-gate, validation, evidence +
│   │       │                           adr, test-strategy, release, maintenance
│   │       ├── init.md               → init de .sooft/, detección de stack/integraciones, MCP
│   │       └── banner.txt + sooft.json → hook sessionStart (banner + trigger)
│   ├── sooft-development/ · sooft-bugs/ · sooft-security-remediation/ · sooft-migrations/   → routers
│   ├── sooft-status/ · sooft-incident-response/ · sooft-checkpoint/   → skills developer-invocables
│   └── Readme.md                     → índice de skills e instalación (npx skills add)
├── evals/                            → evaluaciones de comportamiento del agente (gate-safety)
└── ci/                               → configuración de integración continua (validate.yml)
```

---

## Cómo empezar

Hay **dos formas** de usar SOOFT:

- **Sin instalar (piloto):** dale al agente este repo como contexto y decile *"seguí sooft-ai-standards, necesito X"*. Funciona toda la metodología (fases, gates, templates); lo único que falta es el bloqueo físico de los hooks.
- **Instalado (enforcement completo):** los pasos de abajo. Suma los hooks de agente que bloquean físicamente un commit con secretos o PII.

**Paso 1 — Instalar las skills** (una sola vez por proyecto)

```bash
npx skills add <repo-sooft> -a '*'
```

Clona e instala todas las skills de SOOFT para todos los agentes (Claude Code, Copilot, etc.). Reemplazar `<repo-sooft>` por la URL de este repo. Las **primitivas internas** viajan como archivos de recurso dentro de la skill `sooft` (`sooft/internal/*.md`): no son skills, no aparecen como slash commands y se copian junto con `sooft` sin ningún flag especial. Detalle en [`skills/Readme.md`](skills/Readme.md).

> **Los guardrails duros (hooks) se instalan solos.** No hace falta correr ningún script a mano: al ejecutar `/sooft` (Paso 2), la skill `sooft` instala los hooks de Copilot en `~/.copilot/hooks/` y `.github/hooks/`. Son los que bloquean físicamente un commit con secretos o PII y disparan el discovery/gate de forma determinista.

**Paso 2 — Inicializar el proyecto** (una sola vez por repo)

```
/sooft [ticket]
```

Carga la constitución `sooft` (banner + auto-setup de hooks), detecta el stack y las integraciones, y crea `.sooft/` (`state.json`, `config.json`, `evidence.md`, `discovery-checklist.json`). El ticket del issue tracker es opcional.

**Discovery (obligatorio para código/PR)**

El archivo `.sooft/discovery-checklist.json` registra la ronda inicial de discovery: entre 1 y 5 preguntas con sus respuestas. La Regla #1 de `copilot-instructions.md` hace que el agente lo complete antes de tocar código, y el hook `sessionStart` inyecta el recordatorio en cada sesión nueva.

**Paso 3 — Elegir el skill según el tipo de trabajo**

```
/sooft-development     → feature nueva o migración
/sooft-bugs            → bug reportado
/sooft-security-remediation → vulnerabilidad o hallazgo de SAST/análisis estático
```

O describir el trabajo en lenguaje natural y el agente carga el skill correcto.

### Tu primer trabajo, paso a paso

1. **`/sooft [ticket]`** — el agente detecta el stack y crea `.sooft/`.
2. **Describí el trabajo** en lenguaje natural: *"necesito agregar paginación al listado de clientes"*.
3. **Respondé el discovery** — el agente pregunta solo lo que no puede inferir.
4. **Aprobá el PRD** ⬛ — el agente para y espera tu OK.
5. **(Si es complejo) aprobá la SPEC** ⬛.
6. **Aprobá el PLAN** ⬛ — recién acá el agente escribe código.
7. **El agente corre la validación pre-PR** — seguridad, arquitectura y tests, dentro del flujo.
8. **Abrís el PR** en el repositorio.

### Lo que tenés que recordar

- El agente **no escribe código hasta que aprobás el PLAN**. Es a propósito.
- Si no sabe algo, lo marca `[NEEDS CLARIFICATION]` en vez de inventarlo.
- Para tareas simples usa un modelo liviano; para lo complejo, el más potente. Vos no configurás nada.

---

## Compatibilidad con herramientas

La misma metodología funciona en dos herramientas:

| Herramienta | De dónde lee las reglas | Cómo se invocan los flujos |
|-------------|------------------------|----------------------------|
| **Claude Code** | `AGENTS.md` + skills (`skills/`) | skills / lenguaje natural |
| **GitHub Copilot** (CLI y VS Code) | `.github/copilot-instructions.md` + `.github/prompts/` | `/sooft`, `/sooft-development`, `/sooft-bugs`, `/sooft-security-remediation`, `/sooft-status`, `/sooft-incident-response` |

> **VS Code Copilot requiere una setting** para aplicar las instrucciones: `github.copilot.chat.codeGeneration.useInstructionFiles: true`. Sin eso, la GUI ignora las reglas (el CLI no la necesita). Setup completo en [`.github/README-copilot.md`](.github/README-copilot.md).

---

## Estado del pipeline

Cada sesión SOOFT tiene un `.sooft/state.json` con la fase actual, el último paso y el próximo paso. El campo `type` (`feat` · `bug` · `security`) define qué rama de la máquina de estados aplica.

La máquina **no es lineal**: modela rechazos (`*_REJECTED`), hallazgos de seguridad (`SECURITY_FINDINGS`), revisión de código IA (`CODE_REVIEW_PENDING`), bloqueos (`BLOCKED`) y cancelación (`CANCELLED`). La definición canónica completa está en la skill [`sooft`](skills/sooft/SKILL.md) (§ máquina de estados).

Camino feliz de un **feature**:

```
IDLE → REQUIREMENT_LOADED → ANALYZED → PRD_PENDING → PRD_APPROVED →
[SPEC_PENDING → SPEC_APPROVED] → PLAN_PENDING → PLAN_APPROVED →
IMPLEMENTING → VALIDATING → CODE_REVIEW_PENDING → REVIEW_DONE → PR_OPEN → DONE
```

Las ramas **bug** y **security** tienen sus propios estados hasta converger en `IMPLEMENTING` (ver la skill [`sooft`](skills/sooft/SKILL.md), §4 máquina de estados). `SPEC_*` es opcional, solo para features complejas.

Formato del archivo:

```json
{
  "phase": "VALIDATING",
  "type": "feat",
  "ticket": "TICKET-XXXXX",
  "owner": "<apellido del developer si está disponible, sino null — NUNCA el email>",
  "created_at": "2026-06-02",
  "last_step": "implement",
  "next_step": "run-validations"
}
```

---

## Contexto Sooft Technology

- **Tickets**: el issue tracker del equipo (Jira, GitHub Issues u otro) (opcional, no bloqueante)
- **Repo**: Git
- **Integración activa**: el issue tracker (tickets). Otras integraciones (calidad, SAST) se suman cuando el proyecto las configure.
- **Stack**: Java, .NET (C#), Python, TypeScript, JavaScript
- **Idioma**: español rioplatense
- **Seguridad**: sin secretos hardcodeados, sin PII en logs, menor privilegio siempre

---

## Glosario

| Término | Definición |
|---|---|
| **SOOFT** | Sooft Engineering AI Rails — la metodología central, distribuida como skills |
| **Gate** | Punto donde el agente para y espera aprobación humana |
| **Guardrail** | Límite que el agente no puede cruzar (blando = regla; duro = hook de agente) |
| **Skill** | Instrucción que define cómo el agente ejecuta una tarea (`SKILL.md`) |
| **Router** | Skill que conduce una rama de trabajo (development, bugs, security) y delega en primitivas |
| **Primitiva interna** | Recurso `.md` reutilizable cargado por archivo desde los routers y la constitución (`skills/sooft/internal/<nombre>.md`); no es una skill ni un slash command |
| **Fase** | Etapa del ciclo de vida (alcance, diseño, desarrollo, pruebas, despliegue, operación) |
| **PRD** | Product Requirements Document — el qué y para qué |
| **SPEC** | Especificación técnica — el cómo (solo para lo complejo) |
| **PLAN** | Descomposición en tareas implementables |
| **Worktree** | Checkout aislado de git donde ocurre el trabajo (`.worktrees/`) |
| **state.json** | El estado del pipeline de un trabajo (`.sooft/state.json`) |
| **evidence.md** | Registro auditable de lo que se hizo (`.sooft/evidence.md`) |

---

Para proponer cambios, abrí un PR y notificá al equipo de AI Platform.
