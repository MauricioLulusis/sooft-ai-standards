# Recurso interno de `sooft`: validation

> Recurso interno de la constitución `sooft` — **no es una skill invocable** ni un slash command. Los routers lo cargan leyendo este archivo (`sooft/internal/sooft-validation.md`) cuando el flujo lo pide. Regí siempre por la skill `sooft` (principios, gates de aprobación, máquina de estados y reglas no negociables).

## Cuándo usarlo

Antes de abrir el Pull Request / Merge Request. Este skill confirma que el trabajo está terminado y cumple los criterios de calidad de Sooft.

## Delegación a subagentes Copilot CLI

Si estás en **Copilot CLI** y existen custom agents en `.github/agents/`, usalos así:

- `sooft-code-reviewer`: revisión read-only de correctitud, tests, arquitectura y mantenibilidad del diff.
- `sooft-security-reviewer`: revisión read-only de seguridad, secretos, PII, auth/authz, inputs, dependencias y configuración.

Los subagentes solo reportan hallazgos. El orquestador SOOFT decide transiciones (`VALIDATING`, `SECURITY_FINDINGS`, `CODE_REVIEW_PENDING`), actualiza evidencia y presenta el gate humano. Si no están disponibles, ejecutá este recurso directamente.

---

## Lineamientos de referencia

Antes de ejecutar el checklist, cargá los lineamientos canónicos (viven en la skill `sooft`, son la **fuente de verdad** compartida):

- **skill `sooft` → `assets/policies/security-guidelines.md`** — reglas obligatorias de seguridad. Verificá cada ítem del bloque "Seguridad" contra este archivo.
- **skill `sooft` → `assets/policies/testing-guidelines.md`** — estrategia de testing obligatoria. Verificá cada ítem del bloque "Tests" contra este archivo.
- **skill `sooft` → `assets/policies/git-guidelines.md`** — convenciones de Git obligatorias. Verificá cada ítem del bloque "Git" contra este archivo.
- **skill `sooft` → `assets/policies/pr-template-guidelines.md`** — template corporativo de Pull Requests. Verificá cada ítem del bloque "PR Template" contra este archivo.

---

## Checklist de validación

### Tests
- [ ] Todos los tests pasan — no solo los nuevos, sino el suite completo.
- [ ] No hay tests skipeados sin justificación documentada.
- [ ] La cobertura del código nuevo es consistente con la skill `sooft` → `assets/policies/testing-guidelines.md` (mínimos: dominio/servicios 80%, controllers 70%, utils 80%).
- [ ] Para features con lógica nueva: se aplicó TDD (test primero, rojo → verde).
- [ ] Para bugs: existe el test de reproducción que falló antes del fix.

### Calidad de código
- [ ] No hay code smells de severidad alta introducidos por este cambio.

### Scripts de verificación
- [ ] Los comandos de validación del proyecto (tests, linter, análisis de calidad / SAST, los que el proyecto tenga configurados) ejecutan sin errores.

### Documentación del ticket
- [ ] `PLAN.md` con todas las tareas marcadas `[x]`.
- [ ] `evidence.md` actualizado con capturas, logs o resultados que evidencian que el cambio funciona.
- [ ] **Autoevaluación consolidada** en `docs/{tipo}/{slug}/SELF-REVIEW.md` (feat → `docs/feats/`, bug → `docs/bugs/`, security → `docs/security/`), completada siguiendo el template `skills/sooft/assets/self-review-template.md`. Ver "Consolidación de la autoevaluación" abajo — es **bloqueante** para pasar a `CODE_REVIEW_PENDING`.
- [ ] **STATUS.md coherente con state.json** en `docs/{tipo}/{slug}/STATUS.md` — 7 secciones obligatorias completas, `phase == state.json.phase` (RF-05 anti-drift), progreso del PLAN sincronizado, sin contenido prohibido (RF-08). Template: `skills/sooft/assets/status-template.md`. Es **bloqueante** para pasar a `CODE_REVIEW_PENDING`.

### Seguridad y datos
Verificar cada ítem contra la skill `sooft` → `assets/policies/security-guidelines.md`:
- [ ] Sin secretos hardcodeados (tokens, passwords, API keys, certificados, connection strings).
- [ ] Sin PII en logs (documento, teléfono, CVU, PAN, CVV, tokens de sesión, JWT, passwords).
- [ ] Sin credenciales de entornos reales en código de test.
- [ ] Queries parametrizadas — sin concatenación de strings para SQL.
- [ ] Dependencias nuevas justificadas en el PLAN/PR y revisadas por CVEs.
- [ ] Si el cambio toca auth/autorización/sesiones/JWT/endpoints públicos/cifrado/PCI-DSS: marcado para revisión de Ciberseguridad.

### Git
Verificar cada ítem contra la skill `sooft` → `assets/policies/git-guidelines.md`:
- [ ] Nombre del branch sigue la convención: `feat/`, `fix/`, `docs/` o `chore/` + descripción kebab-case. Sin nombres vagos (`feature1`, `cambio`, `fix123`).
- [ ] Todos los commits del branch cumplen Conventional Commits: `<tipo>(scope): descripción`. Tipos válidos: `feat`, `fix`, `chore`, `docs`, `refactor`, `test`, `build`, `ci`, `perf`.
- [ ] El PR apunta a `release/<version>`, no directamente a la rama principal (`master` / `main`).
- [ ] Si el PR supera 400 líneas: documentar justificación o dividir en PRs más pequeños.

### PR Template
Verificar cada ítem contra la skill `sooft` → `assets/policies/pr-template-guidelines.md`:
- [ ] El repo tiene `.github/pull_request_template.md`. Si no existe, instalarlo antes de abrir el PR.
- [ ] La descripción del PR incluye **Objetivo** con contenido real (no el placeholder del template).
- [ ] La descripción del PR incluye **Ticket el issue tracker** (`INC-`, `RITM-`, `STRY-` o `CHG-`).
- [ ] La descripción del PR incluye **Cambios Realizados** con al menos un ítem funcional o técnico real.
- [ ] La descripción del PR incluye **Consideraciones para el Reviewer** con al menos un aspecto específico.
- [ ] La descripción del PR incluye **Cómo Probar el Cambio** con precondiciones, pasos reproducibles y resultado esperado.
- [ ] La descripción del PR incluye **Impacto**: alcance (capas afectadas) y nivel de riesgo marcados; Breaking Changes indicado.
- [ ] La descripción del PR incluye **Evidencia** (capturas, logs o resultados de pruebas).

---

## Si algo falla

No abrir el PR hasta resolver todos los ítems bloqueantes. Para cada fallo reportar:

```
Item fallido: <nombre del ítem>
Detalle: <qué falló exactamente — mensaje de error, test fallido, hallazgo de Sonar>
Causa probable: <por qué falló>
Cómo resolverlo: <pasos concretos para corregirlo>
Bloqueante para el PR: sí / no
```

### Ítems bloqueantes (el PR no puede abrirse sin resolverlos)
- Tests fallando.
- Secretos o PII detectados.
- Comandos de validación del proyecto (linter, análisis de calidad / SAST) con errores o hallazgos altos/críticos.
- **`SELF-REVIEW.md` ausente, incompleto o inconsistente** (ver "Consolidación de la autoevaluación" — reglas de trazabilidad y anti-gaming).
- **`STATUS.md` ausente, incompleto o desincronizado de `state.json`** (RF-05 anti-drift). El chequeo se ejecuta como paso 0 del recurso `internal/sooft-code-review-gate.md`.
- PR apuntando a la rama principal (`master` / `main`) en vez de `release/<version>`.
- Commits sin formato Conventional Commits.
- Sección Objetivo del PR ausente o con solo el texto placeholder.
- Sin número de ticket el issue tracker en el PR (`INC-`, `RITM-`, `STRY-` o `CHG-`).
- Sin pasos para reproducir el cambio en el PR.
- Sin indicación de impacto (alcance y nivel de riesgo) en el PR.

### Ítems no bloqueantes (documentar y crear seguimiento)
- Cobertura inferior a la ideal en código legacy que no se modificó.
- Nombre de branch no convencional (si el branch ya existe y renombrarlo generaría fricción, documentar y corregir en el próximo).
- PR superior a 400 líneas sin justificación.
- Evidencia presente como texto descriptivo en vez de artefactos adjuntos (advertir que adjuntar es preferible).
- Breaking Changes no marcado explícitamente en el PR (advertir y pedir confirmación antes de continuar).

---

## Salida esperada

Un reporte de validación en `evidence.md` o como comentario en el PR:

```markdown
## Reporte de validación — <ticket>

Fecha: YYYY-MM-DD
Validado por: qa-agent

| Item | Estado | Detalle |
|------|--------|---------|
| Tests (suite completo) | OK | 142/142 passing |
| Linter / análisis de calidad | OK | Sin errores |
| SAST (si configurado) | OK | Sin hallazgos altos/críticos |
| PLAN.md completo | OK | 8/8 tareas [x] |
| evidence.md actualizado | OK | |
| SELF-REVIEW.md consolidado | OK | `docs/feats/<slug>/SELF-REVIEW.md` |
| STATUS.md coherente | OK | `docs/feats/<slug>/STATUS.md`, `phase == state.json.phase` |
| Sin secretos | OK | |
| Sin PII en logs | OK | |
| Branch naming                | OK     | feat/validacion-cvu          |
| Commits conventional         | OK     |                              |
| PR apunta a release/         | OK     | release/0.2.0                |
| PR Template instalado        | OK     | .github/pull_request_template.md |
| PR: Objetivo                 | OK     |                              |
| PR: Ticket el issue tracker        | OK     | STRY-12345                   |
| PR: Cambios realizados       | OK     |                              |
| PR: Pasos de validación      | OK     |                              |
| PR: Impacto                  | OK     | Riesgo: Bajo · Backend       |
| PR: Evidencia                | OK     | Captura adjunta              |

**Resultado: LISTO PARA PR**
```

---

## Consolidación de la autoevaluación

Como **último paso** del checklist, y una vez validado el resto, el agente consolida el sketchpad `.sooft/self-review-scratchpad.md` (mantenido durante `IMPLEMENTING` — ver recurso `internal/sooft-implement-task.md`) en el artefacto final `docs/{tipo}/{slug}/SELF-REVIEW.md`, siguiendo el template `skills/sooft/assets/self-review-template.md`.

Este artefacto es el input principal del reviewer humano en el gate 4 (`CODE_REVIEW_PENDING`, recurso `internal/sooft-code-review-gate.md`). Sin él el gate no se abre.

### Reglas de trazabilidad (RF-04 del PRD original de la feature)

- **Toda tarea `[x]` del PLAN debe aparecer en la sección "Cobertura" del SELF-REVIEW con su ID `[T0XX]`.**
- Un ítem de cobertura sin tarea real → inconsistencia.
- Una tarea `[x]` sin ítem de cobertura → inconsistencia.

### Reglas anti-gaming del nivel de confianza (RF-05)

Al asignar el nivel global de confianza:

- **Cap por dimensión**: el nivel global es como máximo el mínimo de las tres dimensiones (`cobertura`, `limitaciones`, `riesgos`). Si `cobertura=medio, limitaciones=alto, riesgos=alto`, el global no puede ser `alto`.
- **Cap por señales objetivas**:
  - Con tests fallando o cobertura del código nuevo `< umbral del proyecto`, el nivel global **no puede** ser `alto`.
  - Con hallazgos SAST `high` o `critical` **sin remediar**, el nivel global **se fuerza a `bajo`**.
- **Rationale sustantivo obligatorio**: debe referenciar al menos una limitación, riesgo o señal objetiva concreta. Rationale genérico ("todo OK", "sin observaciones") = sección incompleta.

### Comportamiento cuando el artefacto está incompleto o inconsistente

Si al consolidar el agente detecta:

- sección obligatoria vacía o con placeholder no justificado,
- violación de las reglas anti-gaming,
- ruptura de la trazabilidad con el PLAN,

entonces **NO transiciona a `CODE_REVIEW_PENDING`**. Reporta la inconsistencia concreta al developer (qué sección, qué regla se violó) y ofrece dos rutas:

1. Volver a `IMPLEMENTING` a cubrir la brecha.
2. Documentar el desvío explícitamente dentro del propio `SELF-REVIEW.md` y quedar en `BLOCKED` esperando aprobación del desvío.

Nunca aprueba el gate 4 con un `SELF-REVIEW` incompleto.

### Relación con `evidence.md`

`evidence.md` es el diario cronológico del trabajo (log operativo por paso). `SELF-REVIEW.md` es la vista consolidada dirigida al reviewer humano del gate 4. No hay duplicación: `evidence.md` es proceso; `SELF-REVIEW.md` es entregable de review. El SELF-REVIEW puede referenciar entradas de `evidence.md` cuando la evidencia detallada es relevante para un riesgo o limitación.

### Relación con `STATUS.md`

`STATUS.md` es el snapshot semántico compacto del proyecto (vivo, actualizado en cada transición) — sirve para rehidratar el contexto entre sesiones. `SELF-REVIEW.md` es el entregable final del gate 4 (consolidado una vez, al final de `VALIDATING`). No hay duplicación: `STATUS.md` es memoria operativa; `SELF-REVIEW.md` es entregable de review. Al consolidar `SELF-REVIEW.md`, verificar que `STATUS.md.phase == VALIDATING` (RF-09 del PRD TICKET-2045). El SELF-REVIEW puede referenciar `STATUS.md` desde su sección Cobertura si aporta contexto.
