# Implementation Plan

> Parte de `sooft-development`. No invocar directamente.

## Propósito

Convertir el PRD aprobado y la SPEC aprobada (si existe) en un `PLAN.md` ejecutable,
trazable y aprobado antes de tocar código.

## Cuándo usarlo

- `phase == PRD_APPROVED` y la SPEC no aplica.
- `phase == SPEC_APPROVED`.
- `phase == PLAN_REJECTED`, para corregir el plan y volver a presentarlo.

## Entradas

- `docs/feats/{slug}/PRD.md` aprobado.
- `docs/feats/{slug}/SPEC.md` aprobada, si aplica.
- `.sooft/PRINCIPLES.md`, si existe (los principios técnicos del proyecto mandan).

## Delegación a subagente Copilot CLI

Si estás en **Copilot CLI** y existe el custom agent `sooft-plan-writer`, delegá la construcción del PLAN a ese subagente. El orquestador SOOFT conserva el gate de PLAN, valida que PRD/SPEC estén aprobados, presenta la frase canónica y espera aprobación explícita antes de cualquier implementación. El subagente no ejecuta tareas del plan ni crea archivos del entregable.

Si el subagente no está disponible, seguí este recurso directamente.

## Flujo

1. Verificar que no haya `[NEEDS CLARIFICATION]` abierto en PRD/SPEC.
2. Explorar el proyecto para descubrir stack, runner y convención real de tests (ver abajo).
3. Definir tareas con paths exactos y trazabilidad a requisitos/criterios de éxito.
4. Para lógica nueva, escribir tareas TDD en pares: test rojo primero, implementación verde después.
5. Si el cambio altera comportamiento documentado (contratos públicos, comandos, instalación, estructura o uso en el README u otra doc), agregar una tarea para actualizar esa doc. Cambios internos sin impacto en la doc no la tocan.
6. Documentar `## Spec omitida` en el plan si la SPEC no fue requerida.
7. Guardar `docs/feats/{slug}/PLAN.md` siguiendo el esqueleto de la plantilla canónica `skills/sooft/assets/templates/PLAN.md`; si hay más de 10 tareas, crear también `TASKS.md`.

Formato de tarea:

```
- [ ] T001 [P] {slug} Descripción precisa — src/ruta/exacta/Archivo.java
```

`[P]` = paralelizable. Sin `[P]` = secuencial. Fases del plan: Setup → Foundation → US1, US2… → Polish.

### Exploración de la convención de tests (ANTES de escribir las tareas de test)

El agente **NO asume** una ruta fija para los tests. **Antes** de definir las tareas de test,
**EXPLORÁ el proyecto** para **descubrir la convención de tests existente** y ubicar los tests nuevos **ahí mismo**.

Lo que hay que descubrir:

- **Dónde viven los tests:** `tests/`, `__tests__/`, `src/test/java/`, junto al código (`*.test.ts`, `*.spec.ts`), `test_*.py`, `*Tests.cs`, etc.
- **Qué framework está configurado:** `package.json`, `pom.xml` / `build.gradle`, `pyproject.toml`, `.csproj`.
- **Qué naming y estructura** usa el proyecto.

Reglas de ubicación:

- El test nuevo se ubica **siguiendo la convención existente descubierta**.
- **GREENFIELD**: usá la convención estándar del stack detectado.
- En el PLAN, la tarea de test indica la **ruta REAL descubierta**, no un placeholder.

### TDD como tareas EXPLÍCITAS del plan (solo lógica nueva)

Por cada unidad de **lógica nueva**, el plan lista **dos tareas en orden**:

1. **Escribir el TEST** — debe FALLAR (rojo). Apunta a la **ruta REAL** descubierta.
2. **IMPLEMENTAR** hasta que ese test pase (verde).

Esto es solo para lógica nueva (features). Los bugs siguen reproducción-first. Ver `sooft` (§6.2).

Ejemplo:

```
- [ ] T000 Explorar la convención de tests del proyecto — (exploración, sin archivo)
- [ ] T001 Escribir login.test.ts — tests del regex. Debe FALLAR (rojo). — src/login.test.ts
- [ ] T002 Implementar el regex en login.ts hasta que T001 pase (verde). — src/login.ts
- [ ] T003 Crear index.html con el formulario (sin lógica → sin test). — index.html
```

Para definir qué y cómo testear, apoyate en el recurso `internal/sooft-test-strategy.md` de `sooft`.

## Verificación de consistencia (al pie del PLAN)

Cada tarea se rastrea a un requisito, cada requisito tiene su tarea, los criterios de éxito tienen tarea de validación, y no queda ningún `[NEEDS CLARIFICATION]` abierto.

## Transición

- Al presentar: `phase = PLAN_PENDING`, `last_step = plan-draft`, `next_step = plan-review`.
- Al aprobar: `phase = PLAN_APPROVED`, `last_step = plan-approved`, `next_step = implement`.
- Al rechazar: `phase = PLAN_REJECTED`; corregir y volver a `PLAN_PENDING`.

## Gate

> **EL GATE DE PLAN ES OBLIGATORIO.** No se crea NINGÚN archivo del trabajo hasta que el PLAN esté **APROBADO explícitamente**.

**"Plan listo en `docs/feats/{slug}/PLAN.md`. Revisá antes de que empiece la implementación."**

Stop. No crear archivos de trabajo, tests ni código hasta aprobación explícita.

## Qué NO hacer

- No generar un plan sin PRD aprobado.
- No inventar rutas de tests: descubrirlas en el proyecto.
- No incluir scope que no esté en PRD/SPEC.
- No escribir código desde este paso.
