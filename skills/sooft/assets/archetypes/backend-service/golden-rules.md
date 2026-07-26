# Golden Rules — Backend (Sooft)

Reglas de oro **transversales** (cross-stack) para el desarrollo de servicios backend en
**Sooft Technology**: arquitectura, convenciones de nombres, seguridad y tests. Aplican a
cualquier stack —**Java + Spring, .NET (ASP.NET Core), Node.js, NestJS, Python (FastAPI)**—
salvo donde una nota indique lo contrario.

> Esta es la capa **cross-stack**: lo que vale para todo backend de Sooft. El detalle por
> tecnología vive en cada arquetipo (`java/`, `dotnet/`, `node/`, `nest/`, `python/`).
> No reemplaza a `SECURITY.md` ni a `GOVERNANCE.md`: los reafirma a nivel de desarrollo.
> Están alineadas con prácticas de arquitectura vigentes a 2026 y con el ciclo **SDLC** y el
> enfoque **SDD (Spec-Driven Development)** de la metodología Sooft.

## Contenido

1. [Reglas de arquitectura](#1-reglas-de-arquitectura)
2. [Convenciones de nombres (naming)](#2-convenciones-de-nombres-naming)
3. [Restricciones no negociables (seguridad)](#3-restricciones-no-negociables-seguridad)
4. [Estándar de tests](#4-estándar-de-tests)
5. [Observabilidad](#5-observabilidad)

---

## 1. Reglas de arquitectura

### 1.1 Separación de capas (no negociable)

Las dependencias van en **un solo sentido**, de afuera hacia adentro:

```
API (Controller/Handler/Router) → Application (Service/UseCase) → Domain → Adapters (Repository / HTTP Client)
```

- **API**: recibe el request, valida la entrada (DTO/schema) y delega. **Sin lógica de negocio.**
- **Application / Service**: orquesta el caso de uso. Es el corazón de la lógica.
- **Domain**: entidades y reglas de negocio puras, sin dependencias de framework ni de I/O.
- **Adapters**: acceso a datos (repository) y llamadas a servicios externos (client HTTP).

**Prohibido:** lógica de negocio en la capa API · acceso directo a base de datos desde la API ·
dependencias invertidas (el dominio no conoce el framework) · acoplar el dominio a librerías de infraestructura.

> Regla práctica: el **dominio no importa nada** de web, ORM ni HTTP. Si tenés que mockear
> media app para testear una regla de negocio, la capa está mal cortada.

### 1.2 Config por entorno (12-factor)

- Toda config (endpoints, credenciales, flags) viaja por **variables de entorno**, nunca hardcodeada.
- La config se **carga y valida al arranque** (fail-fast): si falta o es inválida, el servicio no levanta.
- Un solo build, muchos entornos: no hay ramas de código por ambiente.

### 1.3 Contrato de respuesta consistente

- Todas las respuestas de una API comparten una forma consistente y documentada.
- Los **errores** usan un formato estándar y predecible. Recomendado: **RFC 7807 (Problem Details)**
  o un envelope propio uniforme (`code`, `message`, `details`, `traceId`).
- **Nunca** se exponen stack traces, rutas internas ni detalles de infraestructura al cliente.
- Usá los códigos de estado HTTP correctos; no devuelvas `200` con un error adentro.

### 1.4 API-first / contract-first

- El contrato (**OpenAPI**) es la fuente de verdad del API. Se define/actualiza **antes** de implementar
  (coherente con SDD). Da igual si después se genera código desde el spec o se documenta desde el código,
  pero el contrato existe, está versionado y se revisa.
- Cambios que rompen el contrato → versionado explícito y comunicación a los consumidores.

### 1.5 Resiliencia en llamadas externas

- Todo cliente HTTP saliente tiene **timeouts** explícitos, **reintentos** con backoff donde tenga sentido,
  y **circuit breaker** para dependencias críticas.
- Idempotencia en operaciones que se puedan reintentar. Degradación elegante ante fallas de terceros.

### 1.6 Cambios sobre código existente

- Leé antes de tocar; hacé el **cambio mínimo** necesario.
- Los tests existentes siguen pasando salvo cambio de comportamiento aprobado en el PLAN.
- Sin refactors fuera del alcance del trabajo (si aparece uno grande, se registra como trabajo aparte).

---

## 2. Convenciones de nombres (naming)

### 2.1 Generales (todo stack)

- Identificadores de código (clases, métodos, variables) **en inglés**, descriptivos, sin abreviaturas ambiguas.
- Una unidad = una responsabilidad, y el nombre lo refleja. El nombre dice **qué hace**, no cómo.

### 2.2 Por stack

| Concepto | Java + Spring | .NET | Node / NestJS | Python (FastAPI) |
|---|---|---|---|---|
| Archivos | `PascalCase.java` | `PascalCase.cs` | `kebab-case.ts` con sufijo de rol | `snake_case.py` |
| Clases / tipos | `PascalCase` | `PascalCase` | `PascalCase` | `PascalCase` |
| Métodos / variables | `camelCase` | `PascalCase` (métodos), `camelCase` (locales) | `camelCase` | `snake_case` |
| Constantes | `UPPER_SNAKE_CASE` | `PascalCase` | `UPPER_SNAKE_CASE` | `UPPER_SNAKE_CASE` |
| Paquetes / carpetas | `lowercase` | `PascalCase` (namespaces) | `kebab-case` | `snake_case` |
| Controller / handler | `XxxController` | `XxxController` | `xxx.controller.ts` | `routers/xxx.py` |
| Service / use case | `XxxService` | `XxxService` | `xxx.service.ts` | `services/xxx.py` |
| Test | `XxxTest` | `XxxTests` | `xxx.spec.ts` | `test_xxx.py` |

### 2.3 Git (ramas y commits)

- **Ramas** por tipo de trabajo: `feat/...`, `fix/...`, `hot-fix/...`, `chore/...`, `security/...`.
- **Commits**: [conventional commits](https://www.conventionalcommits.org) (`type(scope): descripción`),
  con el razonamiento (qué / por qué) en el cuerpo cuando el cambio lo amerite.
- **Trazabilidad IA**: el código generado por IA se marca para revisión humana antes del PR
  (ej. `// [IA-generated] Sooft — revisar antes de merge`).

---

## 3. Restricciones no negociables (seguridad)

Límites absolutos, alineados con **OWASP Top 10 / ASVS**:

- **Sin secretos hardcodeados** (tokens, credenciales, connection strings, API keys). Siempre por entorno o gestor de secretos.
- **Sin datos personales (PII) en logs**: emails, documentos, teléfonos, tarjetas, tokens. Enmascarar o no loguear.
- **Validar todo input externo** antes de procesarlo (tipos, rangos, formato). Nunca confiar en el cliente.
- **Menor privilegio** siempre (DB, red, cloud, tokens de terceros).
- Consultas parametrizadas / ORM — **nunca** SQL armado por concatenación de strings.
- **Sin dependencias nuevas sin justificación** registrada en el PLAN aprobado; y sin CVEs de severidad alta.
- Controles antes del PR: linter + análisis estático (SAST) + escaneo de dependencias (SCA). Los hallazgos de
  severidad alta **bloquean** el PR. Las herramientas concretas las define cada proyecto (ej. SonarQube, Semgrep,
  CodeQL, Trivy, `npm audit`, `pip-audit`, OWASP Dependency-Check) — la metodología exige el control, no una marca.

---

## 4. Estándar de tests

- **Cobertura objetivo ≥ 80%** sobre código con lógica (se excluye config, constantes, DTOs/modelos sin lógica, código autogenerado).
- Lógica nueva → **test primero (TDD)**; bug → **test de reproducción** (rojo) antes del fix.
- Los tests unitarios corren **sin dependencias externas** (mockear I/O). Integración con dobles reales acotados
  (ej. Testcontainers / bases efímeras) donde aporte.
- La pirámide de tests aplica: muchos unitarios, algunos de integración, pocos e2e.

| Stack | Framework | Integración |
|---|---|---|
| Java + Spring | JUnit 5 + Mockito | Testcontainers |
| .NET | xUnit + FluentAssertions | Testcontainers |
| Node / NestJS | Vitest / Jest + supertest | Testcontainers |
| Python (FastAPI) | pytest | httpx test client + contenedores efímeros |

---

## 5. Observabilidad

- **Logging estructurado** (JSON) con nivel, timestamp y correlación (`traceId`). Nada de `print`/`console.log` sueltos.
- **Trazas y métricas** con **OpenTelemetry** (estándar transversal a todos los stacks); exportables al backend que use el proyecto.
- **Health checks** (`/health` liveness + readiness) en todo servicio.
- Correlación de request punta a punta (propagar el `traceId` en llamadas salientes).

---

## Historial de cambios

| Fecha | Autor | Cambio |
|-------|-------|--------|
| 2026-07-26 | Sooft | Versión inicial cross-stack (Java, .NET, Node, NestJS, Python) — genérica, alineada a SDLC + SDD y arquitectura 2026 |
