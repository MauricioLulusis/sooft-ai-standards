# Arquetipo backend — NestJS

Material de referencia de **Sooft Technology** para agentes de IA y developers.
Metodología: **Sooft Engineering AI Rails**. Marca: **Sooft**.

## Qué es y cuándo usarlo

Arquetipo genérico y market-standard para construir servicios backend con **NestJS (TypeScript)**. Usalo como base cuando necesites:

- **Microservicio** de dominio acotado con contratos claros (HTTP/REST o mensajería).
- **API REST** pública o interna con validación fuerte, documentación OpenAPI y observabilidad.
- **BFF (Backend For Frontend)** que orquesta llamadas a servicios downstream y adapta payloads para un canal específico (web, mobile).

NestJS aporta una arquitectura **opinada y modular** basada en inyección de dependencias, decoradores y separación explícita de capas. Es la elección recomendada cuando querés consistencia entre equipos, testabilidad alta y un camino claro para escalar de un monolito modular a microservicios.

No lo uses para: scripts efímeros, funciones serverless muy simples (un handler y nada más) o prototipos descartables donde el overhead de la estructura no se justifica.

## Layout recomendado

Organización **por feature** (vertical slice): cada capacidad de negocio vive en su propio módulo y encapsula sus capas. Los módulos transversales (config, logging, health) se comparten.

```
src/
  main.ts                      # bootstrap: crea la app, aplica pipes/filters globales
  app.module.ts                # módulo raíz: importa features + transversales
  config/
    config.module.ts           # ConfigModule con validación de env
    env.validation.ts          # schema de variables de entorno
  common/
    filters/                   # ExceptionFilter global (envelope de error)
    interceptors/              # logging, timeout, transform de respuesta
    guards/                    # auth (JWT), roles
    dto/                       # DTOs compartidos (paginación, etc.)
  health/
    health.module.ts           # @nestjs/terminus
    health.controller.ts       # /health/liveness, /health/readiness
  <feature>/                   # ej: orders, users, payments
    <feature>.module.ts
    <feature>.controller.ts    # capa de entrada HTTP (routing, status codes)
    <feature>.service.ts       # lógica de negocio (orquestación, reglas)
    dto/                       # request/response DTOs + validación
      create-<feature>.dto.ts
      update-<feature>.dto.ts
    entities/                  # entidades de dominio / persistencia
      <feature>.entity.ts
    repository/                # acceso a datos (aísla el ORM del service)
      <feature>.repository.ts
test/
  <feature>.e2e-spec.ts        # tests end-to-end con supertest
```

Reglas de dependencia entre capas:

- El **controller** no contiene lógica de negocio: valida entrada (vía DTO + `ValidationPipe`), delega en el service y mapea la respuesta.
- El **service** concentra la lógica de negocio y depende de abstracciones (repository, clientes HTTP), nunca de detalles de framework HTTP.
- El **repository** aísla el ORM/driver. Si mañana cambiás de Prisma a TypeORM, solo tocás esta capa.
- Los **DTO** definen el contrato de entrada/salida y son el punto de validación y documentación (Swagger).

## Bootstrap

```bash
# 1. Crear el proyecto (elegí npm/pnpm/yarn de forma consistente en el equipo)
npx @nestjs/cli new mi-servicio

# 2. Dependencias transversales base
npm install @nestjs/config nestjs-pino pino-http \
  class-validator class-transformer \
  @nestjs/terminus @nestjs/axios axios \
  @nestjs/swagger helmet @nestjs/throttler

# 3. Generar un feature con estructura completa
npx nest generate module orders
npx nest generate controller orders
npx nest generate service orders
```

Estructura de módulos: el `AppModule` importa los módulos transversales (`ConfigModule`, logging, `HealthModule`) y cada módulo de feature. Cada módulo declara sus `controllers`, `providers` (services, repositories) y `exports` explícitos. Mantené los módulos **cohesivos y con límites claros**: si un feature necesita algo de otro, importalo por su módulo, nunca por rutas de archivos internas.

Configuración con **`@nestjs/config`**: cargá `ConfigModule.forRoot({ isGlobal: true, validationSchema })` una sola vez en el módulo raíz. Toda configuración se lee por entorno (variables de ambiente), nunca hardcodeada. Esto alinea el servicio con **12-factor** (config en el entorno, paridad dev/prod, procesos stateless).

## Preocupaciones transversales

### ConfigModule con validación de env
Definí un schema de validación (con `class-validator` o `joi`) que falle el arranque si falta o es inválida una variable requerida. Nada de valores por defecto silenciosos para secretos. Ejemplo de variables: `NODE_ENV`, `PORT`, `LOG_LEVEL`, `DATABASE_URL`, `JWT_SECRET`. **Los secretos se inyectan por entorno** (variables de ambiente o un secret manager), nunca se commitean.

### Logging estructurado con nestjs-pino
Logging en **JSON** con `nestjs-pino`. Correlacioná requests con un `requestId` (header o generado). **Prohibido loguear PII o secretos**: definí redacción de campos sensibles (`authorization`, `password`, `token`, datos personales) vía la opción `redact` de pino. Nivel de log configurable por entorno (`LOG_LEVEL`).

### ExceptionFilter global + envelope de error
Un `ExceptionFilter` global normaliza todas las respuestas de error en un **envelope consistente**:

```json
{
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "El campo 'email' es inválido",
    "traceId": "..."
  }
}
```

Nunca expongas stack traces ni detalles internos al cliente. Logueá el detalle técnico del lado servidor y devolvé un mensaje seguro y accionable.

### ValidationPipe con DTOs
`ValidationPipe` global con `whitelist: true`, `forbidNonWhitelisted: true` y `transform: true`. Los DTOs usan `class-validator` (decoradores `@IsString`, `@IsEmail`, `@Min`, etc.) y `class-transformer` para el casteo de tipos. Esto rechaza propiedades no esperadas y previene mass-assignment.

### Health checks con @nestjs/terminus
Exponé `/health/liveness` (¿el proceso está vivo?) y `/health/readiness` (¿puede recibir tráfico? — chequea DB, dependencias). Usá los indicadores de `@nestjs/terminus` para base de datos, memoria y servicios downstream. Estos endpoints alimentan probes de Kubernetes u orquestadores.

### Cliente HTTP con retry
Usá `@nestjs/axios` (`HttpModule`) para llamadas a servicios externos. Configurá **timeouts explícitos** y **reintentos con backoff exponencial** (vía `rxjs` `retry` con `delay`, o interceptores de axios) solo para errores idempotentes/transitorios. Aplicá circuit breaking cuando corresponda.

### Interceptores
- **Logging interceptor**: mide latencia por endpoint y loguea entrada/salida (sin PII).
- **Transform interceptor**: envuelve respuestas exitosas en un formato consistente.
- **Timeout interceptor**: corta requests que exceden un umbral.

### Guards para autenticación
Guards para **auth** (`JWT` vía passport) y autorización por roles. Aplicalos a nivel controller/handler con decoradores. La verificación de token y permisos vive en el guard, no dispersa en los services.

### Observabilidad con OpenTelemetry
Instrumentá el servicio con **OpenTelemetry** (traces y métricas). Propagá el contexto de trace entre servicios (headers W3C `traceparent`) y correlacioná el `traceId` con los logs estructurados para tener trazabilidad punta a punta.

## Golden rules

Antes de dar por terminado el servicio, revisá las reglas transversales del arquetipo: [../golden-rules.md](../golden-rules.md).
