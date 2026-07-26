# Template — Autoevaluación de código IA (`SELF-REVIEW.md`)

> Recurso interno de la constitución `sooft`. Este template lo consume `sooft-validation.md` como último paso de `VALIDATING` para consolidar la autoevaluación del agente antes del gate 4 (`CODE_REVIEW_PENDING`). No es una skill invocable ni un slash command.

## Cuándo usarlo

Al final de `VALIDATING`, después de que corran tests, linter, análisis de calidad y SAST, y de haber actualizado `.sooft/evidence.md`. El agente consolida el sketchpad efímero `.sooft/self-review-scratchpad.md` (mantenido durante `IMPLEMENTING`) en el artefacto final versionado.

## Dónde vive el artefacto

Según el `type` del trabajo (leído de `.sooft/state.json`):

- `feat` → `docs/feats/{slug}/SELF-REVIEW.md`
- `bug` → `docs/bugs/{slug}/SELF-REVIEW.md`
- `security` → `docs/security/{slug}/SELF-REVIEW.md`

## Reglas de consolidación

- **Trazabilidad `PLAN ↔ SELF-REVIEW`**: toda tarea `[x]` del PLAN debe aparecer en la sección "Cobertura" con su ID (`[T001]`, `[T002]`, …). Ítem de cobertura sin tarea real o tarea sin ítem = artefacto incompleto → no abre gate 4.
- **Anti-gaming del nivel de confianza**:
  - El nivel global es como máximo el mínimo de las tres dimensiones (cobertura, limitaciones, riesgos).
  - Con tests fallando o cobertura del código nuevo bajo el umbral del proyecto, el nivel global no puede ser `alto`.
  - Con hallazgos SAST `high`/`critical` sin remediar, el nivel global se fuerza a `bajo`.
  - Rationale genérico ("todo OK", "sin observaciones") = sección incompleta → no abre gate 4.
- **Placeholder `N/A`**: solo permitido si va con una oración de justificación explícita. Un `N/A` pelado en una sección obligatoria = incompleto.

## Template

Copiar el bloque siguiente al archivo destino y completar. Reemplazar todos los `<placeholder>`.

```markdown
# SELF-REVIEW — <slug>

- **Ticket:** <STRY-XXXXXXX / INC-XXXXX / N/A si aplica>
- **Rama:** <feat|fix|security>/<slug>
- **Type:** <feat | bug | security>
- **PLAN:** [PLAN.md](./PLAN.md)  <!-- feat → PLAN.md; bug → FIX_PLAN.md; security → REMEDIATION_PLAN.md -->
- **Fecha de consolidación:** <YYYY-MM-DD>

---

## 1. Cobertura

<!--
Un ítem por tarea del PLAN completada. Formato:
- **[T0XX]** <qué se implementó, en una oración> — Validado por: <cómo se validó (tests, manual, revisión, etc.)>.
Referenciar tests generados por path + nombre del test: `path/al/archivo.test.ts::nombre del it()`.
-->

- **[T001]** <resumen 1 línea> — Validado por: <cómo>.
- **[T002]** <resumen 1 línea> — Validado por: <cómo>.

## 2. Limitaciones

<!--
Edge cases NO validados, decisiones heurísticas explícitas, supuestos sin verificar.
Formato: "<Limitación> — <por qué se dejó fuera> — <tarea del PLAN afectada si aplica>".
Si realmente no hay limitaciones (raro), justificar por qué.
-->

- <limitación> — <razón> — <T0XX o N/A>.

## 3. Riesgos

<!--
Áreas frágiles, dependencias críticas, deuda técnica introducida a propósito.
Formato: "<Riesgo> — Severidad: <alto|medio|bajo> — Mitigación: <sugerida o `aceptado sin mitigación: <motivo>`>".
-->

- <riesgo> — Severidad: <alto|medio|bajo> — Mitigación: <texto>.

## 4. Nivel de confianza

<!--
Nivel global: uno de `alto` / `medio` / `bajo`. Aplica RF-05 (caps por dimensión y por señales objetivas).
Rationale: 1 a 3 oraciones que referencien AL MENOS UNA limitación, riesgo o señal objetiva concreta.
Breakdown obligatorio por dimensión.
-->

**Nivel global:** <alto | medio | bajo>

**Rationale:** <1 a 3 oraciones que referencien al menos una limitación, riesgo o señal objetiva concreta>.

**Breakdown por dimensión:**

| Dimensión | Nivel | Justificación breve |
|---|---|---|
| Cobertura | <alto|medio|bajo> | <1 oración> |
| Limitaciones | <alto|medio|bajo> | <1 oración> |
| Riesgos | <alto|medio|bajo> | <1 oración> |

<!-- Regla dura: el nivel global NO puede ser mayor que el mínimo de las tres dimensiones. -->

## 5. Señales objetivas

<!--
Datos crudos tomados del reporte de sooft-validation.md. No reingeniar; copiar el resultado real.
Si el proyecto no tiene alguna herramienta configurada, poner "no configurado" (NO usar `OK` en ese caso).
-->

| Señal | Valor | Detalle |
|---|---|---|
| Tests | <p/f> | <X/Y passing — suite completa> |
| Cobertura código nuevo | <%> | <umbral del proyecto: <%>> |
| Linter | <OK / errores / no configurado> | <detalle si hay errores> |
| Análisis de calidad | <OK / hallazgos / no configurado> | <detalle> |
| SAST | <OK / hallazgos por severidad / no configurado> | <detalle> |

**Archivos `[IA-generated]` afectados:**

<!-- Lista completa. Path + breve descripción. -->

- `path/al/archivo.ext` — <qué contiene>.

## 6. Soporte adicional (opcional)

<!--
Solo si aporta valor al reviewer. Ejemplos: output extendido de análisis estático, benchmarks,
capturas de UI relevantes, notas del developer previas al gate 4, links a evidence.md de entradas
particularmente relevantes. Si no aplica, dejar la sección vacía o eliminarla.
-->
```

## Ejemplo mínimo (feature simple)

```markdown
## 1. Cobertura
- **[T001]** Validación por regex del password (8+ chars, mayúscula, minúscula, número, símbolo). — Validado por: `src/login.test.ts::rechaza password sin símbolo` + 6 casos más.
- **[T002]** Endpoint `POST /login` devuelve 401 con contraseña inválida. — Validado por: `src/login.test.ts::responde 401 con password invalido`.

## 2. Limitaciones
- No se valida rate limiting a nivel endpoint — se dejó para el ticket siguiente — T003 fuera de scope.

## 3. Riesgos
- El regex del password no distingue entre símbolos ASCII y unicode. Severidad: bajo. Mitigación: aceptado sin mitigación: el proyecto solo soporta ASCII en passwords hoy (documentado en la doc del proyecto).

## 4. Nivel de confianza
**Nivel global:** medio
**Rationale:** cobertura completa por tests del regex y del endpoint; limitación explícita en rate limiting (deuda declarada) baja la confianza de riesgos a medio.
Breakdown: cobertura=alto, limitaciones=medio, riesgos=medio. Cap por dimensión aplica → global=medio.

## 5. Señales objetivas
| Señal | Valor | Detalle |
|---|---|---|
| Tests | p | 34/34 passing |
| Cobertura código nuevo | 92% | umbral: 80% |
| Linter | OK | eslint sin errores |
| SAST | no configurado | proyecto sin SAST hoy |
```

## Historial

| Fecha | Autor | Cambio |
|---|---|---|
| 2026-07-03 | SOOFT (TICKET-2045) | Template inicial. |
