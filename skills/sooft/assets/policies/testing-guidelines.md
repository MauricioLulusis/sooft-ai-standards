# Lineamientos de Testing — Sooft Technology

---

## Regla fundamental

**Sin test, la tarea NO está completa.** OBLIGATORIO test para toda lógica nueva o modificada.

---

## Tipos de tests

### Unitarios
- Cubren lógica de dominio y servicios de negocio en aislamiento.
- Mockear dependencias externas (repositorios, clientes HTTP, etc.).
- Foco: ramas condicionales, casos borde, manejo de errores.

### Integración
- Cubren interacción real con base de datos y APIs internas.
- Usar base de datos embebida o contenedor de test (H2, Testcontainers).
- Foco: transaccionalidad, mappings de persistencia, queries críticas.

### Contrato
- Cubren APIs externas o microservicios con los que el cambio integra.
- Usar Pact o mocks de contrato cuando el equipo externo no puede correr tests conjuntos.
- Foco: que el consumidor y el proveedor acuerden el shape del mensaje.

### End-to-end (E2E)
- Cubren flujos críticos de negocio de punta a punta.
- Solo para cambios que afectan flujos de usuario o integraciones core.
- Foco: happy path + un caso de error representativo por flujo.

---

## Stack de Sooft

| Lenguaje | Frameworks | Runner |
|---|---|---|
| Java | JUnit 5 + Mockito + AssertJ | `mvn test` / `gradle test` |
| .NET (C#) | xUnit + Moq | `dotnet test` |
| Python | pytest | `pytest` |
| TypeScript / JavaScript | Jest / Vitest + Supertest | `npm test` + `tsc --noEmit` |

---

## Convenciones de nombrado

- **Java:** `deberia_<resultado>_cuando_<condicion>`
- **Node.js / TS:** `should <resultado> when <condicion>`
- Un assert principal por test; los secundarios son asserts de soporte.
- Tests parametrizados (`@ParameterizedTest` / `test.each`) para casos borde repetitivos.

---

## TDD según tipo de trabajo

| Tipo | Approach | Regla |
|---|---|---|
| **Feature (lógica nueva)** | TDD estricto | Test PRIMERO (rojo) → implementar mínimo (verde) → refactorizar (verde). En el PLAN la tarea de test es ANTERIOR a la de implementación. |
| **Bug** | Reproducción-first | Test que reproduce el bug, falla con comportamiento actual, pasa después del fix. PROHIBIDO reescribir ese test luego. |
| **Refactor / chore** | Regresión | Los tests existentes siguen en verde. PROHIBIDO borrarlos o reescribirlos sin justificación. |
| **Migración (upgrade de versión o port entre tecnologías)** | Regresión / paridad | NO agrega lógica nueva → NO aplica el umbral de cobertura de features. Criterio: la suite **existente** queda 100% en verde (clase A) o los tests se **portan** al stack destino y quedan en verde (clase B). La cobertura se **preserva**, no se sube; agregar tests a código legacy es otro ticket. PROHIBIDO cambiar comportamiento. |
| **Security** | Sin TDD | Tests existentes en verde. |
| **Sin lógica testeable** | Exención explícita | HTML/CSS estático, textos, comentarios, config pura. OBLIGATORIO indicarlo explícitamente. PROHIBIDO inventar tests vacíos o que siempre pasan. |

---

## Cobertura mínima por defecto

| Capa | Mínimo |
|---|---|
| Dominio / Servicios | 80% |
| Controllers | 70% |
| Utils | 80% |

Los umbrales configurados por el equipo tienen **prioridad** si difieren.

---

## Ubicación de los tests

OBLIGATORIO descubrir la convención del proyecto antes de escribir tareas de test. Usá la ruta REAL descubierta. PROHIBIDO imponer una ruta fija o un placeholder genérico.

---

## Qué NO se testea

- Código generado por el framework (getters/setters sin lógica).
- Configuración de beans / DI sin lógica de negocio.
- HTML/CSS estático, textos literales, comentarios, config pura.

Toda exención debe quedar documentada explícitamente en el PLAN o en el artefacto de test-strategy del ticket.
