# Arquetipo backend — Java + Spring Boot

Arquetipo genérico y market-standard para construir servicios backend en **Java + Spring Boot** dentro de Sooft Technology, siguiendo la metodología **Sooft Engineering AI Rails**. Es material de referencia para agentes de IA y developers: define estructura, dependencias transversales y decisiones por defecto para arrancar un servicio nuevo sin reinventar la base.

## Qué es y cuándo usarlo

Usá este arquetipo cuando necesites levantar cualquiera de estos servicios:

- **Microservicio**: unidad de negocio acotada, con su propio ciclo de vida y datos.
- **API REST**: expone recursos vía HTTP/JSON a consumidores internos o externos.
- **BFF (Backend For Frontend)**: agrega y adapta datos de varios servicios para un frontend específico (web o mobile).

No lo uses para batch jobs de larga duración, funciones serverless efímeras o procesamiento de streaming pesado: esos casos ameritan otro arquetipo.

## Layout de proyecto recomendado

Organización por capas con paquetes por responsabilidad. Raíz típica: `com.sooft.<servicio>`.

```
src/main/java/com/sooft/<servicio>/
├── Application.java              # Clase main con @SpringBootApplication
├── config/                       # @Configuration, beans, properties tipadas (@ConfigurationProperties)
├── web/
│   ├── controller/               # @RestController — solo orquestación HTTP, sin lógica de negocio
│   ├── dto/                       # Request/Response DTOs (nunca exponer entidades de dominio)
│   ├── mapper/                    # Mapeo DTO <-> dominio (MapStruct o manual)
│   └── error/                     # @RestControllerAdvice + envelope de error
├── service/                      # Lógica de negocio, transacciones, casos de uso
├── domain/                       # Modelo de dominio, entidades, value objects, reglas invariantes
├── repository/                   # Puertos de persistencia (Spring Data repos / interfaces)
├── client/                       # Clientes HTTP a servicios externos (con timeouts y resiliencia)
└── common/                       # Utilidades transversales sin dependencia de negocio

src/main/resources/
├── application.yml               # Config base (sin secretos)
├── application-<env>.yml         # Overrides por entorno (local, dev, prod)
└── db/migration/                 # Scripts de migración (Flyway/Liquibase)

src/test/java/...                 # Tests unit + integración, espejando el layout de main
```

Reglas de dependencia entre capas:

- `web` depende de `service`; `service` depende de `domain` y `repository`; `client` es consumido por `service`.
- El `domain` no depende de frameworks de infraestructura ni de `web`.
- Los DTOs viven en `web`; nunca serialices entidades de dominio directo a la respuesta HTTP.

## Cómo bootstrapear un proyecto nuevo

1. Generá el esqueleto con **Spring Initializr** (start.spring.io) o el plugin equivalente de tu IDE.
2. Elegí:
   - **Build**: Maven 3.9+ o Gradle 8+ (definí uno por convención de equipo y mantenelo).
   - **Java**: 21 LTS.
   - **Spring Boot**: 3.x (última minor estable).
   - Dependencias base: `Spring Web`, `Spring Boot Actuator`, `Validation`, `Spring Data JPA` (si hay persistencia), `springdoc-openapi`.
3. Renombrá el paquete raíz a `com.sooft.<servicio>` y armá los paquetes del layout de arriba.
4. Configurá `application.yml` con defaults seguros y perfiles por entorno.
5. Agregá el `Dockerfile` multi-stage y el pipeline de CI (build, test, escaneo de dependencias).
6. Escribí un primer test de integración con Testcontainers que levante el contexto y un smoke test del health check.

El detalle de librerías y versiones está en [`tech-stack.md`](./tech-stack.md).

## Preocupaciones transversales

### Configuración (12-factor)

- Config por entorno vía variables de entorno y perfiles de Spring (`application-<env>.yml`), nunca hardcodeada.
- Tipá la config con `@ConfigurationProperties` y validala al arranque con Bean Validation.
- Ningún secreto en el repo ni en `application.yml`: inyectalos por variable de entorno o un gestor de secretos del entorno de ejecución.

### Logging estructurado

- SLF4J como fachada + Logback con salida **JSON** en entornos no-locales (facilita ingestión y búsqueda).
- Incluí correlation/trace id en cada log (MDC + propagación de contexto).
- **Nunca loguees PII, credenciales ni tokens.** Enmascará o excluí esos campos explícitamente.

### Manejo global de excepciones + envelope de error

- Centralizá el manejo con `@RestControllerAdvice`.
- Devolvé un envelope de error consistente y sin filtrar detalles internos (stack traces, SQL, rutas de clases). Formato sugerido:

```json
{
  "timestamp": "2026-07-26T12:00:00Z",
  "status": 400,
  "error": "VALIDATION_ERROR",
  "message": "El campo 'email' es inválido",
  "traceId": "b1f2...",
  "details": []
}
```

- Mapeá excepciones de dominio a códigos HTTP explícitos; el default para lo no controlado es 500 con mensaje genérico.

### Validación de input

- Bean Validation (Jakarta Validation) sobre los DTOs de entrada (`@Valid`, `@NotNull`, `@Size`, etc.).
- Validá en el borde (controllers) y reforzá invariantes en el dominio. No confíes en input externo.

### Health checks

- Spring Boot Actuator: exponé `health`, `info` y `metrics`. Usá liveness/readiness probes para orquestadores.
- Restringí endpoints sensibles de Actuator y no expongas detalles internos sin autenticación.

### Cliente HTTP con timeouts y resiliencia

- Cliente HTTP con **timeouts explícitos** (connect y read) siempre configurados; nunca timeouts infinitos.
- Aplicá retry con backoff, circuit-breaker y bulkhead con Resilience4j para dependencias externas.
- Aislá los clientes en el paquete `client` y devolvé errores de dominio, no excepciones de bajo nivel.

### Observabilidad

- Métricas con Micrometer; trazas distribuidas con OpenTelemetry.
- Propagá el trace id a través de llamadas HTTP salientes y logs.
- Exponé métricas de negocio además de las técnicas (latencia, throughput, tasa de error).

### Seguridad

- Spring Security para autenticación/autorización; asegurá endpoints por defecto (deny by default).
- Sin secretos hardcodeados; gestión de secretos por entorno.
- Sin PII en logs; validación estricta de input; dependencias sin CVEs conocidos (ver escaneo en `tech-stack.md`).
- Aplicá el principio de menor privilegio en accesos a datos y servicios.

## Reglas cross-stack

Para las reglas que aplican a todos los arquetipos (independientes del lenguaje), ver [`../golden-rules.md`](../golden-rules.md).
