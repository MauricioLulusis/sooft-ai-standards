# Recurso interno de `sooft`: test-strategy

> Recurso interno de la constitución `sooft` — **no es una skill invocable** ni un slash command. El agente lo carga leyendo este archivo (`sooft/internal/sooft-test-strategy.md`) cuando el flujo lo pide. Regí siempre por la skill `sooft` (principios, gates de aprobación, máquina de estados y reglas no negociables).

## Cuándo usarlo

- Antes de implementar features complejas que afecten múltiples capas.
- Para bugs que necesitan test de reproducción (el test debe fallar antes del fix).
- Cuando el developer no está seguro de qué testear o qué nivel de cobertura es suficiente.
- Cuando el PLAN.md no incluye una sección de tests explícita.

## Delegación a subagente Copilot CLI

Si estás en **Copilot CLI** y existe el custom agent `sooft-test-strategist`, delegá a ese subagente la estrategia de tests, detección de gaps y propuesta de casos. Solo delegá escritura de tests cuando el PLAN aprobado lo habilite explícitamente. El orquestador SOOFT conserva la decisión de fase, la evidencia y los gates.

Si el subagente no está disponible, seguí este recurso directamente.

## Qué produce

Una sección **"Estrategia de tests"** dentro del `PLAN.md` existente, o un documento separado `test-strategy.md` en la carpeta del ticket, con:

- Lista de casos de prueba por tipo (ver tipos, stack y convenciones en la skill `sooft` → `assets/policies/testing-guidelines.md`).
- Nivel de cobertura esperado para el código nuevo (respetar umbrales de `sooft` → `assets/policies/testing-guidelines.md`).
- Decisión explícita sobre qué NO se testea y por qué.

---

## Cómo armar el plan de tests

1. Leé la skill `sooft` → `assets/policies/testing-guidelines.md` para conocer tipos de tests, stack, convenciones y reglas de TDD según el tipo de trabajo (feature / bug / refactor).
2. Para cada pieza de lógica nueva o modificada, elegí el tipo de test apropiado.
3. Listá los casos concretos (no genéricos): clase/método, escenario, resultado esperado.
4. Indicá explícitamente qué queda fuera y por qué (código generado, config pura, etc.).

---

## Salida esperada

```markdown
## Estrategia de tests

### Unitarios
- [ ] `ServicioX.metodoY` — caso feliz con entrada válida
- [ ] `ServicioX.metodoY` — lanzar `ExcepcionZ` cuando entrada es nula
- [ ] `ValidadorA.validar` — retornar false para cada campo obligatorio faltante

### Integración
- [ ] `RepositorioX.guardar` — persistir entidad con relaciones lazy
- [ ] `RepositorioX.buscarPorId` — retornar vacío cuando no existe

### E2E
- [ ] Flujo completo: crear → procesar → confirmar (happy path)
- [ ] Flujo con error: crear → procesar → fallo en paso 2 → rollback

### No se testea
- Código generado por el framework (getters/setters sin lógica).
- Configuración de beans de Spring (cubierto por contexto de integración).
```
