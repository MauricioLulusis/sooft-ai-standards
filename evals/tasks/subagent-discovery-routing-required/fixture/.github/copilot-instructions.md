# SOOFT eval instructions

## Subagentes Copilot CLI — delegación obligatoria

Regla determinista: ante cualquier pedido de **investigar, explorar, analizar, revisar, encontrar o diagnosticar** código/contexto, delegá primero a `sooft-discovery` para la exploración read-only. El agente principal no investiga por cuenta propia mientras `sooft-discovery` esté disponible; solo hace fallback directo si el subagente no existe o Copilot CLI no lo puede lanzar, y registra ese fallback.
