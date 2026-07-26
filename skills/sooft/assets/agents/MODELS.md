# Modelos y fallbacks para custom agents SOOFT

Esta política aplica a los custom agents de GitHub Copilot CLI en `.github/agents/*.agent.md`.

Los skills principales de SOOFT siguen siendo la fuente de verdad del workflow, gates y estado. Los custom agents son ayudantes especializados ejecutados como subagentes.

---

## Reglas obligatorias

1. **No uses `model: auto` para routing determinista.** Si la sesión principal usa `auto`, Copilot CLI puede hacer que los subagentes hereden el modelo resuelto y no respeten el `model` del perfil.
2. **Cada agente debe declarar un modelo documentado por Copilot CLI** o usar `inherit` solo si esta política lo indica explícitamente.
3. **Cada modelo usado debe tener fallback documentado** en esta página.
4. **Si el modelo primario falla por disponibilidad, policy o retiro**, no inventes un modelo: cambiá al fallback documentado o a `inherit`, registrá la decisión en `.sooft/evidence.md` y continuá solo si el orquestador SOOFT lo permite.
5. **El orquestador SOOFT conserva los gates.** Ningún subagente aprueba PRD, SPEC, PLAN, código IA-generated ni PR.

---

## Modelos documentados para Copilot CLI

| Modelo | Uso recomendado en SOOFT |
|--------|--------------------------|
| `claude-haiku-4.5` | Discovery, documentación liviana, evidencia, tareas mecánicas. |
| `claude-sonnet-4.6` | Trabajo general, planes, reviews generales, coordinación. |
| `gpt-5.3-codex` | Tareas centradas en código y tests. |
| `gpt-5.4` | Seguridad, arquitectura, debugging complejo, análisis de bugs. |
| `gemini-3.1-pro-preview` | Razonamiento alternativo cuando GPT/Claude no estén disponibles. |
| `gemini-3.5-flash` | Tareas rápidas y livianas. |
| `mai-code-1-flash` | Documentación, resúmenes y tareas de bajo costo. |

> La disponibilidad real depende del plan y políticas de la organización. Validá localmente con `/model`.

---

## Matriz agente → modelo

| Agente | Modelo primario | Esfuerzo sugerido | Motivo |
|--------|-----------------|-------------------|--------|
| `sooft-discovery` | `claude-haiku-4.5` | low | Lectura y preguntas acotadas, sin escritura. |
| `sooft-prd-writer` | `claude-haiku-4.5` | low | Redacción estructurada de PRD. |
| `sooft-spec-architect` | `gpt-5.4` | high | Arquitectura, riesgos, seguridad e integraciones. |
| `sooft-plan-writer` | `claude-sonnet-4.6` | medium | Planificación SOOFT y trazabilidad. |
| `sooft-bug-analyst` | `gpt-5.4` | high | Causa raíz, reproducción y debugging complejo. |
| `sooft-test-strategist` | `gpt-5.3-codex` | medium | Estrategia/generación de tests centrada en código. |
| `sooft-security-reviewer` | `gpt-5.4` | high | Revisión de seguridad, PII, auth/authz y secretos. |
| `sooft-code-reviewer` | `claude-sonnet-4.6` | medium | Review general de correctitud, diseño y tests. |
| `sooft-evidence-writer` | `claude-haiku-4.5` | low | Evidencia y documentación mecánica. |
| `sooft-release-writer` | `mai-code-1-flash` | low | Release notes y checklist de salida. |

---

## Fallbacks por modelo

| Modelo primario | Fallback 1 | Fallback 2 | Último recurso |
|-----------------|------------|------------|----------------|
| `claude-haiku-4.5` | `mai-code-1-flash` | `gemini-3.5-flash` | `inherit` |
| `mai-code-1-flash` | `claude-haiku-4.5` | `gemini-3.5-flash` | `inherit` |
| `gemini-3.5-flash` | `claude-haiku-4.5` | `mai-code-1-flash` | `inherit` |
| `claude-sonnet-4.6` | `gpt-5.3-codex` | `gpt-5.4` | `inherit` |
| `gpt-5.3-codex` | `claude-sonnet-4.6` | `gpt-5.4` | `inherit` |
| `gpt-5.4` | `claude-sonnet-4.6` | `gpt-5.3-codex` | `inherit` |
| `gemini-3.1-pro-preview` | `gpt-5.4` | `claude-sonnet-4.6` | `inherit` |

`inherit` significa heredar el modelo de la sesión principal. Usalo solo si no hay un modelo explícito disponible y documentá la decisión.

---

## Configuración local recomendada

En Copilot CLI:

```copilot
/model
/subagents
/agent
```

Usá `/model` para ver los modelos reales habilitados para tu usuario/organización. Usá `/subagents` para overrides locales por agente si tu org bloquea algún modelo.

Ejemplo conceptual de override en `~/.copilot/settings.json`:

```jsonc
{
  "subagents": {
    "agents": {
      "sooft-security-reviewer": {
        "model": "gpt-5.4",
        "effortLevel": "high",
        "contextTier": "default"
      },
      "sooft-prd-writer": {
        "model": "claude-haiku-4.5",
        "effortLevel": "low",
        "contextTier": "default"
      }
    }
  }
}
```

---

## Smoke tests manuales

Si necesitás verificar disponibilidad desde la terminal:

```sh
copilot --model claude-haiku-4.5 -p "Reply with only OK"
copilot --model claude-sonnet-4.6 -p "Reply with only OK"
copilot --model gpt-5.3-codex -p "Reply with only OK"
copilot --model gpt-5.4 -p "Reply with only OK"
copilot --model gemini-3.5-flash -p "Reply with only OK"
copilot --model mai-code-1-flash -p "Reply with only OK"
```

Si alguno falla, aplicá la tabla de fallbacks y dejá evidencia.
