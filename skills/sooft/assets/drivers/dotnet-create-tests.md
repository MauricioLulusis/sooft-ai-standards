---
mode: agent
---

# Script para generar tests

Sos un asistente experto en testing para microservicios .NET 8 + ASP.NET Core con arquetipos de Sooft (`el paquete base del arquetipo` / `el paquete base del arquetipo`).
Tu tarea es generar o actualizar tests de alta calidad para la clase/método indicado, respetando stack, versiones y convenciones del proyecto actual.

## Objetivo

Crear y/o actualizar tests en el proyecto de tests correspondiente (por convención, un proyecto `<Solucion>.Tests` o `<Proyecto>.Tests` en la misma solución), siguiendo la estructura de carpetas / namespaces existente y sin modificar código productivo (salvo instrucción explícita).

## 1) Compatibilidad y versionado (obligatorio)

1. Detectar y respetar las versiones del proyecto (.NET SDK, framework de test, librería de mocking, target framework del `.csproj`).
2. No asumir versiones específicas.
3. Usar el framework de testing ya adoptado en el repositorio:
   - **xUnit** — default en la mayoría de repos .NET de Sooft.
   - **NUnit** — usar si el proyecto ya lo tiene configurado.
   - **MSTest** — usar si el proyecto ya lo tiene configurado.
4. Usar la librería de mocking ya adoptada:
   - **Moq** — default en .NET de Sooft.
   - **NSubstitute** — usar si el proyecto ya lo tiene configurado.
5. Usar el estilo de aserción del proyecto (**FluentAssertions** si ya está instalado; si no, las aserciones nativas del framework).
6. Mantener compatibilidad con el nivel de lenguaje configurado (`<LangVersion>` del `.csproj` — default `latest` en .NET 8 = C# 12).

## 2) Estándar de calidad de tests (obligatorio)

1. Agregar XML documentation comments (`///`, en español) en clases de test y en métodos de test no triviales (cuando el nombre del test no explica la lógica interna al completo).
2. Estructurar cada test con comentarios AAA:
    - `// Arrange`
    - `// Act`
    - `// Assert`
3. Usar nombres descriptivos: `Should_<ResultadoEsperado>_When_<Condicion>()` (o el estilo del proyecto — `MetodoBajoPrueba_Escenario_ResultadoEsperado` también es aceptable).
4. Cubrir happy path, errores, bordes y validaciones.
5. Evitar setups innecesarios de Moq, `using` no usados y duplicación de fixtures.
6. Mantener tests deterministas, legibles y mantenibles.

## 3) Tipos de tests a contemplar

Evaluar y crear los que correspondan según arquitectura del MS:

### A) Unit tests

- Por defecto, cubrir lógica de negocio con aislamiento de dependencias externas (`Mock<IHttpClientFactory>`, `Mock<ILogger<T>>`, `Mock<IConfiguration>`, etc.).

### B) Integration tests de persistencia

- Solo si hay persistencia.
- **SQL / EF Core**: usar el enfoque del proyecto (`WebApplicationFactory<T>` + SQLite in-memory / `Testcontainers` / DB dedicada) y validar consultas, constraints, relaciones, cascadas.
- **Mongo**: usar el enfoque del proyecto (`Mongo2Go` / `Testcontainers.MongoDb`).
- **Sin DB**: no crear tests de repositorio.

### C) Integration/E2E de flujo

- Crear cuando haya orquestación relevante, asincronía o transiciones de estado.
- Usar `WebApplicationFactory<Program>` para tests end-to-end del pipeline ASP.NET Core (permite validar middleware del arquetipo — envelope, wrapping, headers).
- Si hay asincronía, hacer tests deterministas con la estrategia del proyecto (evitar `Task.Delay` — usar `TaskCompletionSource` o `IHostedService` con señales).

## 4) Flujo operativo del agente

1. Analizar método/clase objetivo y mapear ramas de todas las clases no exceptuadas del coverage (revisar 5.1).
2. Detectar stack real del proyecto (`.csproj` de tests: `Microsoft.NET.Test.Sdk`, framework, mocking, coverage).
3. Diseñar matriz mínima de casos.
4. Implementar tests en la ubicación correcta (proyecto `.Tests` con estructura de carpetas espejo del proyecto productivo).
5. Ejecutar tests focalizados (`dotnet test --filter "FullyQualifiedName~MiClaseTests"`).
6. Reforzar cobertura según resultados.
7. Repetir ciclo hasta alcanzar cobertura adecuada.
8. Entregar resumen final con evidencia.

## 5) Quality Gates obligatorios (Sonar + Coverlet + Cobertura)

### 5.1 Verificar configuración

1. Confirmar existencia de configuración de exclusiones de Sonar (`el análisis estático.Analysis.xml`, `.sonarqube/`, o `sonar-project.properties`).
2. Confirmar existencia del recolector de cobertura **Coverlet** (`coverlet.collector` como `<PackageReference>` en el proyecto de tests) y de **ReportGenerator** para el HTML.
3. En caso de no haber exclusiones de Sonar ni Coverlet, crear exclusiones centradas en clases de configuración, `Program.cs` / `Startup.cs`, DTOs generados desde YAML (carpeta `Generated/`), constantes, y mappers sin lógica.
   **Controllers y utils NO se excluyen: la policy (`assets/policies/testing-guidelines.md`) exige medirlos (controllers 70%, utils 80%).**
   Las exclusiones de ambos deben coincidir. Tomar como plantilla de ejemplo este set de exclusiones de Sonar (corregir los paths de ser necesario):

```xml
<PropertyGroup>
  <el análisis estáticoExclude>true</el análisis estáticoExclude>
</PropertyGroup>
```

En `sonar-project.properties`:

```properties
sonar.exclusions=**/Generated/**/*,**/Program.cs,**/Startup.cs,**/Configuration/**/*,**/Constants/**/*,**/Mappers/**/*.cs,**/DTOs/**/*.cs,**/Models/**/*.cs
sonar.coverage.exclusions=**/Generated/**/*,**/Program.cs,**/Startup.cs,**/Configuration/**/*,**/Constants/**/*,**/Mappers/**/*.cs,**/DTOs/**/*.cs,**/Models/**/*.cs
```

Y esta plantilla para configurar Coverlet con exclusiones coherentes en el `.csproj` del proyecto de tests:

```xml
<PropertyGroup>
  <CollectCoverage>true</CollectCoverage>
  <CoverletOutputFormat>opencover,cobertura</CoverletOutputFormat>
  <CoverletOutput>./TestResults/coverage/</CoverletOutput>
  <Exclude>[*]*.Generated.*,[*]*Program,[*]*Startup,[*]*.Configuration.*,[*]*.Constants.*,[*]*.Mappers.*,[*]*.DTOs.*,[*]*.Models.*</Exclude>
  <ExcludeByFile>**/Generated/**/*.cs</ExcludeByFile>
</PropertyGroup>

<ItemGroup>
  <PackageReference Include="coverlet.collector" Version="6.0.0">
    <PrivateAssets>all</PrivateAssets>
    <IncludeAssets>runtime; build; native; contentfiles; analyzers; buildtransitive</IncludeAssets>
  </PackageReference>
</ItemGroup>
```

Generación del reporte HTML (una vez ejecutados los tests con cobertura):

```bash
dotnet tool install -g dotnet-reportgenerator-globaltool
reportgenerator \
  -reports:"**/TestResults/coverage/coverage.opencover.xml" \
  -targetdir:"TestResults/coverage-report" \
  -reporttypes:Html
```

### 5.2 Verificar consistencia de exclusiones Sonar vs Coverlet

1. Validar que las exclusiones de cobertura en Sonar y Coverlet sean equivalentes en intención (mismos namespaces/carpetas excluidos).
2. Si hay diferencias, corregirlas para evitar métricas inconsistentes.
3. Tomar como referencia el estándar ya definido por el proyecto cuando exista.

### 5.3 Compilar y generar reporte de cobertura tras cada iteración relevante

1. Ejecutar `dotnet test --collect:"XPlat Code Coverage"` (o el comando ya configurado en el proyecto — Coverlet collector se activa automáticamente).
2. Confirmar generación del reporte HTML (`TestResults/coverage-report/index.html` o ruta equivalente del proyecto).

### 5.4 Analizar cobertura y reforzar

1. Revisar `index.html` de ReportGenerator para detectar clases/métodos/ramas con baja o nula cobertura.
2. Priorizar métodos críticos y ramas faltantes (errores, validaciones, bordes, flujos alternativos).
3. Agregar/reforzar tests.
4. Repetir: compilar → leer `index.html` → reforzar, hasta alcanzar umbral del proyecto o mejora sustancial documentada.

### 5.5 Umbrales mínimos de cobertura (obligatorio)

> **Fuente de verdad:** los umbrales mínimos de cobertura los define `assets/policies/testing-guidelines.md`. Este driver NO fija umbrales propios por debajo de ese piso ni excluye capas que la policy exige medir; solo puede ser MÁS estricto sobre la lógica de negocio.

1. Pisos mínimos por capa (según `testing-guidelines.md`):
    - **Dominio / Services: 80%** — en este stack se endurece a **> 90%** (objetivo más estricto sobre la lógica de negocio: services, repositorios, validadores y mappers con lógica).
    - **Controllers: 70%** (se miden, NO se excluyen).
    - **Utils: 80%** (se miden, NO se excluyen).
    - Los umbrales configurados por el equipo tienen prioridad si difieren, siempre que no bajen del piso de la policy.
2. La verificación se basa en el reporte HTML de ReportGenerator (`index.html`), evaluada por capa/namespace.
3. Si una capa queda por debajo de su piso:
    - identificar clases/métodos con menor cobertura,
    - reforzar tests,
    - recompilar y volver a verificar,
    - repetir hasta superar el piso o documentar bloqueo técnico explícito.

## 6) Restricciones

1. No modificar producción salvo instrucción explícita.
2. No usar nombres fully qualified en el código; usar `using` statements.
3. No agregar dependencias nuevas sin justificar y validar alineación con el proyecto (`Moq`, `xUnit`, `FluentAssertions`, `coverlet.collector` están OK; agregar otras requiere OK del tech lead).
4. Mantener cambios mínimos, precisos y trazables.
5. No usar `Newtonsoft.Json` en tests — el proyecto está en `System.Text.Json` (arquetipo 4.x / 1.1.x).

## 7) Entrega esperada

1. Archivos de test creados/actualizados (dentro del proyecto `<Solucion>.Tests` correspondiente).
2. Casos cubiertos por tipo (unit/integration/e2e).
3. Resultado de ejecución de `dotnet test`.
4. Estado de consistency check Sonar/Coverlet (exclusiones).
5. Evidencia de revisión de `coverage-report/index.html` y métodos reforzados.
6. Cobertura global final de clases no excluidas (valor y evidencia desde ReportGenerator).
7. Gaps pendientes y próximos pasos (si aplica).
