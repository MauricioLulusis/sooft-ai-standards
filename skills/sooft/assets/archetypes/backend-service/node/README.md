# Arquetipo backend — Node.js (Express / Fastify)

Arquetipo genérico y market-standard para servicios backend en Node.js con TypeScript.
Material de referencia para agentes de IA y developers bajo la metodología **Sooft Engineering AI Rails**.

## Qué es y cuándo usarlo

Este arquetipo describe cómo estructurar un servicio HTTP en Node.js siguiendo prácticas
estándar de la industria (12-factor, separación por capas, config por entorno).

Usalo cuando necesites:

- Una **API REST** liviana de negocio.
- Un **microservicio** de dominio acotado con superficie HTTP.
- Un **BFF (Backend For Frontend)** liviano que orqueste llamados a otros servicios y adapte la respuesta a un cliente específico.

> **Nota:** para aplicaciones con arquitectura **opinada** (inyección de dependencias
> integrada, módulos, decorators, estructura impuesta por el framework) conviene usar el
> arquetipo NestJS. Ver [`../nest/README.md`](../nest/README.md).

No lo uses para: jobs batch puros sin superficie HTTP, funciones serverless triviales
(donde el overhead del framework no se justifica) o front-end.

## Layout recomendado

Estructura por capas dentro de `src/`. El objetivo es que las dependencias apunten hacia
adentro (el `domain` no conoce HTTP ni base de datos):

```text
src/
  routes/           # Express: definición de rutas y binding a handlers
  plugins/          # Fastify: plugins encapsulados (equivalente a routes + wiring)
  controllers/      # (Express) parseo de request, invocación de service, armado de response
  handlers/         # (Fastify) equivalente a controllers en el mundo Fastify
  services/         # lógica de aplicación / orquestación de casos de uso
  domain/            # entidades, value objects y reglas de negocio puras (sin I/O)
  repositories/      # acceso a persistencia (interfaces + implementación)
  clients/           # clientes de servicios externos (HTTP, colas, cache)
  config/            # carga y validación de configuración por entorno
  middlewares/       # cross-cutting: auth, logging, manejo de errores, rate limit
  app.ts             # composición de la app (framework + middlewares + rutas)
  server.ts          # bootstrap: levanta el puerto, maneja señales de shutdown
tests/
  unit/              # tests de services y domain (sin red ni DB)
  integration/       # tests de rutas end-to-end con supertest / inject
```

Regla de dependencias: `routes/plugins` → `controllers/handlers` → `services` → `domain` /
`repositories` / `clients`. Nunca al revés.

## Bootstrap

1. Inicializar el proyecto y el control de versiones de dependencias:

   ```bash
   npm init -y
   npm pkg set type=module
   ```

2. TypeScript 5.x y ejecución en desarrollo con `tsx` (o `ts-node`):

   ```bash
   npm install -D typescript tsx @types/node
   npx tsc --init --strict --module nodenext --target es2022 --outDir dist
   ```

   Scripts sugeridos en `package.json`:

   ```json
   {
     "scripts": {
       "dev": "tsx watch src/server.ts",
       "build": "tsc -p tsconfig.json",
       "start": "node dist/server.js",
       "test": "vitest run"
     }
   }
   ```

3. Elección de framework — **Express vs Fastify**:

   - **Fastify** (recomendado por defecto): mayor throughput, validación y serialización
     basadas en JSON Schema de fábrica, sistema de plugins con encapsulamiento, hooks de
     ciclo de vida y buena integración con OpenAPI. Ideal para microservicios donde
     performance y contratos importan.
   - **Express 5**: máximo ecosistema y familiaridad. Elegilo si el equipo ya lo domina o
     dependés de middlewares específicos del ecosistema Express. Requiere sumar validación
     y logging estructurado manualmente.

   Elegí uno solo por servicio y mantené la coherencia en todo el repo.

## Preocupaciones transversales

- **Configuración por entorno (12-factor):** toda la config viene de variables de entorno,
  nunca hardcodeada. Cargar en `config/` y **validar el esquema de env al arranque** con
  `zod` (o `envalid`); si falta una variable requerida, el proceso falla rápido (fail-fast)
  antes de aceptar tráfico. Nunca commitear `.env`; versionar solo un `.env.example`.
- **Secretos:** jamás en el código ni en el repo. Inyectados por entorno (variables de
  entorno o gestor de secretos de la plataforma). No loguear secretos ni PII.
- **Logging estructurado:** usar `pino` con salida JSON. Incluir un `requestId`/`traceId`
  por request para correlación. **Nunca loguear PII, tokens, passwords ni payloads
  sensibles** — usar redacción (`redact`) para campos como `authorization`, `password`,
  `email`.
- **Manejo global de errores + envelope:** un middleware/hook central captura errores y
  responde con un envelope consistente, por ejemplo:

  ```json
  { "error": { "code": "VALIDATION_ERROR", "message": "…", "traceId": "…" } }
  ```

  No filtrar stack traces ni detalles internos al cliente en producción. Distinguir errores
  esperados (4xx) de inesperados (5xx).
- **Validación de input:** validar y tipar todo input externo (body, query, params,
  headers) con `zod` en el borde de la aplicación. En Fastify se puede usar además JSON
  Schema para validación + serialización. No confiar nunca en datos del cliente.
- **Health checks:** exponer `/health/live` (liveness — el proceso responde) y
  `/health/ready` (readiness — dependencias como DB y servicios externos disponibles) para
  orquestadores.
- **Cliente HTTP saliente:** usar `undici` (nativo, performante) o `axios`, siempre con
  **timeouts**, **reintentos con backoff** en errores transitorios e idempotentes, y
  circuit breaking cuando corresponda. Nunca llamadas sin timeout.
- **Observabilidad:** instrumentar con **OpenTelemetry** (traces y métricas). Propagar
  contexto de trazas hacia servicios downstream y correlacionar con los logs vía `traceId`.
- **Seguridad HTTP:** aplicar `helmet` (Express) o `@fastify/helmet` para headers seguros,
  `rate limiting` para mitigar abuso, CORS restrictivo y límites de tamaño de payload.
  Mantener dependencias **sin CVEs** (ver `npm audit` / Dependabot).

## Reglas de oro

Antes de codear, revisá las [reglas de oro del arquetipo](../golden-rules.md).
