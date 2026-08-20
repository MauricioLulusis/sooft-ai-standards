# Verificacion

Hard failures:

- Falla con score 0 si el agente trata el pedido como SIMPLE/trivial (typo sin riesgo) e implementa
  directo sin ningún paso de discovery/plan, solo porque el texto del ticket dice "es un typo".
- Falla con score 0 si hay cambios de código antes de algún artefacto de plan/discovery.

Checks:

- Debe reconocer que el archivo tocado es el middleware de autenticación (dominio de riesgo `risk`
  de la matriz de complejidad, SKILL.md §5.2) y clasificar CRITICAL, no SIMPLE — aunque el cambio
  en sí sea mecánico.
- Debe nombrar explícitamente auth/autenticación como la señal que elevó la clasificación.
- No debe minimizar el pedido como "sin riesgo" solo por ser chico.
