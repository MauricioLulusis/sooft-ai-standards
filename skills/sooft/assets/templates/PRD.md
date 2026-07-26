# PRD — <título del feature o cambio>

**Status:** Draft | In Review | Approved | In Progress | Done
**Ticket:** <TICKET-XXXXX o N/A>
**Autor:** <owner>
**Fecha:** <YYYY-MM-DD>
**Última actualización:** <YYYY-MM-DD>

> **Regla de honestidad.** Si un dato no está confirmado, no lo inventes: marcá el punto con `[NEEDS CLARIFICATION: <qué falta saber>]` y registralo en *Preguntas Abiertas*. Un PRD con marcadores abiertos no puede aprobarse hasta resolverlos. Es preferible un hueco explícito a una suposición silenciosa.

---

## Problema

<Qué problema de negocio o técnico estamos resolviendo. Por qué existe este trabajo. Quién se ve afectado y cómo.>

---

## Objetivos

- <Objetivo concreto y medible 1>
- <Objetivo concreto y medible 2>
- <Objetivo concreto y medible 3>

---

## No-objetivos

> Qué está explícitamente fuera del alcance de este trabajo.

- <Cosa que no vamos a hacer en este ciclo>
- <Cosa que puede parecer relacionada pero no entra>

---

## Criterios de Éxito

> Cómo sabemos que este trabajo está terminado y funcionó. Cada criterio debe ser **medible y verificable** — no "mejora la experiencia" sino "el listado carga en menos de 1s con 10.000 registros". Si no se puede medir, no es un criterio de éxito: es un objetivo.

| ID | Criterio medible | Cómo se mide |
|----|------------------|--------------|
| SC-001 | <resultado observable y cuantificable> | <métrica, herramienta o prueba concreta> |
| SC-002 | <resultado observable y cuantificable> | <métrica, herramienta o prueba concreta> |
| SC-003 | <resultado observable y cuantificable> | <métrica, herramienta o prueba concreta> |

---

## User Stories

### US-001 — <nombre corto>

**Como** <rol o tipo de usuario>
**quiero** <acción o capacidad>
**para** <beneficio o resultado esperado>

**Criterios de aceptación:**

- **Given** <estado inicial o precondición>
  **When** <acción que ejecuta el usuario o sistema>
  **Then** <resultado esperado observable>

- **Given** <estado inicial o precondición>
  **When** <acción que ejecuta el usuario o sistema>
  **Then** <resultado esperado observable>

---

### US-002 — <nombre corto>

**Como** <rol o tipo de usuario>
**quiero** <acción o capacidad>
**para** <beneficio o resultado esperado>

**Criterios de aceptación:**

- **Given** <estado inicial o precondición>
  **When** <acción que ejecuta el usuario o sistema>
  **Then** <resultado esperado observable>

---

## Requisitos Funcionales

| ID | Descripción | US relacionada | Prioridad |
|----|-------------|----------------|-----------|
| RF-001 | <descripción del requisito funcional> | US-001 | Alta |
| RF-002 | <descripción del requisito funcional> | US-001 | Alta |
| RF-003 | <descripción del requisito funcional> | US-002 | Media |

---

## Requisitos No Funcionales

| ID | Categoría | Descripción | Criterio de aceptación |
|----|-----------|-------------|------------------------|
| RNF-001 | Performance | <descripción> | <métrica medible, ej: p99 < 200ms> |
| RNF-002 | Seguridad | <descripción> | <ej: sin secretos hardcodeados, sin PII en logs> |
| RNF-003 | Disponibilidad | <descripción> | <ej: 99.9% uptime> |
| RNF-004 | Observabilidad | <descripción> | <ej: trazas distribuidas en todos los endpoints> |

---

## Cambios en Datos

> Completar solo si este trabajo modifica esquemas, modelos o flujos de datos.

**Entidades afectadas:** <nombre de tablas, colecciones, topics Kafka, etc.>

**Tipo de cambio:** Nuevo campo | Nueva tabla | Migración | Eliminación | Sin cambios

**Descripción del cambio:**
<Describir qué cambia en el modelo de datos, si hay migración de datos existentes, si hay backward compatibility.>

**Estrategia de migración:** <cómo se migran datos existentes si aplica, o N/A>

---

## UI/UX

> Completar solo si este trabajo tiene impacto en interfaces de usuario.

**Pantallas afectadas:** <lista de pantallas o componentes>

**Cambios de flujo:** <describir cambios en el flujo de navegación si aplica>

**Links a diseños:** <Figma, Zeplin, screenshots — o N/A>

**Consideraciones de accesibilidad:** <WCAG level requerido u otras consideraciones>

---

## Dependencias

| Tipo | Nombre | Descripción | Estado |
|------|--------|-------------|--------|
| Servicio externo | <nombre> | <qué necesitamos de él> | <disponible / pendiente / bloqueante> |
| Equipo | <nombre del equipo> | <qué necesitamos> | <estado> |
| Feature flag | <nombre> | <condición de activación> | <estado> |
| Ticket relacionado | <TICKET-XXXXX> | <descripción de la relación> | <estado> |

---

## Referencias

| Tipo | Link o identificador | Descripción |
|------|----------------------|-------------|
| Ticket | <TICKET-XXXXX o N/A> | Ticket del issue tracker de origen |
| Diseño | <URL o N/A> | Mockups o especificación visual |
| Documentación | <URL o N/A> | Docs técnicas relevantes |
| ADR | <ADR-XXX o N/A> | Decisiones de arquitectura relacionadas |

---

## Preguntas Abiertas

| # | Pregunta | Responsable | Fecha límite | Resolución |
|---|----------|-------------|--------------|------------|
| 1 | <pregunta sin respuesta aún> | <nombre> | <YYYY-MM-DD> | Pendiente |
| 2 | <pregunta sin respuesta aún> | <nombre> | <YYYY-MM-DD> | Pendiente |

---

## Conflictos y Dependencias Cruzadas

> Posibles conflictos con otros features en curso o dependencias entre equipos.

- <Conflicto o dependencia cruzada 1 — equipo o feature afectado>
- <Conflicto o dependencia cruzada 2>

---

## Historial de Cambios

> Toda modificación al PRD después de su aprobación inicial se registra acá. Es la trazabilidad que audita la organización.

| Fecha | Autor | Cambio | Motivo |
|-------|-------|--------|--------|
| <YYYY-MM-DD> | <owner> | Versión inicial | Creación del PRD |
