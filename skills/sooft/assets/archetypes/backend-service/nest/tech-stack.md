# Stack — NestJS

Stack recomendado de **Sooft Technology** para servicios backend en NestJS. Solo paquetes estándar del mercado (npm público / open-source).

| Preocupación | Elección recomendada | Notas |
|---|---|---|
| Runtime | Node.js 20 LTS+ | LTS con soporte a largo plazo; fijá la versión en `.nvmrc` y en la imagen del contenedor. |
| Lenguaje | TypeScript 5.x | `strict: true` en `tsconfig`. Sin `any` implícito. |
| Framework | NestJS 10 (adapter Express o Fastify) | Express por defecto (ecosistema amplio); Fastify cuando priorizás throughput y menor overhead. |
| Testing | Jest + supertest (e2e) | Unit con Jest y mocks de dependencias; e2e levantando la app real con supertest sobre HTTP. |
| Logging | nestjs-pino (JSON) | Logs estructurados en JSON; redacción de campos sensibles; `LOG_LEVEL` por entorno. |
| Validación | class-validator + class-transformer | `ValidationPipe` global con `whitelist: true`, `forbidNonWhitelisted: true`, `transform: true`. |
| Config | @nestjs/config con schema de validación | Falla el arranque si falta/es inválida una env requerida. Config solo por entorno (12-factor). |
| API docs | @nestjs/swagger | Genera OpenAPI desde DTOs y decoradores; publicá el spec para consumidores. |
| Cliente HTTP | @nestjs/axios + reintentos | Timeouts explícitos y retry con backoff exponencial solo para errores transitorios/idempotentes. |
| Health | @nestjs/terminus | Endpoints de liveness y readiness (DB, memoria, downstream) para probes del orquestador. |
| Observabilidad | OpenTelemetry | Traces + métricas; propagación de contexto W3C `traceparent`; correlación con logs. |
| Persistencia | Prisma o TypeORM (con migraciones) | Aislá el ORM tras la capa repository. Migraciones versionadas y aplicadas en el pipeline. |
| Seguridad | helmet, guards JWT/passport, @nestjs/throttler, secretos por entorno | Headers seguros con helmet; auth por guards; rate limiting con throttler; **cero secretos hardcodeados** ni PII en logs. |
| Contenedor | Dockerfile multi-stage, node:20-slim | Build en una stage, runtime mínimo en otra; imagen `node:20-slim`; usuario no-root; `NODE_ENV=production`. |

## Versionado y actualización

- **Lockfile commiteado**: `package-lock.json` (o `pnpm-lock.yaml` / `yarn.lock`) siempre en el repositorio para builds reproducibles.
- **`npm audit`** en el pipeline de CI; fallá el build ante vulnerabilidades altas/críticas y remediá antes de mergear.
- **Dependabot** (o Renovate) habilitado para actualizaciones automáticas de dependencias y parches de seguridad, revisadas por PR.
- Fijá versiones mayores de forma explícita; probá las actualizaciones con la suite de tests (unit + e2e) antes de promover.
- Mantené las dependencias **sin CVEs conocidos**: monitoreo continuo y actualización proactiva.
