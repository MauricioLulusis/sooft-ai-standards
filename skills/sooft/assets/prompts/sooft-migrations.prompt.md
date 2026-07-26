---
mode: agent
description: Flujo de migración guiado por el dev — define origen y destino, y la skill conduce la migración (upgrade de versión o port entre tecnologías) con discovery, plan y gates. Delega en la skill sooft-migrations.
---

# /sooft-migrations — flujo de migración (rama migration)

Cargar la skill **`sooft`** (constitución) si no está cargada y conducir el flujo con la skill **`sooft-migrations`**. **No reproducir los pasos aquí — esas skills mandan.**

Lo no negociable: el **discovery va SIEMPRE primero** y es el **driver**. La **tecnología y versión de origen** salen del init (`.sooft/`); con el dev se **confirma el origen** y se **define el destino** (tecnología y versión). De ahí sale si es un **upgrade de versión** mismo-lenguaje (Java 8→21, Spring 2→3) o un **port entre tecnologías** (Java→C#). **No se toca NINGÚN archivo del proyecto hasta que el PLAN de migración esté aprobado** explícitamente por el dev. El plan se arma **leyendo el proyecto real**, no desde una matriz precargada. La migración **preserva la semántica** (refactor de plataforma, no cambio funcional); los tests quedan en verde. El trabajo va en un **worktree aislado** (`.worktrees/migration-{slug}`). El motor (OpenRewrite vía `engines/java-migrator`) se usa **solo en upgrade mismo-lenguaje Java**; para un port, el subagente `migration-agent` traduce en el toolchain destino. Si el loop llega a **5 intentos fallidos** o hay un conflicto de Git que no compila → `MIGRATION_BLOCKED` y se pide intervención humana. La skill `sooft-migrations` define el flujo completo y los gates.
