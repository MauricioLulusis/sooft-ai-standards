# Revisión de Arquitectura

Esta revisión se hace sobre el plan técnico aprobado de la rama (`PLAN.md`, `FIX_PLAN.md` o `REMEDIATION_PLAN.md`) antes de comenzar la implementación,
y se complementa con una revisión del código generado antes del PR. El objetivo es detectar
problemas estructurales antes de que el código esté escrito o, si ya está escrito, antes de que
llegue a la rama principal.

No es una revisión de estilo ni de tests — eso está cubierto en `testing-review.md` y
`security-review.md`. Acá el foco es: ¿la solución encaja bien en la arquitectura existente?

---

## Capas y responsabilidades

- [ ] El cambio respeta las capas de la aplicación (controller / service / repository o la
      equivalente en el stack afectado). Si lógica de negocio aparece en el controller, o
      queries directas en el service sin pasar por el repository, documentá el hallazgo.
- [ ] Las clases o módulos nuevos tienen una única responsabilidad clara. Si una clase hace
      más de una cosa distinta, evaluá si hay que dividirla.
- [ ] No se duplica lógica que ya existe en otro componente del mismo sistema. Antes de
      aceptar una implementación nueva, confirmá que no hay un método o servicio existente
      que ya hace lo mismo o algo muy parecido.
- [ ] Las abstracciones introducidas tienen sentido: no hay interfaces con un solo
      implementador que no va a crecer, ni herencia donde alcanzaría con composición.

---

## Dependencias

- [ ] Las dependencias nuevas (librerías, módulos internos, servicios externos) están
      justificadas. Para cada dependencia nueva preguntá: ¿hay algo ya en el proyecto que
      cubre esto? ¿Es una librería aprobada por la organización o hay que validarla?
- [ ] No se introdujeron dependencias circulares entre módulos o paquetes.
- [ ] Las dependencias hacia servicios externos (APIs de terceros, sistemas internos de la
      organización) están encapsuladas detrás de una interfaz o adaptador. El código de negocio
      no debería tener llamadas directas a HTTP o a SDKs externos sin una capa de
      abstracción intermedia.
- [ ] Si se agrega una dependencia a un servicio interno de Sooft, confirmá que ese servicio
      tiene SLA definido y que el equipo dueño está al tanto del nuevo consumidor.

---

## Escalabilidad y performance

- [ ] Si el cambio introduce procesamiento de listas o colecciones, verificá que no hay
      iteraciones anidadas con complejidad cuadrática o peor sobre volúmenes de datos
      que pueden crecer (ej: loops dentro de loops sobre registros de base de datos).
- [ ] Las consultas a base de datos usan índices apropiados. Si se agrega un filtro por un
      campo nuevo, verificá que ese campo tiene índice o que el plan contempla crearlo.
- [ ] Si el cambio puede generar carga adicional en un servicio externo (más llamadas,
      payloads más grandes), eso está contemplado y el servicio externo tiene capacidad
      para absorberlo.
- [ ] Si el componente va a ser llamado concurrentemente, el código es thread-safe o
      el plan lo trata explícitamente.
- [ ] No se introducen cachés sin política de invalidación definida.

---

## Compatibilidad hacia atrás

- [ ] Si se modifica una API (REST, mensajería, eventos), los consumidores existentes
      no se rompen. Cambios breaking (renombrar campos, cambiar tipos, eliminar endpoints)
      requieren versionado o coordinación explícita con los consumidores.
- [ ] Si se modifica el esquema de base de datos, la migración es compatible hacia atrás:
      las versiones anteriores del código pueden correr contra el esquema nuevo. Si no es
      posible, el plan de deploy lo contempla.
- [ ] Si se cambia el contrato de un evento o mensaje asíncrono (Kafka, MQ, etc.), los
      consumidores del evento están identificados y actualizados o el cambio es aditivo.
- [ ] Los archivos de configuración o variables de entorno nuevas tienen valores por defecto
      razonables para no romper deploys existentes que no las tengan seteadas.

---

## Deuda técnica introducida

- [ ] Si el plan toma un shortcut técnico por restricciones de tiempo, ese shortcut está
      documentado como deuda en el código (comentario `TODO` con número de ticket) y hay
      un ticket de seguimiento creado en el issue tracker.
- [ ] No se aumenta la complejidad ciclomática de métodos que ya están en el límite.
      Si un método ya tiene muchos branches, agregar más sin refactorizar es deuda
      que va a costar caro después.
- [ ] Si el cambio toca código legado con poca cobertura de tests, el plan contempla
      agregar tests básicos sobre ese código antes de modificarlo, no solo sobre el
      código nuevo.
- [ ] No se introducen patrones de diseño innecesarios (factories de factories, builders
      para objetos simples, etc.) que aumentan la superficie de código sin beneficio claro.

---

## Observabilidad

- [ ] Los flujos nuevos tienen logging suficiente para diagnosticar problemas en producción.
      Mínimamente: entrada al flujo con datos clave (sin PII), salida con resultado,
      errores con stack trace.
- [ ] Si se agrega un proceso batch o asíncrono, hay métricas o logs que permiten saber
      cuándo empezó, cuándo terminó y cuántos registros procesó.
- [ ] Los errores se loguean con nivel apropiado (`ERROR` para fallas reales, `WARN` para
      situaciones degradadas, `INFO` para flujo normal). No todo es `ERROR`.

---

## Registro de la revisión

Documentá el resultado en `.sooft/state.json` o en un comentario del MR/PR:

```json
"architecture_review": {
  "status": "approved" | "approved_with_observations" | "rejected",
  "reviewed_by": "<legajo o nombre>",
  "reviewed_at": "<ISO 8601>",
  "findings": [
    {
      "severity": "blocker" | "major" | "minor",
      "description": "<qué encontraste>",
      "resolution": "<cómo se resuelve o si ya fue resuelto>"
    }
  ]
}
```

`"blocker"` impide que el MR avance. `"major"` requiere resolución antes del merge pero
no bloquea el desarrollo. `"minor"` es una observación para seguimiento futuro.
