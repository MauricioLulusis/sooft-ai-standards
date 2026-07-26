# Arquetipo backend — .NET (ASP.NET Core)

Material de referencia de **Sooft Technology** bajo la metodología **Sooft Engineering AI Rails**. Describe un backend genérico, market-standard, para construir servicios en .NET usando únicamente herramientas y librerías públicas (nuget.org, open-source).

## Qué es y cuándo usarlo

Este arquetipo aplica cuando necesitás exponer un **servicio HTTP** en .NET:

- **Microservicio** con responsabilidad acotada dentro de un dominio.
- **Web API** REST tradicional (controllers) para dominios con muchos endpoints, filtros y convenciones.
- **Minimal API** para servicios chicos, gateways o BFFs donde el overhead de controllers no se justifica.

Usalo como punto de partida para cualquier servicio nuevo. No lo uses para librerías puras, workers sin superficie HTTP (aunque varias secciones transversales siguen aplicando) o front-ends.

## Layout recomendado (Clean Architecture liviana)

Separación en cuatro proyectos. La regla de dependencia apunta siempre hacia adentro: `Domain` no depende de nadie; `Application` depende solo de `Domain`; `Infrastructure` y `Api` implementan y componen.

```
src/
  MyService.Api/            # Host web: endpoints, DI, middleware, config. Punto de entrada.
  MyService.Application/    # Casos de uso, DTOs, interfaces (puertos), validaciones.
  MyService.Domain/         # Entidades, value objects, reglas de negocio. Sin dependencias externas.
  MyService.Infrastructure/ # Implementaciones: EF Core, clientes HTTP, mensajería, repos.
tests/
  MyService.UnitTests/          # Dominio y aplicación aislados.
  MyService.IntegrationTests/   # API + dependencias reales (Testcontainers).
```

Referencias de dependencias:

- `Api` → `Application`, `Infrastructure`
- `Infrastructure` → `Application`, `Domain`
- `Application` → `Domain`
- `Domain` → (ninguna)

Las interfaces (puertos) viven en `Application`; sus implementaciones (adapters) en `Infrastructure`. Esto mantiene el núcleo testeable y desacoplado de detalles de infra.

## Bootstrap de proyecto nuevo

```bash
# Solución y proyectos
dotnet new sln -n MyService

dotnet new webapi   -n MyService.Api            -o src/MyService.Api
dotnet new classlib -n MyService.Application    -o src/MyService.Application
dotnet new classlib -n MyService.Domain         -o src/MyService.Domain
dotnet new classlib -n MyService.Infrastructure -o src/MyService.Infrastructure

dotnet new xunit -n MyService.UnitTests        -o tests/MyService.UnitTests
dotnet new xunit -n MyService.IntegrationTests -o tests/MyService.IntegrationTests

# Agregar a la solución
dotnet sln add (Get-ChildItem -Recurse *.csproj)   # PowerShell
# o: dotnet sln add $(find . -name "*.csproj")      # bash

# Referencias entre proyectos
dotnet add src/MyService.Application    reference src/MyService.Domain
dotnet add src/MyService.Infrastructure reference src/MyService.Application src/MyService.Domain
dotnet add src/MyService.Api            reference src/MyService.Application src/MyService.Infrastructure

# Compilar y testear
dotnet build
dotnet test
```

Para Minimal API, arrancá igual con `dotnet new webapi` y definí los endpoints con `app.MapGet/MapPost` en lugar de controllers, o usá grupos con `MapGroup`.

## Preocupaciones transversales

Todas se configuran en `MyService.Api` (composición) y se consumen vía interfaces desde las capas internas.

### Configuración (12-factor)

- Usá `appsettings.json` como base y `appsettings.{Environment}.json` para overrides por entorno.
- Todo valor sensible o específico de entorno viene de **variables de entorno**, nunca hardcodeado ni commiteado.
- Bindeá secciones a POCOs con el patrón **IOptions**: `builder.Services.Configure<MyOptions>(builder.Configuration.GetSection("My"))`. Inyectá `IOptions<MyOptions>` (o `IOptionsSnapshot` para reload). Validá al arranque con `.ValidateDataAnnotations().ValidateOnStart()`.
- En desarrollo, usá **user-secrets** (`dotnet user-secrets`) para no dejar credenciales en disco.

### Logging estructurado

- Emití logs en **JSON** con contexto (request id, correlation id, nombre de operación).
- **Nunca** loguees PII, secretos, tokens ni cuerpos completos de request/response con datos sensibles.
- Usá niveles correctos (`Information` para flujo normal, `Warning`/`Error` con excepción adjunta). Aprovechá logging con templates (`logger.LogInformation("User {UserId} created", id)`), no interpolación de strings.

### Manejo global de excepciones + envelope de error

- Centralizá el manejo con middleware (`IExceptionHandler` en .NET 8 o middleware propio). Ninguna excepción debe filtrar stack traces ni detalles internos al cliente.
- Respondé con **ProblemDetails** (RFC 7807) como envelope estándar: `type`, `title`, `status`, `detail`, `traceId`. Mapeá excepciones de dominio a códigos HTTP apropiados (400, 404, 409, 422) y todo lo inesperado a 500 genérico.

### Validación

- Validá toda entrada en el borde. Usá **FluentValidation** para reglas complejas o **DataAnnotations** para casos simples.
- Rechazá payloads inválidos con 400/422 y un envelope de error consistente. No confíes en datos externos sin validar.

### Health checks

- Exponé `/health/live` (liveness) y `/health/ready` (readiness con checks de dependencias: base de datos, colas, servicios upstream) vía `AddHealthChecks()`.
- Readiness debe reflejar la capacidad real de servir tráfico; usalo para probes de orquestador.

### Cliente HTTP con resiliencia

- Consumí servicios externos con **IHttpClientFactory** (typed clients), nunca instanciando `HttpClient` a mano.
- Agregá políticas de resiliencia con **Polly**: retry con backoff exponencial + jitter, circuit breaker y timeout. En .NET 8 podés usar `AddStandardResilienceHandler()`.

### Observabilidad

- Instrumentá con **OpenTelemetry .NET**: traces, métricas y correlación de logs. Exportá vía OTLP a tu backend de observabilidad.
- Propagá `traceparent` en llamadas salientes para trazabilidad distribuida punta a punta.

### Seguridad

- Autenticación/autorización con **JWT Bearer** o ASP.NET Core Identity según el caso; protegé endpoints con `[Authorize]` / políticas.
- Sin secretos hardcodeados: todo por entorno / user-secrets / secret manager. Protegé datos en reposo sensibles con **Data Protection**.
- Forzá HTTPS, headers de seguridad y CORS restrictivo. Mantené dependencias **sin CVEs** (ver `tech-stack.md`).

## Reglas de oro

Antes de codear, revisá las [reglas de oro transversales](../golden-rules.md).
