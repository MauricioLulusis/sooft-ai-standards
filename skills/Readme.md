# SOOFT como paquete de skills

Este directorio empaqueta la metodología **SOOFT** (Sooft Engineering AI Rails) de Sooft Technology como **skills self-contained**, distribuibles con [`skills`](https://www.skills.sh) (`npx skills add`). Las skills entry point viven en `skills/<nombre>/SKILL.md`. Las **primitivas internas** NO son skills: son archivos de recurso dentro de la constitución, en `skills/sooft/internal/<nombre>.md`, y viajan con la skill `sooft`. Las dependencias se referencian **por nombre** (entre skills) o **por archivo** (los recursos `internal/*.md`), no por path absoluto.

## Entry points — invocadas por el developer

Estas son las skills que el developer invoca directamente con un slash command o en lenguaje natural.

| Skill                       | Para qué                                                                                                                                        |
| --------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------- |
| **`sooft`**                  | **La constitución.** Cargala SIEMPRE primero: principios, gates de aprobación, máquina de estados, switcheo de modelos y reglas no negociables. |
| `sooft-development`          | **Router** de la rama FEATURE: feature, refactor, migración                                                                                     |
| `sooft-bugs`                 | **Router** de la rama BUG: bug, regresión, comportamiento roto                                                                                  |
| `sooft-security-remediation` | **Router** de la rama SECURITY: vulnerabilidades, CVEs, auditorías                                                                              |
| `sooft-status`               | Ver estado actual del workflow                                                                                                                  |
| `sooft-incident-response`    | Incidente en producción                                                                                                                         |

## Primitivas internas — recursos de `sooft` (NO son slash commands)

El developer no las invoca. **No son skills**: son archivos de recurso que viven dentro de la constitución, en `skills/sooft/internal/<nombre>.md`, y viajan con la skill `sooft` (que se carga siempre). Como no tienen `SKILL.md`, **no se exponen como slash commands** `/sooft-*` en ningún agente, y **no requieren** `INSTALL_INTERNAL_SKILLS`. Los routers (y la propia `sooft`) las cargan **leyendo el archivo** cuando el flujo lo pide.

### Multi-router (cargadas desde más de un router)

| Recurso                             | Cargado desde                                                |
| ----------------------------------- | ------------------------------------------------------------ |
| `internal/sooft-discovery.md`        | `sooft-development`, `sooft-bugs`, `sooft-security-remediation` |
| `internal/sooft-implement-task.md`   | `sooft-development`, `sooft-bugs`, `sooft-security-remediation` |
| `internal/sooft-validation.md`       | los tres routers, via `/review`                              |
| `internal/sooft-code-review-gate.md` | los tres routers                                             |
| `internal/sooft-evidence.md`         | transversal — múltiples skills                               |

### De fase/artefacto (cargadas por el agente en el momento correcto, no por el developer)

| Recurso                          | El agente lo carga cuando                                                   |
| -------------------------------- | --------------------------------------------------------------------------- |
| `internal/sooft-adr.md`           | surge una decisión de arquitectura significativa (desde `sooft-development`) |
| `internal/sooft-test-strategy.md` | hay que definir qué y cómo testear, durante el planning                     |
| `internal/sooft-release.md`       | el PR fue aprobado y hay que preparar el deploy                             |
| `internal/sooft-maintenance.md`   | el trabajo es tipo chore/mantenimiento (desde `sooft-development`)           |

### Assets embebidos en cada router (no son skills standalone)

**`sooft-development/assets/`**
- `prd.md` — PRD colaborativo con el developer
- `technical-spec.md` — SPEC técnica para cambios complejos
- `implementation-plan.md` — generar/corregir `PLAN.md` con TDD y exploración de tests

**`sooft-bugs/assets/`**
- `bug-analysis.md` — causa raíz → `ANALYSIS.md`
- `bug-reproduction.md` — test rojo de reproducción antes del fix
- `fix-plan.md` — `FIX_PLAN.md` del bug

**`sooft-security-remediation/assets/`**
- `security-findings.md` — relevar hallazgos → `FINDINGS.md`
- `security-scope.md` — confirmar scope de remediación
- `remediation-plan.md` — `REMEDIATION_PLAN.md`

**`sooft/assets/`**
- `init.md` — inicialización de `.sooft/`, detección de stack e integraciones, configuración de MCP

**`sooft/assets/policies/`** (fuente de verdad — lineamientos compartidos)
- `security-guidelines.md` — lineamientos de seguridad
- `testing-guidelines.md` — lineamientos de testing
- `git-guidelines.md` — lineamientos de Git: conventional commits, branching SOOFT, PRs, code review, historial, merge

## Instalación — un solo comando, y después `/sooft`

Desde el proyecto destino, instalando todas las skills para todos los agentes (Claude Code, Copilot, etc.):

```bash
npx skills add <repo-sooft> -a '*'
```

Reemplazá `<repo-sooft>` por la URL del repo donde viva este paquete (soporta `owner/repo`, URL completa de GitHub/GitLab, GitHub Enterprise self-hosted como `https://git.sooft.tech/...`, o cualquier git URL). `skills` clona por git, así que usa las credenciales git que ya tengas para repos privados internos. Las **primitivas internas** viajan solas: son archivos de recurso dentro de la skill `sooft` (`sooft/internal/*.md`), no skills, así que se copian junto con `sooft` sin ningún flag especial y **no** aparecen como slash commands.

Después, **una sola vez por proyecto**, corré `/sooft` (o pedíselo en lenguaje natural). Ese comando es el **único punto de arranque**: carga la constitución `sooft` (banner + auto-setup), instala los hooks, materializa los custom agents de Copilot CLI en `.github/agents/` y crea `.sooft/`. A partir de ahí Copilot queda listo para `/sooft-development`, `/sooft-bugs`, `/sooft-security-remediation`, etc.

> Sin fricción: tras `/sooft` podés trabajar en la **misma** sesión — al correr `/sooft` se carga la constitución `sooft`, así que el discovery y los gates rigen desde ya. El banner y el trigger toman efecto automáticamente desde la próxima sesión (el harness de Copilot los cachea al iniciar la sesión; no hay que reiniciar nada a mano).

## Determinismo: capa de hooks auto-instalable (Copilot CLI **y** GUI de VS Code)

Una skill se carga **bajo demanda** — el agente la invoca según su `description` —, así que por sí solas las skills no garantizan que el discovery/gate se dispare en cada pedido. Para cerrar esa brecha **sin pedirle al dev más que `npx skills add` + `/sooft`**, `sooft` trae un **auto-setup** (ver su sección §0.1): instala los **hooks de agente de Copilot** y los **custom agents de Copilot CLI** (que vienen como assets de la skill). Los hooks van en **dos ubicaciones**, porque tanto el CLI como la GUI de VS Code leen el mismo formato desde ahí:

- `~/.copilot/hooks/sooft.json` → **user-level**, lo lee el CLI (y también la GUI). Una vez por máquina.
- `.github/hooks/sooft.json` → **repo-level**, lo lee la **GUI de VS Code** por defecto y el CLI. Queda versionado: el hook viaja con el repo para todo el equipo. Una vez por proyecto.

Una vez instalados, los corre el **harness de Copilot, no el agente** (no gastan tokens de razonamiento) y dan la parte determinista:

- **`sessionStart`** → muestra el banner e **inyecta el recordatorio de cargar `sooft`** en cada sesión nueva (hace determinista el disparo).

Los custom agents se copian desde `skills/sooft/assets/agents/` hacia `.github/agents/` del proyecto destino, sin pisar archivos existentes. Así los subagentes viajan con `npx skills add` y quedan en la ubicación que Copilot CLI usa para cargarlos.

**Notas/limitaciones de esta v1:**
- El auto-setup cubre **Copilot CLI y la GUI de VS Code** (ambas superficies leen `~/.copilot/hooks/` y `.github/hooks/`). En **Claude Code** el equivalente son hooks de `settings.json` (otro mecanismo).
- El auto-setup se dispara al correr `/sooft` (carga `sooft` → §0.1). Es idempotente: si ya estaban instalados, no los reescribe.
