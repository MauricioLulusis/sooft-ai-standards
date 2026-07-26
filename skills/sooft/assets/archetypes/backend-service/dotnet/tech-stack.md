# Stack — .NET (ASP.NET Core)

Stack de referencia de **Sooft Technology** (metodología **Sooft Engineering AI Rails**). Solo herramientas y paquetes públicos de nuget.org / open-source.

| Preocupación | Elección recomendada | Notas |
|---|---|---|
| Runtime | **.NET 8 (LTS)** | Mantenerse en versión LTS por soporte extendido. Evitar STS en producción salvo necesidad puntual. |
| Framework | **ASP.NET Core Web API** (controllers) o **Minimal APIs** | Controllers para dominios grandes con muchas convenciones; Minimal APIs para servicios chicos, gateways o BFFs. |
| Testing | **xUnit** + **Moq** o **NSubstitute** + **FluentAssertions** + **Testcontainers** | xUnit como runner; mocking a elección del equipo; FluentAssertions para asserts legibles; Testcontainers para integración con dependencias reales (DB, colas) efímeras. |
| Logging | **Serilog** o **Microsoft.Extensions.Logging**, salida **JSON** | Logs estructurados con enrichers (correlation id, request id). Sin PII ni secretos. Serilog para sinks avanzados; MEL alcanza para casos simples. |
| Validación | **FluentValidation** / **DataAnnotations** | FluentValidation para reglas complejas y componibles; DataAnnotations para validaciones simples de DTOs. Validar toda entrada en el borde. |
| API docs | **Swashbuckle** (OpenAPI/Swagger) | Generar contrato OpenAPI. Exponer Swagger UI solo en entornos no productivos o detrás de auth. |
| Cliente HTTP | **IHttpClientFactory** + **Polly** | Typed clients gestionados por la factory. Polly para retry con backoff+jitter, circuit breaker y timeout. En .NET 8, `AddStandardResilienceHandler()`. |
| Observabilidad | **OpenTelemetry .NET** | Traces, métricas y logs correlacionados. Export vía OTLP. Propagación de contexto distribuido (`traceparent`). |
| Persistencia | **EF Core** + migraciones EF | `dotnet ef migrations add` / `database update`. Migraciones versionadas en el repo. Repositorios/`DbContext` detrás de interfaces en Application. |
| Seguridad | **ASP.NET Core Identity / JWT Bearer**, **Data Protection**, secretos por entorno (**user-secrets** en dev) | Autenticación/autorización por políticas. Sin secretos hardcodeados; en producción, variables de entorno o secret manager. Data Protection para datos sensibles en reposo. |
| Contenedor | **Dockerfile multi-stage**, imagen `aspnet` runtime | Stage de build con SDK (`dotnet/sdk`), stage final con runtime liviano (`dotnet/aspnet`). Ejecutar como usuario no-root. Imagen final sin SDK ni herramientas de build. |

## Versionado y actualización

- **Mantenerse en LTS** (.NET 8) y planificar el salto a la próxima LTS antes del fin de soporte.
- Automatizar actualizaciones de dependencias con **Dependabot** (o Renovate) sobre los paquetes NuGet.
- Ejecutar **`dotnet list package --vulnerable`** (NuGet audit) en CI para detectar CVEs; fallar el build ante vulnerabilidades conocidas.
- Fijar versiones de paquetes y revisar changelogs antes de subir mayores. Correr `dotnet list package --outdated` periódicamente.
