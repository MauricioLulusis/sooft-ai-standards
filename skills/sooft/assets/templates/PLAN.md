# PLAN — <título del feature o cambio>

**Ticket:** <TICKET-XXXXX o N/A>
**Autor:** <owner>
**Fecha:** <YYYY-MM-DD>
**PRD:** [PRD — <título>](../feats/<slug>/PRD.md)
**SPEC:** [SPEC — <título>](../feats/<slug>/SPEC.md) *(si aplica)*

---

## Resumen Técnico

<Descripción de 3 a 5 líneas del enfoque de implementación. Qué se va a construir, en qué orden y por qué. Mencionar las tecnologías o patrones clave que se van a usar.>

---

## Modo de Trabajo sobre Código Existente

> Si este cambio toca código que ya existe (lo más común en proyectos de Sooft), aplica el principio de **preservación**: se modifica lo mínimo necesario, no se reescribe lo que ya funciona.

- **Leer antes de tocar.** Entender el código existente y sus tests antes de modificarlo.
- **Cambio mínimo.** Solo lo que el requerimiento exige. Nada de refactors oportunistas fuera de scope.
- **Preservar comportamiento.** Los tests existentes deben seguir pasando, salvo que el requerimiento cambie ese comportamiento explícitamente.
- **Documentar el porqué.** Cada cambio sobre código existente lleva una razón rastreable al PRD o la SPEC.

Para código nuevo (greenfield) esta sección no aplica — indicarlo con "N/A — implementación desde cero".

---

## Estrategia MVP

<Describir cuál es el subconjunto mínimo que entrega valor real. Qué tareas son bloqueantes para el MVP y cuáles son mejoras posteriores. Esto guía las prioridades P1/P2/P3.>

---

## Dependencias entre Tareas

<Describir las dependencias críticas. Qué tareas deben completarse antes de que otras puedan comenzar. Ejemplo: T003 requiere T001 y T002.>

---

## Oportunidades de Paralelismo

<Qué grupos de tareas pueden ejecutarse en paralelo una vez que sus dependencias estén resueltas. Esto ayuda a estimar duración real vs. suma de partes.>

---

## Convención de Tareas (TDD test-first para lógica nueva)

> Cómo se escriben las tareas según el tipo de trabajo. El developer aprueba el plan viendo el test-first explícito, no confiando en que el agente "lo recuerde" durante la implementación.

- **Lógica nueva (features):** por cada unidad de lógica van **DOS tareas en orden**: primero escribir el **TEST** (debe fallar = **rojo**), después **IMPLEMENTAR** hasta que ese test pase (**verde**). El test va antes que la implementación, siempre.
- **Archivos sin lógica (HTML/CSS estático, config, fixtures):** van como tareas normales, **sin test**.
- **Bugs:** no usan este formato. Siguen el flujo de **reproducción-first** (primero el test que reproduce el bug, después el fix). Esto vale solo para lógica nueva.

> **Dónde va el test — exploratorio, no inventado.** Antes de definir las tareas de test, **explorá el proyecto** para descubrir su convención de tests y seguila. No asumas una ruta fija ni la impongas; es el mismo principio de preservar lo que ya funciona.
> - **Dónde viven los tests:** `tests/`, `__tests__/`, `src/test/java/`, junto al código (`*.test.ts`, `*.spec.ts`), `test_*.py` o `tests/` en Python, `*Tests.cs` o proyecto `.Tests` en .NET, etc.
> - **Qué framework está configurado:** mirá `package.json`, `pom.xml` / `build.gradle`, `pyproject.toml` / `requirements.txt`, `.csproj` / `.sln`.
> - **Qué naming y estructura** usa el proyecto, y replicalo.
> - **Greenfield (sin tests previos):** usá la convención estándar del stack detectado — ej: Vitest/Jest `*.test.ts` junto al código en TS; `src/test/java/` en Java/Maven; `tests/` con pytest en Python; proyecto `.Tests` en .NET.
>
> En el plan, cada tarea de test indica la **ruta REAL descubierta** (o la estándar si es greenfield), **nunca un placeholder genérico ni una ruta inventada**.

**Ejemplo (login con validación de password por regex):**

> En este ejemplo, `src/login.test.ts` es la convención de **ESE proyecto** (greenfield TS → Vitest/Jest junto al código). En un proyecto ya existente, el test iría **donde el proyecto ya tenga sus tests** (ej: `tests/`, `__tests__/`, `*.spec.ts`), según lo que arroje la exploración.

- [ ] T001 [P1] Escribir `login.test.ts` — tests del regex (8+ chars, mayúscula, minúscula, número, símbolo). Debe **FALLAR** (rojo). — `src/login.test.ts`
- [ ] T002 [P1] Implementar el regex de validación en `login.ts` hasta que T001 pase (verde). — `src/login.ts`
- [ ] T003 [P1] Crear `index.html` con el formulario (sin lógica → sin test). — `index.html`
- [ ] T004 [P1] `tsconfig.json` (config → sin test). — `tsconfig.json`

---

## Fases de Implementación

### Fase 1 — Setup

> Preparar el ambiente, dependencias y estructura base del proyecto.

- [ ] T001 [P1] <descripción de la tarea> — `<path/al/archivo/o/carpeta>`
- [ ] T002 [P1] <descripción de la tarea> — `<path/al/archivo/o/carpeta>`
- [ ] T003 [P1] <descripción de la tarea> — `<path/al/archivo/o/carpeta>`

---

### Fase 2 — Foundation

> Construir los cimientos: modelos, repositorios, configuraciones base.

- [ ] T004 [P1] <descripción de la tarea> — `<path/al/archivo/o/carpeta>`
- [ ] T005 [P1] <descripción de la tarea> — `<path/al/archivo/o/carpeta>`
- [ ] T006 [P2] <descripción de la tarea> — `<path/al/archivo/o/carpeta>`

**Dependencias:** T004 requiere T001, T005 puede correr en paralelo con T004.

---

### Fase 3 — Implementación US1

> Implementar la funcionalidad de la primera user story. Para cada unidad de lógica nueva: primero el test (rojo), después la implementación (verde). Ver "Convención de Tareas".

- [ ] T007 [P1] Escribir test de <unidad de lógica> — debe **FALLAR** (rojo). — `<path/al/test>`
- [ ] T008 [P1] Implementar <unidad de lógica> hasta que T007 pase (verde). — `<path/al/archivo>`
- [ ] T009 [P1] <archivo sin lógica: HTML/CSS estático o config — sin test> — `<path/al/archivo>`

**Dependencias:** T008 requiere T007 (no se implementa sin el test en rojo). T007 requiere T004 y T005.

---

### Fase 4 — Implementación US2

> Implementar la funcionalidad de la segunda user story.

- [ ] T011 [P1] <descripción de la tarea> — `<path/al/archivo/o/carpeta>`
- [ ] T012 [P1] <descripción de la tarea> — `<path/al/archivo/o/carpeta>`
- [ ] T013 [P2] <descripción de la tarea — tests> — `<path/al/test>`

**Dependencias:** T011 requiere T006. T012 requiere T011.

---

### Fase 5 — Polish

> Calidad, observabilidad, documentación y preparación para merge.

- [ ] T014 [P2] <agregar logs estructurados y trazas> — `<path>`
- [ ] T015 [P2] <actualizar documentación técnica> — `<path>`
- [ ] T016 [P3] <métricas y alertas si aplica> — `<path>`
- [ ] T017 [P2] <ejecutar análisis estático de calidad/SAST y resolver findings críticos>
- [ ] T018 [P1] <validar criterios de aceptación del PRD>

---

## Resumen de Prioridades

| Prioridad | Descripción |
|-----------|-------------|
| P1 | Bloqueante — debe completarse para el MVP |
| P2 | Importante — debe completarse antes del merge |
| P3 | Mejora — puede ir en un ciclo posterior si el tiempo no alcanza |

---

## Estimación

| Fase | Tareas P1 | Tareas P2 | Tareas P3 | Estimación |
|------|-----------|-----------|-----------|------------|
| Setup | <n> | <n> | <n> | <n horas o días> |
| Foundation | <n> | <n> | <n> | <n horas o días> |
| US1 | <n> | <n> | <n> | <n horas o días> |
| US2 | <n> | <n> | <n> | <n horas o días> |
| Polish | <n> | <n> | <n> | <n horas o días> |
| **Total** | | | | **<estimación total>** |

---

## Verificación de Consistencia

> Antes de empezar a implementar, confirmar que los tres artefactos están alineados. Si algo no cierra, resolverlo antes de escribir código.

- [ ] Cada tarea del plan se rastrea a un requisito del PRD o de la SPEC
- [ ] Cada requisito funcional del PRD tiene al menos una tarea que lo implementa
- [ ] Los criterios de éxito (SC) del PRD tienen una tarea de validación en el plan
- [ ] No hay tareas que implementen algo que ningún requisito pide
- [ ] No quedan marcadores `[NEEDS CLARIFICATION]` sin resolver en PRD ni SPEC

---

## Historial de Cambios

| Fecha | Autor | Cambio | Motivo |
|-------|-------|--------|--------|
| <YYYY-MM-DD> | <owner> | Versión inicial | Creación del plan |
