# Stack — Java + Spring Boot

Stack recomendado por defecto para el arquetipo backend en Java. Todas las herramientas son estándar del mercado y están disponibles en Maven Central o como imágenes públicas. Elegí las versiones estables más recientes dentro de cada línea indicada.

| Preocupación | Elección recomendada | Notas |
|---|---|---|
| Runtime | **Java 21 (LTS)** | Aprovechá virtual threads, records, pattern matching. Fijá la versión en el build y en la imagen. |
| Framework | **Spring Boot 3.x** | Última minor estable. Base para web, config, actuator e inyección de dependencias. |
| Build | **Maven 3.9+** o **Gradle 8+** | Elegí uno por convención de equipo. Usá el wrapper (`mvnw`/`gradlew`) para builds reproducibles. |
| Testing | **JUnit 5**, **Mockito**, **Testcontainers**, **AssertJ** | JUnit 5 + AssertJ para unit; Mockito para dobles de prueba; Testcontainers para integración con dependencias reales (DB, colas) en Docker. |
| Logging | **SLF4J + Logback**, salida **JSON** | Fachada SLF4J, Logback como implementación. JSON en entornos no-locales. Trace id en MDC. Nunca loguear PII ni secretos. |
| Validación | **Bean Validation (Jakarta Validation)** | Anotaciones sobre DTOs (`@Valid`, `@NotNull`, `@Size`, etc.). Validá input en el borde. |
| API docs | **springdoc-openapi** | Genera OpenAPI 3 y Swagger UI desde los controllers. Mantené los DTOs anotados y documentados. |
| Cliente HTTP | **RestClient** (síncrono) o **WebClient** (reactivo) + **Resilience4j** | Timeouts connect/read explícitos. Resilience4j para retry con backoff, circuit-breaker y bulkhead. |
| Observabilidad | **Micrometer + OpenTelemetry** | Métricas vía Micrometer; trazas distribuidas con OpenTelemetry. Propagá contexto en llamadas salientes. |
| Persistencia | **Spring Data JPA** o **Spring Data JDBC** + **Flyway** o **Liquibase** | JPA para modelos ricos; JDBC para control fino. Migraciones versionadas en `db/migration`, nunca `ddl-auto=update` en prod. |
| Seguridad | **Spring Security** + gestión de secretos por entorno | Deny by default; autenticación/autorización explícitas. Secretos por variable de entorno o gestor del entorno, nunca en el repo. |
| Contenedor | **Dockerfile multi-stage**, imagen **distroless** o **Temurin (eclipse-temurin) JRE** | Stage de build separado del runtime. Imagen final mínima, usuario no-root, sin herramientas de build. |

## Versionado y actualización

- Mantené las dependencias al día: adoptá patches de seguridad rápido y planificá los bumps de minor/major.
- Fijá versiones explícitas (via BOM de Spring Boot / dependency management); evitá rangos abiertos.
- Escaneo de vulnerabilidades en CI con **OWASP Dependency-Check** y actualizaciones automatizadas con **Dependabot** (o Renovate).
- Bloqueá el merge si hay CVEs de severidad alta/crítica sin mitigar.
- Revisá periódicamente dependencias sin mantenimiento y reemplazalas por alternativas activas.
