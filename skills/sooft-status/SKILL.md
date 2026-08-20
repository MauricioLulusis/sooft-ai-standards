---
name: sooft-status
description: Usar en cualquier momento para ver el estado actual del workflow, la fase, los artefactos generados y el próximo paso.
---

# Status

> Esta skill es parte de SOOFT. Antes de usarla, seguí la skill `sooft` (principios, gates de aprobación, máquina de estados y reglas no negociables).

> **Proyección estructurada:** la tabla `next_step` de este skill también vive en `workflow.yml`
> (mismo directorio) — formato declarativo, agnóstico a la herramienta.

Este skill es READ-ONLY. No modifica nada.

## Qué hace

1. Lee `.sooft/state.json`. Si no existe: informar que no hay sesión activa y sugerir `/sooft`.
2. Lee `.sooft/config.json` si existe.
3. Lee `docs/{tipo}/{slug}/STATUS.md` si existe (snapshot semántico compacto del proyecto, contrato en `skills/sooft/assets/status-template.md`).
4. Verifica existencia y contenido de artefactos según la fase actual.
5. Determina el próximo paso según la fase.
6. Reporta todo como JSON estructurado.

## Pasos

### Paso 1 — Leer state.json

Intentá leer `.sooft/state.json`.

Si el archivo no existe, reportá:

```json
{
  "version": "0.1.0",
  "phase": "IDLE",
  "block": "No hay sesión activa. Ejecutá /sooft para comenzar.",
  "next_step": "init"
}
```

Y detené la ejecución aquí.

### Paso 2 — Leer config.json

Intentá leer `.sooft/config.json`.

Si existe, extraé:
- `integrations.tracker`
- `integrations.repository`

Si no existe, estos valores son `"unknown"`.

### Paso 3 — Determinar el slug y tipo de tarea

A partir de `.sooft/state.json`, extraé el campo `slug` y `type` (si existen).

El tipo puede ser `feat`, `bug`, o `security`.

Rutas de artefactos según tipo:

| Tipo | PRD/BUG | SPEC/ANALYSIS | PLAN/FIX_PLAN | Evidence | Status |
|------|---------|---------------|---------------|----------|--------|
| feat | `docs/feats/{slug}/PRD.md` | `docs/feats/{slug}/SPEC.md` | `docs/feats/{slug}/PLAN.md` | `.sooft/evidence.md` | `docs/feats/{slug}/STATUS.md` |
| bug | `docs/bugs/{slug}/BUG.md` | `docs/bugs/{slug}/ANALYSIS.md` | `docs/bugs/{slug}/FIX_PLAN.md` | `.sooft/evidence.md` | `docs/bugs/{slug}/STATUS.md` |
| security | `docs/security/{slug}/FINDINGS.md` | null | `docs/security/{slug}/REMEDIATION_PLAN.md` | `.sooft/evidence.md` | `docs/security/{slug}/STATUS.md` |

Si el tipo no está disponible, usá las rutas de `feat` como default.

### Paso 4 — Verificar artefactos

Para cada artefacto relevante, determiná su estado:

- `"ok"` — el archivo existe y tiene contenido
- `"missing"` — el archivo no existe
- `"empty"` — el archivo existe pero está vacío
- `"not_required"` — el artefacto no aplica para esta fase o tipo

Reglas de `not_required`:
- `spec` es `not_required` para tipo `bug` y `security`
- `spec` es `not_required` para fases anteriores a `SPEC_PENDING` en tipo `feat`, salvo que ya exista
- `status` es `not_required` para `phase == IDLE`

### Paso 4.5 — Lectura semántica de STATUS.md

Si `STATUS.md` existe (`status_status == "ok"`), extraer para el reporte:

- `phase_in_status`: valor del campo `Fase` en la sección Metadatos.
- `decisions_recent`: los últimos 3 bullets de la sección "Decisiones clave tomadas".
- `open_risks_count`: cantidad de filas de la tabla "Riesgos abiertos" (0 si dice `_Ninguno._`).
- `next_step_from_status`: valor de la sección "Próximo paso".

Si `STATUS.md` **no existe** y `phase != IDLE`, agregar al reporte una recomendación:
`"STATUS.md no existe. Considerá backfill vía /sooft-checkpoint o transición de fase."`

Este skill **NO** genera `STATUS.md` automaticamente — respeta el opt-in explícito del developer.

### Paso 5 — Determinar next_step y block

El vocabulario de fases es el de la máquina de estados de SOOFT (fuente única) — ver la skill
`sooft` (§4 Máquina de estados). Las fases dependen del `type`: `feat`, `bug` y `security`
tienen su propia secuencia de alcance/plan hasta que convergen en `IMPLEMENTING`.

**Comunes y tronco compartido:**

| Fase | next_step |
|------|-----------|
| IDLE | init |
| REQUIREMENT_LOADED | development (feat), bugs (bug), security-remediation (security) |
| IMPLEMENTING | Continuar implementación o ejecutar /review |
| VALIDATING | Ejecutar /review: tests, linter, análisis de calidad, SAST + análisis del diff |
| SECURITY_FINDINGS | Remediar hallazgos críticos/altos del SAST (o excepción de Ciberseguridad), luego volver a VALIDATING |
| CODE_REVIEW_PENDING | Revisar y aprobar el código [IA-generated] |
| REVIEW_DONE | Abrir el PR en la rama target (acción manual) |
| PR_OPEN | Esperar aprobación del PR; al aprobarse, confirmar "PR aprobado" |
| DONE | Sesión completa (terminal) |
| BLOCKED | Resolver el bloqueo; vuelve a `previous_phase` |
| CANCELLED | Trabajo abandonado (terminal) |

**Rama feat:**

| Fase | next_step |
|------|-----------|
| ANALYZED | Generar el PRD |
| PRD_PENDING | Aprobar o rechazar el PRD |
| PRD_REJECTED | El agente corrige el PRD y vuelve a presentarlo |
| PRD_APPROVED | Continuar con SPEC (si aplica) o PLAN |
| SPEC_PENDING | Aprobar o rechazar la SPEC |
| SPEC_REJECTED | El agente corrige la SPEC y vuelve a presentarla |
| SPEC_APPROVED | Continuar con el PLAN |
| PLAN_PENDING | Aprobar o rechazar el PLAN |
| PLAN_REJECTED | El agente corrige el PLAN y vuelve a presentarlo |
| PLAN_APPROVED | Implementar |

**Rama bug:**

| Fase | next_step |
|------|-----------|
| BUG_DOCUMENTED | Analizar la causa raíz |
| BUG_ANALYZED | Escribir el test de reproducción |
| BUG_REPRODUCED | Generar el FIX_PLAN |
| FIX_PLAN_PENDING | Aprobar o rechazar el FIX_PLAN |
| FIX_PLAN_REJECTED | El agente corrige el FIX_PLAN y vuelve a presentarlo |
| FIX_PLAN_APPROVED | Implementar el fix |

**Rama security:**

| Fase | next_step |
|------|-----------|
| FINDINGS_DOCUMENTED | Confirmar el scope a remediar |
| SCOPE_PENDING | El developer confirma severidades/IDs en scope |
| SCOPE_CONFIRMED | Generar el REMEDIATION_PLAN |
| REMEDIATION_PLAN_PENDING | Aprobar o rechazar el plan de remediación |
| REMEDIATION_PLAN_REJECTED | El agente corrige el plan y vuelve a presentarlo |
| REMEDIATION_PLAN_APPROVED | Aplicar los fixes |

Determinar `block`:

- Si la fase es `PRD_PENDING` y `artifacts_status.prd != "ok"`: `"PRD no encontrado o vacío en la ruta esperada."`
- Si la fase es `SPEC_PENDING` y `artifacts_status.spec != "ok"`: `"SPEC no encontrado o vacío en la ruta esperada."`
- Si la fase es `PLAN_PENDING`, `FIX_PLAN_PENDING` o `REMEDIATION_PLAN_PENDING` y `artifacts_status.plan != "ok"`: `"Plan no encontrado o vacío en la ruta esperada."`
- Si la fase es `VALIDATING`, `CODE_REVIEW_PENDING`, `REVIEW_DONE` o `PR_OPEN` y `artifacts_status.evidence != "ok"`: `"No hay evidencia registrada en .sooft/evidence.md."`
- Si la fase es `BLOCKED`: el contenido de `blocked_reason` en `.sooft/state.json`.
- En cualquier otro caso: `null`

### Paso 6 — Construir y reportar el output

Reportá el siguiente JSON sin modificar nada:

```json
{
  "version": "0.1.0",
  "phase": "<fase actual>",
  "ticket": "<ticket o null>",
  "owner": "<owner>",
  "created_at": "<fecha>",
  "last_step": "<último paso>",
  "next_step": "<próximo paso>",
  "artifacts": {
    "prd": "<path o null>",
    "spec": "<path o null>",
    "plan": "<path o null>",
    "evidence": "<path o null>",
    "status": "<path o null>"
  },
  "artifacts_status": {
    "prd": "ok|missing|empty",
    "spec": "ok|missing|empty|not_required",
    "plan": "ok|missing|empty",
    "evidence": "ok|missing|empty",
    "status": "ok|missing|empty|not_required"
  },
  "status_summary": {
    "phase_in_status": "<fase declarada en STATUS.md o null>",
    "decisions_recent": ["<ultimas 3 decisiones o []>"],
    "open_risks_count": 0,
    "next_step_from_status": "<proximo paso declarado en STATUS.md o null>",
    "drift_detected": false
  },
  "block": "<descripción de qué bloquea el avance, o null si no hay bloqueo>",
  "integrations": {
    "tracker": "<valor de config o unknown>",
    "repository": "<valor de config o unknown>"
  }
}
```

> `drift_detected` es `true` si `phase_in_status != phase` (RF-05 anti-drift). En ese caso `block` debe reflejarlo: `"STATUS.md desincronizado de state.json (drift RF-05). Regenerar STATUS.md o corregir state.json."`

## Qué NO hacer

- No modificar `.sooft/state.json`
- No modificar ningún artefacto
- No inventar datos que no están en el estado
- No reportar un gate como aprobado si no hay evidencia de aprobación
- No avanzar la fase ni sugerir hacerlo automáticamente
