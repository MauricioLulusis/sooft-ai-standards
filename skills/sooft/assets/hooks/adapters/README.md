# Librería de adapters del hook de sesión

Esta carpeta guarda traducciones **ya verificadas** de `../session-start.yml` (la spec
canónica, agnóstica a la herramienta) al formato nativo de una herramienta puntual.

**No es una lista cerrada de herramientas soportadas.** El algoritmo que produjo cada
archivo de aquí es el mismo que cualquier agente, corriendo en cualquier herramienta
—incluida una que no exista todavía—, puede seguir para sí mismo. Ver
`internal/sooft-bootstrap.md` §"Hook de sesión" de la skill `sooft` para el
procedimiento completo. En resumen:

1. ¿Ya hay un adapter para tu herramienta en esta carpeta? Usalo tal cual.
2. Si no, ¿tu herramienta tiene un mecanismo de hooks nativo (evento de inicio de
   sesión, o equivalente) que puedas **confirmar con certeza en este momento** contra
   su propia documentación? Traducí `../session-start.yml` a ese formato.
3. Si no podés confirmarlo, no instales nada. SOOFT sigue funcionando igual — el mismo
   mensaje ya vive en las instrucciones always-on (`AGENTS.md`, etc.).
4. Si en el paso 2 lograste construir y verificar un adapter nuevo, **guardalo en esta
   carpeta** como `<herramienta>.json` (o el formato que corresponda) antes de seguir.
   Así el próximo developer que use esa misma herramienta ya lo encuentra en el
   paso 1 — la librería crece con el uso, no con trabajo manual previo.

## Herramientas con adapter propio (fuera de esta carpeta, por motivos de plumbing)

- **Copilot** vive en `../../sooft.json` (no en `adapters/`) porque su instalación
  necesita dos ubicaciones simultáneas (`~/.copilot/hooks/` y `.github/hooks/`), a
  diferencia del resto de las herramientas de esta carpeta, que necesitan un único
  archivo. Es el mismo contenido canónico, con más plumbing de destino — no un caso
  distinto en sustancia.

## Adapters verificados en esta carpeta

- `claude.json` — Claude Code. Mergear `hooks.SessionStart` en `.claude/settings.json`.
