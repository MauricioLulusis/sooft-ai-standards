# Evidencia — <título del feature o cambio>

**Ticket:** <TICKET-XXXXX o N/A>
**Fecha de cierre:** <YYYY-MM-DD>
**Responsable:** <owner>
**Repo:** <URL del repositorio>
**Branch:** <nombre del branch>

---

## Resumen Ejecutivo

<Descripción de 3 a 5 líneas de qué se hizo, por qué y cuál fue el resultado. Orientado a alguien que no siguió el trabajo de cerca. Mencionar si el objetivo del PRD se cumplió completamente, parcialmente, o si hubo desvíos.>

---

## Archivos Modificados

| Archivo | Tipo de cambio | Descripción |
|---------|----------------|-------------|
| `<path/al/archivo>` | Nuevo / Modificado / Eliminado | <descripción del cambio> |
| `<path/al/archivo>` | Nuevo / Modificado / Eliminado | <descripción del cambio> |
| `<path/al/archivo>` | Nuevo / Modificado / Eliminado | <descripción del cambio> |

**Total de archivos modificados:** <n>
**Líneas agregadas / eliminadas:** <+n / -n>

---

## Validaciones Ejecutadas

### Tests unitarios

| Suite | Resultado | Cobertura | Observaciones |
|-------|-----------|-----------|---------------|
| <nombre de la suite> | PASS / FAIL | <n%> | <observaciones si hay fallos o skips> |

**Comando ejecutado:** `<comando exacto>`
**Output relevante:**
```
<fragmento del output con el resultado final>
```

### Tests de integración

| Suite | Resultado | Observaciones |
|-------|-----------|---------------|
| <nombre de la suite> | PASS / FAIL | <observaciones> |

**Comando ejecutado:** `<comando exacto>`

### Análisis estático (calidad / SAST)

| Categoría | Findings críticos | Findings altos | Estado |
|-----------|-------------------|----------------|--------|
| Bugs | <n> | <n> | PASS / FAIL |
| Vulnerabilidades | <n> | <n> | PASS / FAIL |
| Code smells | <n> | <n> | PASS / FAIL |
| Cobertura | — | — | <n%> |

**Link al reporte:** <URL al reporte de análisis estático o N/A>
**Quality Gate:** PASSED / FAILED

### Análisis estático (SAST — seguridad)

| Severidad | Cantidad | Estado |
|-----------|----------|--------|
| Very High | <n> | PASS / FAIL |
| High | <n> | PASS / FAIL |
| Medium | <n> | PASS / FAIL / Justificado |
| Low / Info | <n> | Registrado |

**Link al reporte:** <URL al scan de SAST o N/A>
**Excepciones aprobadas por Ciberseguridad:** <detalle o ninguna>

### Linter

| Resultado | Observaciones |
|-----------|---------------|
| PASS / FAIL | <hallazgos resueltos o pendientes> |

### Hooks y pipelines

| Hook / Pipeline | Resultado | Observaciones |
|-----------------|-----------|---------------|
| CI pipeline | PASS / FAIL | <observaciones> |
| <otro check> | PASS / FAIL | <observaciones> |

---

## Decisiones Tomadas

> Decisiones que no estaban en el PRD/SPEC original y que se tomaron durante la implementación.

| # | Decisión | Justificación | Alternativa descartada |
|---|----------|---------------|------------------------|
| 1 | <descripción de la decisión> | <por qué se tomó> | <qué no se hizo y por qué> |
| 2 | <descripción de la decisión> | <por qué se tomó> | <qué no se hizo y por qué> |

---

## Riesgos Detectados

> Riesgos identificados durante la implementación que no estaban en el análisis inicial.

| ID | Descripción | Probabilidad | Impacto | Estado |
|----|-------------|--------------|---------|--------|
| R-001 | <descripción del riesgo> | Alta / Media / Baja | Alto / Medio / Bajo | Mitigado / Abierto / Aceptado |

---

## Código generado por IA

> Trazabilidad del código IA-generated (ver la skill `sooft`, sección de trazabilidad).

| Archivo | IA-generated | Revisado por | Fecha |
|---------|--------------|--------------|-------|
| `<path/al/archivo>` | Sí / Parcial / No | <usuario> | <YYYY-MM-DD> |

**Proporción del cambio generada por IA:** <aproximado, ej: 70%>
**Todo el código IA-generated fue revisado y aprobado:** Sí / No

---

## Aprobaciones Registradas

| Artefacto | Aprobado por | Fecha | Medio |
|-----------|-------------|-------|-------|
| PRD | <nombre> | <YYYY-MM-DD> | <Slack / comentario en MR / email> |
| SPEC | <nombre> | <YYYY-MM-DD> | <medio> |
| PLAN | <nombre> | <YYYY-MM-DD> | <medio> |
| Código IA-generated | <nombre> | <YYYY-MM-DD> | <medio> |
| Code review | <nombre> | <YYYY-MM-DD> | <URL del MR> |
| QA sign-off | <nombre o N/A> | <YYYY-MM-DD> | <medio> |

---

## Pendientes

> Trabajo que quedó fuera del scope de este ciclo y debe seguirse en futuros tickets.

| # | Descripción | Ticket de seguimiento | Prioridad |
|---|-------------|----------------------|-----------|
| 1 | <descripción del pendiente> | <TICKET-XXXXX o a crear> | Alta / Media / Baja |
| 2 | <descripción del pendiente> | <TICKET-XXXXX o a crear> | Alta / Media / Baja |

---

## Links

| Tipo | Link |
|------|------|
| Merge Request / PR | <URL del MR/PR> |
| Pipeline CI/CD | <URL del pipeline> |
| Ticket el issue tracker | <URL o TICKET-XXXXX> |
| Reporte de análisis estático | <URL> |
| PRD | <path relativo o URL> |
| SPEC | <path relativo o URL, o N/A> |
| PLAN | <path relativo o URL> |
