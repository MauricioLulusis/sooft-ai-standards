# Arquetipo — Backend service (Sooft)

Guía de referencia para construir **servicios backend** en Sooft Technology: APIs REST,
microservicios y BFF. Es **agnóstica del stack** en sus principios y se especializa por
tecnología en las subcarpetas.

> Estos arquetipos son **guías de buenas prácticas**, no plantillas atadas a librerías
> internas: se apoyan en herramientas estándar del mercado. Sirven para que un agente de IA
> —o un developer— arranque un servicio nuevo, o extienda uno existente, con decisiones
> arquitectónicas ya tomadas y alineadas al ciclo **SDLC** y al enfoque **SDD** de Sooft.

## Cuándo usar este arquetipo

- API REST / microservicio que expone lógica de negocio o de datos.
- BFF (Backend For Frontend) que orquesta llamadas a otros servicios para una UI.
- Servicio de integración o worker con endpoints de gestión/health.

## Stacks soportados

| Stack | Framework | Cuándo | Detalle |
|---|---|---|---|
| **Java** | Spring Boot 3.x | Servicios corporativos, alto throughput, ecosistema JVM | [`java/`](java/README.md) |
| **.NET** | ASP.NET Core (.NET 8) | Ecosistema Microsoft, equipos C# | [`dotnet/`](dotnet/README.md) |
| **Node.js** | Express / Fastify | APIs livianas, BFF, alta iteración | [`node/`](node/README.md) |
| **NestJS** | NestJS 10 | Backend TypeScript con arquitectura opinada y modular | [`nest/`](nest/README.md) |
| **Python** | FastAPI | APIs de datos, servicios ML-serving, scripting productivo | [`python/`](python/README.md) |

> Reglas transversales (obligatorias, cross-stack): [`golden-rules.md`](golden-rules.md).

## Estructura común (independiente del stack)

Todo servicio backend, sin importar el lenguaje, organiza el código en las mismas capas
(los nombres concretos cambian por stack — ver cada arquetipo):

```
api/          → controllers / routers / handlers: reciben el request, validan, delegan
application/  → services / use cases: orquestan la lógica de negocio
domain/       → entidades y reglas puras, sin dependencias de framework ni I/O
adapters/     → repositories (datos) y clients (HTTP a otros servicios)
config/       → carga y validación de configuración por entorno
```

## Preocupaciones transversales (todas se resuelven en cada arquetipo)

| Preocupación | Cómo |
|---|---|
| Configuración | Por variables de entorno, validada al arranque (fail-fast). |
| Logging | Estructurado (JSON), sin PII, con `traceId` de correlación. |
| Errores | Manejo global + contrato de error consistente (RFC 7807 o envelope propio). |
| Validación | De todo input externo, en el borde (DTO/schema). |
| Health | `/health` liveness + readiness. |
| Cliente HTTP | Timeouts, reintentos con backoff, circuit breaker. |
| Observabilidad | OpenTelemetry (trazas + métricas). |
| Seguridad | Sin secretos en código, menor privilegio, deps sin CVEs. |
| Tests | Unit (sin I/O) + integración; TDD para lógica nueva. |

## Cómo lo usa el agente

Durante el **discovery** (fase de alcance del ciclo Sooft), el agente detecta el stack del
repo y carga el arquetipo correspondiente para proponer estructura, librerías y decisiones.
Si el proyecto es nuevo, el arquetipo guía el bootstrap. Nunca se reimplementa lo que una
librería estándar ya resuelve bien.
