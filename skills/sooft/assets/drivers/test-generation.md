# Prompt: Generación de Tests

Prompt base para generar tests para un componente dado.
El agente no sólo genera los tests: explica qué está testeando y por qué ese escenario importa.

> **Fuente de verdad:** los tipos de test, las convenciones de nombrado y los umbrales de cobertura los define `assets/policies/testing-guidelines.md`. Este prompt no fija valores propios: seguí los de la policy.

---

## Cuándo usarlo

- Cuando terminás de implementar una clase o función y necesitás tests.
- Cuando un componente existente no tiene tests y querés agregar cobertura.
- Cuando el code review o el análisis estático detecta baja cobertura en código crítico.
- Para generar los tests antes de implementar (TDD), pasándole la firma o el contrato esperado.

---

## Prompt

```
Generá tests para el siguiente componente. Trabajás en Sooft Technology con stack Java Spring Boot y/o Node.js.

COMPONENTE A TESTEAR:
---
PEGÁ ACÁ EL CÓDIGO DEL COMPONENTE: clase, función, método o módulo completo
---

CONTEXTO ADICIONAL (opcional pero recomendado):
---
DESCRIBÍ qué hace este componente en el sistema, qué ticket resuelve, qué reglas de negocio implementa, qué dependencias externas tiene
---

Generá los tests con las siguientes reglas:

1. Para cada test, escribí PRIMERO una línea de comentario que diga:
   - Qué escenario estás testeando.
   - Por qué ese escenario es importante (qué riesgo cubre o qué regla de negocio valida).

2. Cubrí obligatoriamente estos tipos de escenarios:
   - **Caso feliz**: el input es válido y el comportamiento es el esperado.
   - **Errores esperados**: inputs inválidos, precondiciones no cumplidas, excepciones que el código debe lanzar o manejar.
   - **Casos borde**: valores límite (null, vacío, cero, máximo, mínimo), listas vacías, strings muy largos, fechas especiales.
   - **Comportamiento con dependencias**: cómo se comporta cuando una dependencia externa falla, devuelve null, o tarda demasiado.

3. Para cada test indicá a qué tipo pertenece: UNITARIO | INTEGRACIÓN | CONTRATO.

4. Usá el framework de testing estándar del stack:
   - Java Spring Boot: JUnit 5 + Mockito + AssertJ. Si hay contexto de Spring, usá @SpringBootTest o @WebMvcTest según corresponda.
   - Node.js: Jest. Para HTTP, usá supertest si aplica.

5. Los mocks tienen que ser realistas: no uses "foo", "bar" ni datos genéricos. Usá datos que parezcan reales del dominio bancario (montos, cuentas, fechas, estados de transacción) pero que no sean datos reales de producción.

6. Al final, incluí una sección llamada "Escenarios no cubiertos" donde listés casos que serían importantes testear pero que no podés generar sin más contexto (por ejemplo: tests de performance, tests que requieren datos de producción, integraciones con sistemas de Sooft que no están disponibles en el código dado).

Organizá los tests agrupados por tipo de escenario: primero el caso feliz, luego los errores esperados, luego los casos borde, luego los tests de dependencias.
```

---

## Ejemplo de uso

Entrada:

```java
@Service
public class TransferenciaService {

    private final CuentaRepository cuentaRepo;
    private final AuditLogger auditLogger;

    public void transferir(String cuentaOrigen, String cuentaDestino, BigDecimal monto) {
        Cuenta origen = cuentaRepo.findById(cuentaOrigen)
            .orElseThrow(() -> new CuentaNotFoundException(cuentaOrigen));
        Cuenta destino = cuentaRepo.findById(cuentaDestino)
            .orElseThrow(() -> new CuentaNotFoundException(cuentaDestino));

        if (origen.getSaldo().compareTo(monto) < 0) {
            throw new SaldoInsuficienteException(cuentaOrigen);
        }

        origen.setSaldo(origen.getSaldo().subtract(monto));
        destino.setSaldo(destino.getSaldo().add(monto));

        cuentaRepo.save(origen);
        cuentaRepo.save(destino);
        auditLogger.log("TRANSFERENCIA", cuentaOrigen, cuentaDestino, monto);
    }
}
```

Resultado esperado: el agente genera tests para transferencia exitosa, cuenta origen no encontrada, cuenta destino no encontrada, saldo insuficiente, monto cero, monto negativo, monto exactamente igual al saldo, fallo al guardar en el repositorio, y fallo del logger de auditoría. Cada test explica por qué ese escenario importa.

---

## Notas

- Si el componente es muy grande (más de 150 líneas), pasalo en partes o indicá qué método específico querés testear.
- Para tests de integración con bases de datos, el stack de Sooft usa Testcontainers con PostgreSQL. Si el agente genera tests de integración, pedile que use ese approach.
- Los tests generados son un punto de partida: revisalos, ajustá los asserts al comportamiento real del sistema y agregá los escenarios específicos del negocio que el agente no pudo inferir.
- Si el componente implementa reglas de negocio complejas (límites de transferencia, horarios de operación, validaciones regulatorias), incluílas en el contexto adicional para que el agente pueda generar los tests correctos.
