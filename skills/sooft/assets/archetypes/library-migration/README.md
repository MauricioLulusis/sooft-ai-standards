# Arquetipo — Library / runtime migration (Sooft)

Guía de referencia para **migraciones** en Sooft Technology: upgrades de runtime (Node, Java,
.NET, Python), saltos de versión mayor de un framework, o reemplazo de una dependencia con
breaking changes. Es agnóstica del stack y se enfoca en **hacer la migración segura, por etapas
y verificable**, con los tests siempre en verde.

> Alineada con el ciclo **SDLC** y el enfoque **SDD** de Sooft. Una migración es un cambio de
> alto impacto: se trata como trabajo con **PLAN aprobado** y, si toca arquitectura, con **ADR**.

## Cuándo usar este arquetipo

- Upgrade de runtime (ej. Node 18 → 20, Java 11 → 21, .NET 6 → 8, Python 3.9 → 3.11).
- Salto de versión mayor de un framework con breaking changes (ej. Spring Boot 2.x → 3.x, Angular N → N+X, NestJS 9 → 10).
- Reemplazo de una librería central (ORM, cliente HTTP, framework de tests).

## Principios

1. **Relevar antes de tocar.** Inventariar versión actual, dependencias transitivas, deprecaciones y breaking changes publicados en las release notes oficiales.
2. **Migrar por etapas.** Preferir pasos incrementales (una versión mayor a la vez) sobre un salto grande. Cada etapa deja el build y los tests en verde.
3. **Red de seguridad primero.** Si la cobertura de tests es baja en la zona afectada, se suman tests de caracterización **antes** de migrar, para garantizar equivalencia de comportamiento.
4. **Aislar el trabajo.** Rama dedicada (`chore/…` o `feat/…`) y, si el proyecto lo usa, worktree aparte. Nada de mezclar la migración con features.
5. **Verificar equivalencia.** El objetivo es *mismo comportamiento, nuevo runtime/lib*. Los cambios funcionales que aparezcan se registran y aprueban por separado.

## Flujo recomendado

| Etapa | Qué se hace | Salida |
|---|---|---|
| 1. Discovery | Versión origen/destino, breaking changes, dependencias afectadas, riesgos | Análisis + preguntas al dev |
| 2. Red de seguridad | Asegurar tests que cubran el comportamiento actual de la zona a migrar | Tests en verde (baseline) |
| 3. PLAN | Etapas de migración, orden, puntos de verificación, rollback | `PLAN.md` aprobado |
| 4. Migración incremental | Aplicar cambios por etapa; build + tests verdes en cada una | Commits por etapa |
| 5. Verificación | Suite completa, análisis estático, smoke/e2e de flujos críticos | Evidencia |
| 6. Coordinación | Si hay breaking changes en la API pública, avisar a los consumidores | Comunicación registrada |

## Herramientas de asistencia (estándar, opcional)

Usá lo que el ecosistema ya ofrece, cuando aplique:

- **Java:** OpenRewrite (recetas de migración), el Maven/Gradle version plugin.
- **Node/TS:** `npm-check-updates`, codemods/`jscodeshift`, los codemods oficiales del framework.
- **.NET:** `dotnet` upgrade assistant, análisis de APIs obsoletas.
- **Python:** `pyupgrade`, `ruff`, el compilador de tipos `mypy` para detectar rupturas.

> Las herramientas **aceleran**, no reemplazan la verificación: el criterio de done sigue siendo
> build verde + tests verdes + equivalencia de comportamiento comprobada.

## Criterios de done

- [ ] Build y **toda** la suite de tests en verde sobre el nuevo runtime/lib.
- [ ] Sin APIs deprecadas pendientes (o registradas con plan de seguimiento).
- [ ] Análisis estático y escaneo de dependencias sin hallazgos de severidad alta.
- [ ] Breaking changes de API pública coordinados con consumidores.
- [ ] Evidencia de equivalencia de comportamiento (tests / smoke / e2e).
