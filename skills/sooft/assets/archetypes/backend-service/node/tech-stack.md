# Stack — Node.js

Stack recomendado, genérico y market-standard, para servicios backend en Node.js bajo la
metodología **Sooft Engineering AI Rails**. Solo librerías estándar de npm público /
open-source.

| Preocupación | Elección recomendada | Notas |
|---|---|---|
| Runtime | Node.js 20 LTS+ | Usar siempre una versión LTS activa. Fijar la versión en `engines` y en el runtime del contenedor. |
| Lenguaje | TypeScript 5.x | `strict: true`. Sin `any` implícitos. Compilar a ES2022. |
| Framework | Express 5 o **Fastify** | **Recomendado Fastify** por mayor performance, validación por JSON Schema, serialización rápida y sistema de plugins. Express 5 si el equipo prioriza ecosistema/familiaridad. |
| Testing | Vitest o Jest + `supertest` | Vitest (rápido, ESM-first) o Jest. `supertest` para tests de integración HTTP (en Fastify también sirve `app.inject`). Unit para services/domain, integración para rutas. |
| Logging | `pino` (JSON) | Logs estructurados en JSON. Redacción de campos sensibles (`authorization`, `password`, `email`). Correlación por `traceId`. |
| Validación | `zod` | Validar y tipar todo input externo en el borde. Inferir tipos desde los esquemas. |
| API docs | OpenAPI + `swagger-ui-express` / `@fastify/swagger` | Documentar contratos con OpenAPI. `@fastify/swagger` (+ `@fastify/swagger-ui`) genera el spec desde los schemas; en Express usar `swagger-ui-express`. |
| Cliente HTTP | `undici` o `axios` + reintentos | `undici` (nativo, performante) o `axios`. Siempre con timeouts, reintentos con backoff en errores transitorios/idempotentes y circuit breaking. |
| Observabilidad | OpenTelemetry SDK for Node | Traces y métricas. Propagación de contexto a downstream. Exportar a un backend OTLP-compatible. |
| Persistencia | Prisma o Drizzle / `pg` | ORM/query-builder tipado (Prisma o Drizzle) sobre `pg`. **Migraciones versionadas** en el repo. Sin credenciales hardcodeadas. |
| Seguridad | `helmet` / `@fastify/helmet`, rate limiting, `jsonwebtoken`, secretos por entorno | Headers seguros con `helmet` (Express) o `@fastify/helmet` (Fastify). Rate limiting contra abuso. `jsonwebtoken` para JWT (validar `exp`, `iss`, `aud`). Secretos inyectados por entorno, nunca en el repo. |
| Contenedor | Dockerfile multi-stage — `node:20-slim` / distroless | Build multi-stage (deps + build → runtime mínimo). Imagen final `node:20-slim` o distroless. Correr como usuario no-root. |

## Versionado y actualización

- **Auditoría de dependencias:** correr `npm audit` en CI y habilitar **Dependabot** (o
  Renovate) para actualizaciones automáticas. Resolver CVEs de forma prioritaria; no
  liberar con vulnerabilidades altas/críticas conocidas.
- **`engines` en `package.json`:** declarar la versión de Node soportada, por ejemplo:

  ```json
  { "engines": { "node": ">=20 <21" } }
  ```

- **Lockfile commiteado:** versionar siempre el `package-lock.json` (o el lockfile del
  gestor elegido) e instalar de forma reproducible en CI con `npm ci`.
- **Actualizaciones controladas:** subir versiones mayores en PRs aislados, con la suite de
  tests en verde y revisando changelogs por breaking changes.
