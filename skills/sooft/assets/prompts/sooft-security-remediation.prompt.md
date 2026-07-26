---
mode: agent
description: Flujo de remediación de seguridad — triage, scope confirmado y fixes con gate. Delega en la skill sooft-security-remediation.
---

# /sooft-security-remediation — flujo de remediación (rama security)

Cargá la skill **`sooft`** (constitución) si no está cargada y conducí la remediación con la skill **`sooft-security-remediation`**. **No reproduzcas los pasos acá — esas skills mandan.**

Recordá lo no negociable: el **discovery / intake va SIEMPRE primero**, y hay dos gates críticos: **confirmación de scope** antes de planificar y **plan aprobado** antes de aplicar fixes. La validación de seguridad (SAST) y los tests existentes en verde son parte del cierre. La skill `sooft-security-remediation` define el flujo completo y los gates.
