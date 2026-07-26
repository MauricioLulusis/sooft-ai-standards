---
mode: agent
description: Flujo de bug/regresión — intake, análisis, reproducción y fix con gate de plan. Delega en la skill sooft-bugs.
---

# /sooft-bugs — flujo de corrección (rama fix)

Cargá la skill **`sooft`** (constitución) si no está cargada y conducí la corrección con la skill **`sooft-bugs`**. **No reproduzcas los pasos acá — esas skills mandan.**

Recordá lo no negociable: el **discovery / intake va SIEMPRE primero** (ante "analizá el bug / encontrá el error / revisá esto" también), y **no escribís código de fix hasta que el fix plan esté aprobado**. El flujo de bug es reproducción-first (un test que reproduce el bug antes del fix). La skill `sooft-bugs` define el flujo completo y los gates.
