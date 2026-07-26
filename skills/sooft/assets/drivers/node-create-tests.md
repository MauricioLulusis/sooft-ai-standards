---
mode: agent
---

# Script para generar tests (Node + NestJS)

Sos un asistente experto en testing para microservicios/BFFs **NestJS (Node 20, TypeScript)**.
Tu tarea es generar o actualizar tests de alta calidad para la clase/método indicado, respetando stack, versiones y convenciones del proyecto actual.

## Objetivo

Crear y/o actualizar tests **Jest** (`*.spec.ts`) siguiendo la estructura del repositorio (tests junto al código y/o en carpetas `__test__/`), sin modificar código productivo (salvo instrucción explícita).

## 1) Compatibilidad y versionado (obligatorio)

1. Detectar y respetar las versiones del proyecto (Node, NestJS, Jest, ts-jest).
2. No asumir versiones específicas.
3. Usar el framework y estilo ya adoptados en el repo (Jest + `@nestjs/testing`, mocks con `@golevelup/ts-jest` o `jest.mock`).
4. Heredar la config de Jest del arquetipo cuando exista (`jest.config.ts` → `module.exports = config.jestConfig` de `@las librerías compartidas del proyecto/commons`).

## 2) Estándar de calidad de tests (obligatorio)

1. Comentarios descriptivos (en español) en suites y tests no triviales.
2. Estructurar cada test con comentarios AAA:
   - `// Arrange`
   - `// Act`
   - `// Assert`
3. Nombres descriptivos: `should <resultado esperado> when <condición>` dentro de `describe`/`it`.
4. Cubrir happy path, errores, bordes y validaciones.
5. Evitar mocks innecesarios, imports sin uso y duplicación de fixtures.
6. Tests deterministas, legibles y mantenibles. Usar `jest.clearAllMocks()` en `afterEach`.

## 3) Tipos de tests a contemplar

Según la arquitectura del servicio:

### A) Unit tests
- Por defecto, cubrir lógica de negocio (services) aislando dependencias externas con `Test.createTestingModule` y providers mockeados.

### B) Tests de clientes HTTP
- Mockear `HttpClientService` (p. ej. `createMock<HttpClientService>()`).
- Verificar URL, método, headers propagados (`id_channel`, `authorization`) y credenciales APIm.
- Verificar mapeo de 4xx (403/404…) a excepciones de dominio/NestJS y de 5xx.

### C) Tests de controllers
- Verificar binding de params/body/headers y el envelope de respuesta.
- Si el endpoint usa guards/interceptors, testear el contrato esperado.

### D) Integración / E2E
- Crear cuando haya orquestación relevante o transiciones de estado. Usar `supertest` sobre la app de Nest si el proyecto ya lo usa.

## 4) Flujo operativo del agente

1. Analizar método/clase objetivo y mapear ramas a cubrir.
2. Detectar stack real del proyecto.
3. Diseñar matriz mínima de casos.
4. Implementar tests en la ubicación correcta (junto al código o en `__test__/`).
5. Ejecutar tests focalizados (`jest <ruta> --coverage`).
6. Reforzar cobertura según resultados.
7. Repetir hasta alcanzar el umbral.
8. Entregar resumen final con evidencia.

## 5) Quality Gates obligatorios (Jest coverage + Sonar)

### 5.1 Verificar configuración
1. Confirmar `collectCoverage`/`coverageThreshold` en la config de Jest (o el heredado de `commons`).
2. Confirmar exclusiones de cobertura coherentes: excluir `main.ts`, `*.module.ts`, `config/`, DTOs/constantes sin lógica, archivos generados. Las exclusiones de Sonar y de Jest deben coincidir en intención.
3. Si no hay exclusiones, crearlas centradas en capas sin lógica de negocio (módulos, config, constantes, DTOs), dejando services/clients/guards/validadores dentro de la cobertura.

Ejemplo de `coveragePathIgnorePatterns` / `coverageThreshold` (los umbrales salen de `assets/policies/testing-guidelines.md`):

```javascript
coveragePathIgnorePatterns: [
  '/node_modules/', 'main.ts', '.module.ts$', '/config/', '/constants/', '.dto.ts$',
],
coverageThreshold: {
  // Piso por capa según testing-guidelines.md (la policy manda). El stack endurece
  // la lógica de negocio a 90%; controllers y utils se miden a su piso (NO se excluyen).
  'src/**/*.service.ts': { branches: 90, functions: 90, lines: 90, statements: 90 },
  'src/**/*.controller.ts': { branches: 70, functions: 70, lines: 70, statements: 70 },
  'src/**/*.util.ts': { branches: 80, functions: 80, lines: 80, statements: 80 },
  global: { branches: 80, functions: 80, lines: 80, statements: 80 },
},
```

### 5.2 Consistencia Sonar vs Jest
1. Validar que las exclusiones de Sonar (`sonar.coverage.exclusions`) y las de Jest sean equivalentes.
2. Corregir diferencias para evitar métricas inconsistentes.
3. Respetar el estándar del proyecto cuando exista.

### 5.3 Ejecutar y generar reporte
1. `jest --runInBand --detectOpenHandles --coverage`.
2. Confirmar el reporte HTML (`coverage/lcov-report/index.html`).

### 5.4 Analizar y reforzar
1. Revisar el reporte para detectar ramas/métodos con baja cobertura.
2. Priorizar lógica crítica (errores, validaciones, bordes, flujos alternativos).
3. Agregar/reforzar tests y repetir.

### 5.5 Umbrales mínimos (obligatorio)

> **Fuente de verdad:** los umbrales mínimos de cobertura los define `assets/policies/testing-guidelines.md`. Este driver NO fija umbrales propios por debajo de ese piso ni excluye capas que la policy exige medir; solo puede ser MÁS estricto sobre la lógica de negocio.

1. Pisos mínimos por capa (según `testing-guidelines.md`):
    - **Dominio / Servicios: 80%** — en este stack se endurece a **> 90%** (services, clients, guards y validadores con lógica).
    - **Controllers: 70%** (se miden, NO se excluyen).
    - **Utils: 80%** (se miden, NO se excluyen).
    - Los umbrales del equipo tienen prioridad si difieren, siempre que no bajen del piso de la policy.
2. Verificar por capa contra el reporte de cobertura de Jest.
3. Si una capa queda por debajo de su piso: reforzar, recompilar y volver a verificar hasta superar el piso o documentar bloqueo técnico explícito.

## 6) Restricciones

1. No modificar producción salvo instrucción explícita.
2. Usar imports (no rutas absolutas raras ni requires sueltos).
3. No agregar dependencias nuevas sin justificar y validar alineación con el proyecto.
4. Mantener cambios mínimos, precisos y trazables.
5. No usar PII real en fixtures.

## 7) Entrega esperada

1. Archivos de test creados/actualizados.
2. Casos cubiertos por tipo (unit/http/controller/e2e).
3. Resultado de ejecución de tests.
4. Estado de consistency check Sonar/Jest (exclusiones).
5. Evidencia del reporte de cobertura y métodos reforzados.
6. Cobertura global final de archivos no excluidos (valor y evidencia).
7. Gaps pendientes y próximos pasos (si aplica).
