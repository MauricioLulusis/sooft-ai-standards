# Template — Snapshot de estado del proyecto (`STATUS.md`)

> Recurso interno de la constitución `sooft`. Este template lo consumen `sooft-implement-task.md` (auto en cada transición de fase) y `sooft-checkpoint` (manual on-demand). No es una skill invocable ni un slash command.

## Propósito

`STATUS.md` es el **snapshot semántico compacto** del trabajo. Permite rehidratar el contexto del proyecto al iniciar una sesión nueva sin depender del historial conversacional. Vive versionado junto al código y sobrevive al PR.

## Distinción con otros artefactos

| Artefacto | Naturaleza | Ubicación | Momento | Audiencia |
|---|---|---|---|---|
| `.sooft/state.json` | Pointer runtime minimalista | efímero, gitignored | cada transición | agente |
| `.sooft/evidence.md` | Diario cronológico crudo (append) | efímero, gitignored | por acción | auditor humano local |
| **`STATUS.md`** | **Snapshot semántico compacto rehidratable** | **versionado** | **al cambiar de fase + on-demand** | **agente en sesión nueva + reviewer** |
| `SELF-REVIEW.md` | Vista consolidada dirigida al gate 4 | versionado | al final de `VALIDATING` | reviewer humano del gate 4 |

`STATUS.md` **no reemplaza** ninguno de los otros. Coexisten con propósitos ortogonales.

## Dónde vive el artefacto

Según el `type` del trabajo (leído de `.sooft/state.json`):

- `feat` → `docs/feats/{slug}/STATUS.md`
- `bug` → `docs/bugs/{slug}/STATUS.md`
- `security` → `docs/security/{slug}/STATUS.md`

## Snapshots rotativos efímeros

En paralelo al `STATUS.md` versionado, cada actualización escribe una copia efímera en `.sooft/status/YYYY-MM-DDTHH-MM.md` (formato Windows-friendly, sin `:`).

- **Retención**: últimos 10 snapshots en rotación FIFO. Configurable con `status_retention: N` en `.sooft/config.json`.
- **Excepción de retención**: al aprobarse un gate (PRD, SPEC, PLAN, code review) el snapshot correspondiente se mueve a `.sooft/status/gates/{gate}-approved-YYYY-MM-DD.md`. **No rotan**.
- Toda la carpeta `.sooft/status/` es gitignored (heredado del `/.sooft` existente).

## Reglas de consolidación

- **Cap de tamaño (RNF-02)**: el `STATUS.md` versionado debe mantenerse **bajo 200 líneas**. Si crece más, es señal de que el contenido no es semántico compacto sino dump crudo → compactar aún más (archivar riesgos cerrados, no repetir prosa, referenciar `evidence.md` en lugar de duplicar).
- **Anti-drift (RF-05)**: en cada actualización, el campo `phase` de la sección Metadatos **debe** coincidir con `phase` de `state.json`. Ídem `ticket`, `slug`, `type`, `owner`. Divergencia → HALT y reporte al developer.
- **Windows-friendly (RNF-03)**: nombres de archivos en `.sooft/status/` usan `YYYY-MM-DDTHH-MM.md`. Nunca `:`.
- **Trazabilidad con PLAN**: el checklist de la sección "Progreso del PLAN" refleja `[x]`/`[ ]` del `PLAN.md`. Tarea completada en el PLAN pero ausente del STATUS = artefacto desincronizado.
- **Backfill (RF-07)**: para workflows legacy sin `STATUS.md`, el agente puede reconstruirlo desde `evidence.md` + artefactos existentes SOLO con opt-in explícito del developer. Bullets inferidos van con marcador `[inferido de evidence]`.

## Contenido PROHIBIDO (RF-08)

Nunca escribir en `STATUS.md` (versionado ni snapshots):

- Secretos, tokens, credenciales, API keys.
- PII (documento, teléfono, tarjeta, datos personales, mail, teléfono).
- Payloads crudos del issue tracker o requests HTTP.
- Transcripts conversacionales completos.
- Stack traces con paths internos o versiones de librerías.

Se aplica la misma regla que §6.1 de `sooft/SKILL.md`. Una violación → el gate 4 no se abre.

## Template

Copiar el bloque siguiente al archivo destino y completar. Reemplazar todos los `<placeholder>`.

---

```markdown
# STATUS — <título breve del trabajo>

## 1. Metadatos

| Campo | Valor |
|---|---|
| Ticket | <TICKET-ID> |
| Tipo | <feat|bug|security> |
| Slug | <slug> |
| Branch | `<branch-name>` |
| Fase (`phase`) | <PHASE_NAME> |
| Owner | <owner> |
| Última actualización | <YYYY-MM-DD HH:MM> |

> Coherencia obligatoria con `.sooft/state.json`. Divergencia = HALT (RF-05).

## 2. Resumen ejecutivo

<2 a 4 frases: qué problema se busca resolver, en qué punto está, cuál es el próximo paso alto nivel.>

## 3. Decisiones clave tomadas

Bullets ordenados cronológicamente. Cada bullet: `[fase] <fecha> — <decisión> — <rationale corto>`.

- `[discovery] 2026-07-03 — <decisión> — <rationale>`
- `[PRD] 2026-07-03 — <decisión> — <rationale>`
- `[PLAN] 2026-07-03 — <decisión> — <rationale>`

> Máximo ~15 bullets. Si excede, compactar: agrupar decisiones relacionadas.

## 4. Artefactos aprobados

| Artefacto | Ruta | Fecha de aprobación | Estado |
|---|---|---|---|
| PRD | `docs/{tipo}/{slug}/PRD.md` | <YYYY-MM-DD> | aprobado |
| SPEC | `docs/{tipo}/{slug}/SPEC.md` | <YYYY-MM-DD o "omitida (justificada)"> | aprobado / omitida |
| PLAN | `docs/{tipo}/{slug}/PLAN.md` | <YYYY-MM-DD> | aprobado |
| SELF-REVIEW | `docs/{tipo}/{slug}/SELF-REVIEW.md` | <YYYY-MM-DD o "pendiente"> | aprobado / pendiente |

## 5. Riesgos abiertos

Solo los riesgos **abiertos** (los cerrados se archivan, no se listan). Referenciar por ID del PRD si aplica.

| ID | Descripción | Severidad | Mitigación planeada |
|---|---|---|---|
| R-XX | <descripción corta> | <baja|media|alta|crítica> | <mitigación> |

Si no hay riesgos abiertos: `_Ninguno._`

## 6. Progreso del PLAN

Checklist compacto reflejando `PLAN.md`. Solo IDs y títulos cortos.

- [x] T001 — <título>
- [x] T002 — <título>
- [ ] T003 — <título>  ← próxima

> Si el PLAN tiene más de 20 tareas, mostrar solo bloques resumidos (`Bloque A: 3/3 ✓`, `Bloque B: 2/4`).

## 7. Próximo paso

`next_step` sincronizado con `state.json`: **<next_step>**.

> Alto nivel, una frase. Ej: "Ejecutar T003: crear skill sooft-checkpoint".

---

## Historial de cambios del STATUS

| Versión | Fecha | Fase | Cambios |
|---|---|---|---|
| v0.1 | <YYYY-MM-DD> | PRD_PENDING | Snapshot inicial post-discovery. |
| v0.2 | <YYYY-MM-DD> | PLAN_APPROVED | Actualización post gate 3. |
```

## Qué NO hacer

- No usar `STATUS.md` como reemplazo de `evidence.md`, `PRD.md`, `PLAN.md` ni `SELF-REVIEW.md`. Es un snapshot, no una fuente de verdad primaria.
- No duplicar prosa larga: `STATUS.md` es índice + resumen, no la doc completa.
- No incluir contenido de RF-08 (lista negra) bajo ninguna circunstancia.
- No dejar `<placeholder>` sin completar. Un placeholder pelado = incompleto.
- No agregar secciones ad-hoc. Las 7 son un contrato duro.

## Cierre

- Ante conflicto de reglas: manda `skills/sooft/SKILL.md` (constitución) y luego este template. Los cambios en el template requieren PR aparte con justificación.
