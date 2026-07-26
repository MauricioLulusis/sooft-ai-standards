---
mode: agent
description: Punto de entrada de SOOFT — inicializa SOOFT en el proyecto (banner, detección de stack/integraciones, .sooft/). Delega en la skill sooft.
---

# /sooft — Inicialización de SOOFT

Cargá y seguí la skill **`sooft`**: es la constitución de SOOFT y contiene el arranque completo. **No reproduzcas los pasos acá — la skill `sooft` manda.**

> **ORDEN OBLIGATORIO.** Tu **primerísima acción**, sin escribir una sola palabra antes, es imprimir el banner tal como lo define el **§0.0 de la skill `sooft`** (en un bloque de código con triple backtick, para que el ASCII no se rompa en el IDE). Recién después seguís con el auto-setup de hooks (§0.1) y el `sooft-init` (detección de stack e integraciones + creación de `.sooft/`), todo según la skill `sooft`.

Esto **no** arranca un workflow de feature/bug/seguridad: solo prepara el entorno. Para esos flujos están `/sooft-development`, `/sooft-bugs` y `/sooft-security-remediation`.
