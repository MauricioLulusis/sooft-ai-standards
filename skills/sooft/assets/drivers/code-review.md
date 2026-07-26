# Prompt: Code Review

Prompt base para revisar un bloque de código o un diff antes de abrir un merge/pull request.
Usalo para detectar problemas antes de que lleguen a la revisión humana o al análisis estático.

---

## Cuándo usarlo

- Antes de subir un MR/PR.
- Cuando querés una segunda opinión rápida sobre código que escribiste.
- Cuando revisás el código de un compañero y querés estructurar tus comentarios.
- Como paso previo al análisis estático para anticipar hallazgos.
- En el flujo SOOFT, corresponde al gate de code review (recurso `internal/sooft-code-review-gate.md` de `sooft`).

---

## Prompt

```
Revisá el siguiente código como si fueras un senior engineer de Sooft Technology haciendo la revisión de un merge/pull request. El stack es Java Spring Boot y/o Node.js. El análisis estático (SAST/calidad) corre en el pipeline de CI.

CONTEXTO DEL CAMBIO:
---
DESCRIBÍ QUÉ HACE ESTE CÓDIGO: qué ticket resuelve, qué problema atacó el developer, qué parte del sistema es
---

CÓDIGO O DIFF A REVISAR:
---
PEGÁ EL CÓDIGO O EL DIFF COMPLETO
---

Revisá el código en las siguientes dimensiones y listá los hallazgos. Para cada hallazgo indicá:
- Dimensión (ver abajo).
- Severidad: CRÍTICO | MEDIO | SUGERENCIA.
- Ubicación: nombre de archivo y número de línea si está disponible, o descripción del bloque.
- Descripción del problema.
- Cómo corregirlo (código concreto si aplica, no sólo "refactorizá esto").

Severidades:
- CRÍTICO: bug que va a producción, problema de seguridad, violación de una regla de negocio, pérdida de datos. Bloquea el MR.
- MEDIO: código que va a causar problemas en el futuro cercano, deuda técnica grave, test faltante para un escenario de riesgo. El MR no debería mersooft sin resolver esto.
- SUGERENCIA: mejora de legibilidad, convención de estilo, optimización menor. No bloquea el MR.

Dimensiones de revisión:

### 1. Correctitud
¿El código hace lo que dice que hace? ¿Hay bugs lógicos, condiciones de borde no manejadas, comportamiento incorrecto en casos de error? ¿Los tipos y nulls están manejados correctamente?

### 2. Seguridad
¿Hay riesgos de seguridad? Buscá: SQL injection, path traversal, log de datos sensibles, tokens o contraseñas hardcodeadas, validación de inputs faltante, exposición de stack traces al cliente, permisos mal verificados.

### 3. Tests
¿El código tiene tests? ¿Los tests existentes cubren los escenarios importantes (caso feliz, errores, casos borde)? ¿Hay lógica compleja sin test? ¿Los mocks son razonables?

### 4. Arquitectura y diseño
¿El código respeta las capas del sistema (controller, service, repository)? ¿Hay acoplamiento innecesario? ¿Se duplica lógica que ya existe en otro lugar? ¿Las responsabilidades están bien distribuidas?

### 5. Legibilidad y mantenibilidad
¿Los nombres de variables, métodos y clases son claros? ¿Hay código muerto o comentado sin razón? ¿La complejidad ciclomática es manejable? ¿Hay magic numbers o strings sin constante?

---

Al final del análisis, incluí:

### Resumen
- Total de hallazgos por severidad: X CRÍTICOS, X MEDIOS, X SUGERENCIAS.
- Veredicto: APROBADO | APROBADO CON CAMBIOS MENORES | REQUIERE CAMBIOS | RECHAZADO.
- Las 2 o 3 cosas más importantes a corregir antes de mersooft.
```

---

## Ejemplo de uso

Entrada:

```java
@GetMapping("/clientes/{id}/perfil")
public ResponseEntity<Perfil> getPerfil(@PathVariable String id) {
    Perfil p = perfilRepo.findById(id);
    log.info("Perfil obtenido: " + p.toString());
    return ResponseEntity.ok(p);
}
```

Contexto: endpoint REST en Spring Boot que devuelve el perfil de un cliente.

Resultado esperado: el agente marca como CRÍTICO que `p` puede ser null y va a lanzar NullPointerException, como MEDIO que `p.toString()` puede loguear datos personales del cliente (PII), y como SUGERENCIA que el log podría usar formato estructurado en vez de concatenación.

---

## Notas

- Para diffs grandes (más de 300 líneas), dividí el review en archivos o secciones lógicas.
- Los hallazgos CRÍTICOS tienen que resolverse antes de ejecutar el pipeline de análisis estático para no contaminar el baseline.
- Si revisás el código de otra persona, usá los hallazgos como base de los comentarios en el MR/PR: copiá la descripción y la corrección propuesta directo al comentario inline.
