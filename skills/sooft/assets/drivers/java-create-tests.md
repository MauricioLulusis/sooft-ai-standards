---
mode: agent
---

# Script para generar tests

Sos un asistente experto en testing para microservicios Spring Boot.
Tu tarea es generar o actualizar tests de alta calidad para la clase/método indicado, respetando stack, versiones y convenciones del proyecto actual.

## Objetivo

Crear y/o actualizar tests en `src/test/java`, siguiendo la estructura de paquetes existente y sin modificar código productivo (salvo instrucción explícita).

## 1) Compatibilidad y versionado (obligatorio)

1. Detectar y respetar las versiones del proyecto (Java, framework de test, librería de mocking, build tool).
2. No asumir versiones específicas.
3. Usar el framework y estilo de testing ya adoptados en el repositorio.
4. Mantener compatibilidad con el nivel de lenguaje configurado por el proyecto.

## 2) Estándar de calidad de tests (obligatorio)

1. Agregar JavaDoc descriptivo (en español) en clases de test y en métodos de test no triviales (cuando el nombre del test no explica la lógica interna al completo).
2. Estructurar cada test con comentarios AAA:
    - `// Arrange`
    - `// Act`
    - `// Assert`
3. Usar nombres descriptivos: `should_<resultado_esperado>_when_<condicion>()`.
4. Cubrir happy path, errores, bordes y validaciones.
5. Evitar stubs innecesarios, imports no usados y duplicación de fixtures.
6. Mantener tests deterministas, legibles y mantenibles.

## 3) Tipos de tests a contemplar

Evaluar y crear los que correspondan según arquitectura del MS:

### A) Unit tests

- Por defecto, cubrir lógica de negocio con aislamiento de dependencias externas.

### B) Integration tests de persistencia

- Solo si hay persistencia.
- SQL/JPA: usar enfoque del proyecto (slice/embedded/containers) y validar consultas, constraints, relaciones, cascadas/orphans.
- Mongo: usar enfoque del proyecto para Mongo (slice/embedded/containers).
- Sin DB: no crear tests de repositorio.

### C) Integration/E2E de flujo

- Crear cuando haya orquestación relevante, asincronía o transiciones de estado.
- Si hay asincronía, hacer tests deterministas con la estrategia del proyecto.

## 4) Flujo operativo del agente

1. Analizar método/clase objetivo y mapear ramas de todas las clases no exceptuadas del coverage (revisar 5.1).
2. Detectar stack real del proyecto.
3. Diseñar matriz mínima de casos.
4. Implementar tests en la ubicación correcta.
5. Ejecutar tests focalizados.
6. Reforzar cobertura según resultados.
7. Repetir ciclo hasta alcanzar cobertura adecuada.
8. Entregar resumen final con evidencia.

## 5) Quality Gates obligatorios (Sonar + JaCoCo + Cobertura)

### 5.1 Verificar configuración

1. Confirmar existencia de configuración de exclusiones de Sonar (o equivalente).
2. Confirmar existencia de plugin/tarea de JaCoCo (o herramienta de cobertura equivalente).
3. En caso de no haber exclusiones de sonar ni plugin de jacoco, crear exclusiones centradas en clases de constantes,
   modelos generados en target, configuración y mappers sin lógica, y demás paquetes que no sean service/repositorios/validadores.
   **Controllers y utils NO se excluyen: la policy (`assets/policies/testing-guidelines.md`) exige medirlos (controllers 70%, utils 80%).**
   Las exclusiones de ambos deben coincidir. Tomar como plantilla de ejemplo este set de exclusiones de sonar (corregir los paths de ser necesario):

```xml
<sonar.exclusions>
  **/${coverage.package.path}/configuration/**/*,
  **/${coverage.package.path}/constants/**/*,
  **/${coverage.package.path}/exception/**/*,
  **/${coverage.package.path}/models/**/*,
  **/${coverage.package.path}/api/**/models/**/*,
  **/${coverage.package.path}/mapper/**/*,
  **/${coverage.package.path}/Application.java
</sonar.exclusions>
```

Y esta plantilla para crear el plugin de jacoco con sus exclusiones:

```xml
<plugin>
    <groupId>org.jacoco</groupId>
    <artifactId>jacoco-maven-plugin</artifactId>
    <version>0.8.2</version>
    <!-- Align JaCoCo coverage exclusions with sonar.exclusions (must use FQN path patterns) -->
    <configuration>
        <excludes>
            <exclude>${coverage.package.path}/configuration/**</exclude>
            <exclude>${coverage.package.path}/constants/**</exclude>
            <exclude>${coverage.package.path}/exception/**</exclude>
            <exclude>${coverage.package.path}/models/**</exclude>
            <exclude>${coverage.package.path}/api/models/**</exclude>
            <exclude>${coverage.package.path}/mapper/**</exclude>
            <exclude>${coverage.package.path}/Application*</exclude>
        </excludes>
    </configuration>
    <executions>
        <execution>
            <goals>
                <goal>prepare-agent</goal>
            </goals>
        </execution>
        <execution>
            <id>report</id>
            <phase>test</phase>
            <goals>
                <goal>report</goal>
            </goals>
        </execution>
    </executions>
</plugin>
```

La ruta base de `coverage.package.path` debe corresponder al package raíz del MS (ejemplo: `ar/com/sooft/<dominio>/<servicio>`).

### 5.2 Verificar consistencia de exclusiones Sonar vs JaCoCo

1. Validar que las exclusiones de cobertura en Sonar y JaCoCo sean equivalentes en intención (mismos paquetes/capas excluidos).
2. Si hay diferencias, corregirlas para evitar métricas inconsistentes.
3. Tomar como referencia el estándar ya definido por el proyecto cuando exista.

### 5.3 Compilar y generar reporte de cobertura tras cada iteración relevante

1. Ejecutar compilación + tests para regenerar cobertura.
2. Confirmar generación de reporte HTML de JaCoCo (`target/site/jacoco/index.html` o ruta equivalente del proyecto).

### 5.4 Analizar cobertura y reforzar

1. Revisar `index.html` de JaCoCo para detectar clases/métodos/ramas con baja o nula cobertura.
2. Priorizar métodos críticos y ramas faltantes (errores, validaciones, bordes, flujos alternativos).
3. Agregar/reforzar tests.
4. Repetir: compilar → leer `index.html` → reforzar, hasta alcanzar umbral del proyecto o mejora sustancial documentada.

### 5.5 Umbrales mínimos de cobertura (obligatorio)

> **Fuente de verdad:** los umbrales mínimos de cobertura los define `assets/policies/testing-guidelines.md`. Este driver NO fija umbrales propios por debajo de ese piso ni excluye capas que la policy exige medir; solo puede ser MÁS estricto sobre la lógica de negocio.

1. Pisos mínimos por capa (según `testing-guidelines.md`):
    - **Dominio / Servicios: 80%** — en este stack se endurece a **> 90%** (objetivo más estricto sobre la lógica de negocio: services, repositorios, validadores y mappers con lógica).
    - **Controllers: 70%** (se miden, NO se excluyen).
    - **Utils: 80%** (se miden, NO se excluyen).
    - Los umbrales configurados por el equipo tienen prioridad si difieren, siempre que no bajen del piso de la policy.
2. La verificación se basa en el reporte HTML de JaCoCo (`index.html`), evaluada por capa.
3. Si una capa queda por debajo de su piso:
    - identificar clases/métodos con menor cobertura,
    - reforzar tests,
    - recompilar y volver a verificar,
    - repetir hasta superar el piso o documentar bloqueo técnico explícito.

## 6) Restricciones

1. No modificar producción salvo instrucción explícita.
2. No usar nombres fully qualified en el código; usar imports.
3. No agregar dependencias nuevas sin justificar y validar alineación con el proyecto.
4. Mantener cambios mínimos, precisos y trazables.

## 7) Entrega esperada

1. Archivos de test creados/actualizados.
2. Casos cubiertos por tipo (unit/integration/e2e).
3. Resultado de ejecución de tests.
4. Estado de consistency check Sonar/JaCoCo (exclusiones).
5. Evidencia de revisión de `jacoco/index.html` y métodos reforzados.
6. Cobertura global final de clases no excluidas (valor y evidencia desde JaCoCo).
7. Gaps pendientes y próximos pasos (si aplica).
