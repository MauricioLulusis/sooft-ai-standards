# Revisión de Tests

Esta revisión valida que los tests incluidos en el MR son suficientes, están bien escritos
y realmente prueban el comportamiento del código. El objetivo no es maximizar el número de
tests ni alcanzar un porcentaje de cobertura arbitrario, sino asegurarse de que los casos
importantes estén cubiertos y de que los tests fallen cuando el código está roto.

Revisá esta lista después de que el paso de implementación (recurso `internal/sooft-implement-task.md` de `sooft`) generó el código y antes del
gate de code review (recurso `internal/sooft-code-review-gate.md` de `sooft`).

> **Umbrales de cobertura:** esta revisión es cualitativa. Los mínimos cuantitativos los
> define `assets/policies/testing-guidelines.md` — no inventes porcentajes acá.

---

## Cobertura de casos

- [ ] El happy path de cada funcionalidad nueva está cubierto por al menos un test. Si el
      código nuevo hace algo concreto (transforma datos, llama a un servicio, persiste en
      BD), hay un test que verifica que lo hace correctamente con un input válido.
- [ ] Los casos de error están cubiertos: qué pasa cuando el input es inválido, cuando un
      servicio externo falla, cuando el registro no existe, cuando hay un conflicto de
      concurrencia. Para cada `throw` o `return` de error en el código nuevo, debería
      haber un test que lo dispara.
- [ ] Los casos borde están contemplados: valores nulos, colecciones vacías, strings vacíos,
      números en el límite del rango, fechas límite. No esperés que el code review detecte
      un NPE en producción porque nadie testeó el caso de lista vacía.
- [ ] Si hay lógica condicional (`if/else`, `switch`), cada rama tiene al menos un test
      que la ejercita. Un test que siempre entra por el mismo branch no cubre el código
      completo.
- [ ] Las reglas de negocio críticas (cálculos financieros, validaciones de dominio, límites
      operativos) tienen tests con los valores exactos esperados, no solo verificaciones de
      tipo "el resultado no es null".

---

## Independencia de los tests

- [ ] Cada test se puede ejecutar de forma independiente y en cualquier orden. Si el resultado
      de un test depende de que otro test corrió antes (estado compartido, datos en BD de
      test, archivos temporales), es un problema.
- [ ] Los tests no dependen de recursos externos reales: bases de datos de producción,
      servicios externos, filesystem del desarrollador. Usá H2/HSQLDB para BD, WireMock
      o mocks para servicios externos, y archivos temporales limpios por test.
- [ ] Los tests limpian el estado que crean. Si un test inserta registros en una BD de test,
      los borra al finalizar (o usa una transacción que se revierte). Si crea archivos
      temporales, los elimina.
- [ ] Los tests no tienen `Thread.sleep()` ni `wait()` hardcodeados como mecanismo de
      sincronización. Si hay que esperar algo asíncrono, usá `Awaitility` o el mecanismo
      apropiado del framework.

---

## Nombres y legibilidad

- [ ] Los nombres de los tests describen el escenario y el resultado esperado, no el nombre
      del método que prueban. `debeRetornarErrorCuandoElMontoEsNegativo` es útil.
      `testCalcular` no lo es.
- [ ] La estructura de cada test sigue el patrón Arrange / Act / Assert (o Given / When /
      Then). Primero se prepara el contexto, después se ejecuta la acción, después se
      verifica el resultado. Si un test mezcla estos pasos de forma confusa, pedí que lo
      reestructuren.
- [ ] Los assertions son específicos: `assertEquals(expectedAmount, result.getAmount())`
      en lugar de `assertNotNull(result)`. Un test que solo verifica que no hubo excepción
      no es un test útil salvo que eso sea exactamente lo que se quiere verificar.
- [ ] Si un test tiene más de 50 líneas o más de 3 assertions diferentes, evaluá si está
      probando demasiadas cosas a la vez. Un test, un comportamiento.

---

## Mocks y stubs

- [ ] Los mocks se usan para dependencias externas (servicios, repositorios, clientes HTTP),
      no para la clase que se está testeando. Si el test mockea la clase bajo prueba,
      no está probando nada útil.
- [ ] Las verificaciones de interacción con mocks (`verify(mock).metodo(...)`) se usan solo
      cuando el comportamiento observable es exactamente esa interacción (ej: verificar que
      se envió un email). No las uses para verificar detalles de implementación internos que
      pueden cambiar sin cambiar el comportamiento externo.
- [ ] Los mocks están configurados para comportarse de forma realista: si el servicio real
      puede devolver null, el mock también contempla ese caso. Un mock que siempre devuelve
      el happy path solo prueba el happy path.
- [ ] No se usa `@InjectMocks` con dependencias que deberían ser reales en el test. Si el
      test es de integración, usá el contexto real; si es unitario, inyectá mocks
      explícitamente.

---

## Tests de integración

- [ ] Si el cambio toca la capa de persistencia, hay tests de integración que verifican
      el comportamiento contra una BD real (H2 en CI o una BD de test dedicada). Los tests
      unitarios con repositorios mockeados no son suficientes para cambios en queries.
- [ ] Si el cambio expone endpoints REST, hay tests de integración que verifican el contrato
      HTTP: status codes, estructura del response, headers. `@SpringBootTest` +
      `MockMvc` o `WebTestClient` para Spring Boot.
- [ ] Los tests de integración están separados de los tests unitarios (paquete diferente,
      perfil de Maven/Gradle diferente) para poder ejecutar los unitarios rápido en el
      ciclo de desarrollo y los de integración en CI.

---

## CI en verde

- [ ] Todos los tests pasan localmente antes de abrir el MR. No se abre un MR con tests
      rotos "para que CI los detecte".
- [ ] El pipeline de CI completó exitosamente en la rama del MR. Si CI falla, el MR no
      puede mersooftse.
- [ ] Si hay tests que se saltean (`@Disabled`, `@Ignore`, `xit`, `skip`), hay una
      justificación en el comentario y un ticket de seguimiento para rehabilitarlos.
      Un test deshabilitado sin justificación es deuda.
- [ ] La cobertura de líneas del módulo afectado no bajó respecto a la rama base. Si bajó,
      hay una explicación explícita (ej: se agregó código de infraestructura o configuración
      que no es testeable de forma práctica).

---

## Registro de la revisión

```json
"testing_review": {
  "status": "approved" | "approved_with_observations" | "rejected",
  "reviewed_by": "<legajo o nombre>",
  "reviewed_at": "<ISO 8601>",
  "coverage_delta": "<+X% | -X% | sin cambio>",
  "ci_status": "green" | "red" | "not_run",
  "findings": [
    {
      "severity": "blocker" | "major" | "minor",
      "description": "<qué encontraste>",
      "resolution": "<cómo se resuelve o si ya fue resuelto>"
    }
  ]
}
```
