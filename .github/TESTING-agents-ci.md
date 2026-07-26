# TESTING — copilot-cli-agents-ci-validation

Instrucciones de testing para el PR `feat/copilot-cli-agents-ci-validation`.
Cubre: CI de validación, perfiles de agentes y flujos de integración SOOFT.

---

## 1. CI — `ci/validate-copilot-agents.sh`

### 1.1 Happy path (debe pasar sin errores)

```sh
sh ci/validate-copilot-agents.sh
# Salida esperada al final: "Copilot agent validation passed."
```

### 1.2 Mutation tests — cada uno debe hacer FALLAR el script

Hacé cada cambio, corré el script, verificá el error, y revertí antes del siguiente.

| # | Mutación | Error esperado |
|---|----------|----------------|
| M1 | En `sooft-code-reviewer.agent.md` cambiá `tools: ["read", "search"]` → `tools: ["read", "write"]` | `must be read-only; found non-allowed tool` |
| M2 | En cualquier `.agent.md` cambiá el `model:` a uno que no esté en `KNOWN_MODELS` (ej. `model: gpt-3`) | `model gpt-3 is not in the documented model allowlist` |
| M3 | En `MODELS.md` borrá la fila de `gemini-3.5-flash` (sin cambiar ningún agente) | `MODELS.md missing fallback row for gemini-3.5-flash` |
| M4 | En `MODELS.md` borrá la fila de `gemini-3.1-pro-preview` | `MODELS.md missing fallback row for gemini-3.1-pro-preview` |
| M5 | Agregá `sooft-new-agent` a la variable `AGENTS` al inicio del script (sin crear el `.agent.md`) | `missing required file: .github/agents/sooft-new-agent.agent.md` |
| M6 | Creá `.github/agents/sooft-new-agent.agent.md` con frontmatter válido, agregalo a `AGENTS`, pero **no** agregues su `case` en el bloque de routing | `has no routing case defined in the validator` |
| M7 | En cualquier `.agent.md` borrá la línea que referencia `.github/agents/MODELS.md` | `missing MODELS.md reference` |
| M8 | En `.github/copilot-instructions.md` borrá una mención de algún agente (ej. `sooft-discovery`) | `.github/copilot-instructions.md missing sooft-discovery` |

---

## 2. Perfiles de agentes — smoke tests manuales en Copilot CLI

Para cada agente: abrí una sesión en el repo y usá el prompt sugerido.
Verificá que el agente respete sus restricciones (los `read-only` no deben tocar archivos).

### sooft-discovery

```text
@sooft-discovery Explorá el repo y contame qué sistemas afectaría agregar un nuevo custom agent de tipo "sooft-adr-writer".
```

**Verificar:** respuesta con resumen de discovery + handoff section. Sin modificaciones de archivo.

### sooft-prd-writer

```text
@sooft-prd-writer Con este discovery: "Agregar sooft-adr-writer que documenta decisiones de arquitectura como subagente read-only del orquestador SOOFT", redactá un PRD borrador.
```

**Verificar:** PRD con criterios de éxito medibles. Sin `[NEEDS CLARIFICATION]` obvios. Sin modificar archivos fuera de `docs/`.

### sooft-spec-architect

```text
@sooft-spec-architect Diseñá la SPEC técnica para agregar sooft-adr-writer: qué archivos toca, qué routing necesita, qué validaciones en CI.
```

**Verificar:** SPEC con secciones de arquitectura, riesgos y rollback. Sin código de producción.

### sooft-plan-writer

```text
@sooft-plan-writer Armá el PLAN para agregar sooft-adr-writer basándote en esta SPEC: [pegá la SPEC]. Seguí las convenciones de tareas numeradas T001, T002... con rutas reales.
```

**Verificar:** PLAN con tareas ordenadas, rutas reales (no placeholders), TDD donde aplica.

### sooft-bug-analyst

```text
@sooft-bug-analyst El script ci/validate-copilot-agents.sh no detecta cuando un agente tiene una descripción vacía en el frontmatter. Analizá causa raíz y estrategia de reproducción.
```

**Verificar:** análisis de causa raíz con evidencia de línea/archivo. Estrategia de reproducción con test first. Sin modificaciones.

### sooft-test-strategist

```text
@sooft-test-strategist Definí la estrategia de tests para ci/validate-copilot-agents.sh: qué casos cubrir, dónde viven los tests, qué framework.
```

**Verificar:** lista de casos por tipo, decisión explícita de qué NO testear, cobertura esperada.

### sooft-security-reviewer *(read-only — no debe tocar archivos)*

```text
@sooft-security-reviewer Revisá el diff de este PR buscando secretos hardcodeados, PII, o configuraciones inseguras en los agent profiles y el script CI.
```

**Verificar:** revisión estructurada con hallazgos bloqueantes/no bloqueantes y veredicto. **Cero archivos modificados.**

### sooft-code-reviewer *(read-only — no debe tocar archivos)*

```text
@sooft-code-reviewer Revisá ci/validate-copilot-agents.sh: lógica, correctitud, casos borde no cubiertos.
```

**Verificar:** issues priorizados, señal/ruido alta. **Cero archivos modificados.**

### sooft-evidence-writer

```text
@sooft-evidence-writer Actualizá .sooft/evidence.md registrando que se agregaron 10 custom agents y el CI de validación. Commit: 49cdb63. Reviewer: [tu usuario].
```

**Verificar:** `.sooft/evidence.md` actualizado con archivos IA-generated, validaciones corridas y decisiones. Nada fuera de `.sooft/`.

### sooft-release-writer

```text
@sooft-release-writer Redactá las release notes y el checklist de deploy para este PR: nuevos custom agents, CI script, fixes de code review.
```

**Verificar:** release notes con secciones Breaking/New/Fixed. Checklist de rollback. Sin código de producción.

---

## 3. Flujos de integración SOOFT (end-to-end)

Estos son los flujos que se usaron en el desarrollo de este PR, documentados para que el reviewer pueda reproducirlos.

### Flujo A — Feature con code review y fixes (lo que hizo este PR)

```text
# 1. Pedí un /review
/review

# 2. Agente reporta hallazgos — confirmás fixes
"si"

# 3. SOOFT hace discovery → presenta PLAN → esperás aprobación
"dale"  # o "aprobado"

# 4. Agente implementa, commitea en branch, pushea
# 5. Pedís otro /review sobre los nuevos cambios
/review

# 6. Agente reporta nuevos hallazgos → confirmás
"si"
# 7. Agente implementa, commitea, pushea al branch
```

### Flujo B — Feature desde cero

```text
# 1. Describí el feature en lenguaje natural
"quiero agregar un agente sooft-adr-writer que documente decisiones de arquitectura"

# 2. SOOFT hace discovery (preguntas con opciones)
# 3. Respondés las preguntas
# 4. SOOFT presenta PRD → aprobás
"aprobado"
# 5. SOOFT presenta PLAN (con TDD si hay lógica) → aprobás
"dale"
# 6. SOOFT implementa tarea a tarea
# 7. /review → aprobás el código IA-generated
# 8. SOOFT crea branch, commitea, pushea, abre PR
```

### Flujo C — Bug

```text
# 1. Reportás el bug
"el script CI no detecta descripción vacía en el frontmatter"

# 2. SOOFT hace discovery → analysis → reproduce con test primero (rojo)
# 3. SOOFT presenta FIX PLAN → aprobás
"dale"
# 4. SOOFT implementa fix → test pasa (verde)
# 5. /review → commitea y pushea
```

---

## 4. Verificaciones de seguridad del CI (allow-list)

Probá estos casos directamente en la línea `tools:` de un reviewer agent:

| Valor de `tools:` | Resultado esperado |
|-------------------|--------------------|
| `["read", "search"]` | ✅ read-only |
| `["read", "grep", "glob"]` | ✅ read-only |
| `["read", "write"]` | ❌ falla |
| `["read", "create"]` | ❌ falla |
| `["read", "computer"]` | ❌ falla |
| `["read", "terminal"]` | ❌ falla |
| `["*"]` | ❌ falla |
| `[]` (vacío) | ✅ pasa (sin tools = sin riesgo) |

---

## 5. Checklist del reviewer

- [ ] `sh ci/validate-copilot-agents.sh` pasa sin errores
- [ ] Al menos 3 mutation tests de M1-M8 ejecutados y verificados
- [ ] Smoke test de `sooft-security-reviewer` y `sooft-code-reviewer` confirma que no modifican archivos
- [ ] Al menos un flujo de integración (A, B o C) recorrido de punta a punta
- [ ] Tabla de allow-list (sección 4) verificada con al menos M1 y un caso de false negative
