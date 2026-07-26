# Stack — Python (FastAPI)

Stack recomendado por defecto para el arquetipo de backend en Python de **Sooft**. Todas las elecciones son librerías estándar de mercado disponibles en PyPI público. Ajustá solo con justificación técnica documentada.

| Preocupación | Elección recomendada | Notas |
|---|---|---|
| Runtime | Python 3.11+ | Mejoras de performance y mejor tipado. Evitar EOL; alinear con la imagen base del contenedor. |
| Framework | FastAPI | Async nativo, validación con pydantic v2, OpenAPI automático, inyección de dependencias con `Depends`. |
| Server | uvicorn (dev) / gunicorn + uvicorn workers (prod) | `gunicorn app.main:app -k uvicorn.workers.UvicornWorker -w N`. Nunca `--reload` en prod; dimensionar workers por CPU. |
| Gestión de deps | uv (preferido) o poetry | Ambos generan lockfile reproducible. Commitear el lockfile (`uv.lock` / `poetry.lock`). |
| Testing | pytest, pytest-asyncio, httpx test client, coverage | `pytest-asyncio` para tests async; `TestClient`/`httpx.AsyncClient` para integración de endpoints; `coverage`/`c8`-equivalente con umbral mínimo en CI. |
| Logging | structlog (JSON) | Salida JSON estructurada, parseable por el stack de observabilidad. Nunca loguear PII ni secretos. Incluir `request_id`. |
| Validación / Serialización | pydantic v2 + pydantic-settings | Modelos de request/response explícitos; config tipada desde entorno con fail-fast al arranque. |
| API docs | OpenAPI nativo de FastAPI | Generación automática (`/docs`, `/redoc`, `/openapi.json`). Documentar modelos, ejemplos y códigos de error. |
| Cliente HTTP | httpx + tenacity | httpx async con timeouts explícitos; tenacity para retry con backoff exponencial solo en errores transitorios. |
| Observabilidad | OpenTelemetry Python | Traces, métricas y correlación de logs. Instrumentación automática de FastAPI/httpx; export OTLP al collector. |
| Persistencia | SQLAlchemy 2.x + Alembic | ORM/Core estilo 2.x (tipado); Alembic para migraciones versionadas y revisables en PR. Repositorios detrás de interfaces. |
| Seguridad | OAuth2/JWT (python-jose o pyjwt), passlib, secretos por entorno | Validar JWT en cada request protegido; hashing con passlib (bcrypt/argon2). Sin secretos en el repo. |
| Linter / format | ruff + mypy | ruff para lint y formato (reemplaza flake8/isort/black); mypy para tipado estático. Correr en CI y pre-commit. |
| Contenedor | Dockerfile multi-stage, base python:3.11-slim | Etapa de build separada de runtime; usuario no-root; instalar deps desde lockfile; imagen final mínima. |

## Versionado y actualización

- **Lockfile commiteado**: `uv.lock` o `poetry.lock` siempre en el repo. Garantiza builds reproducibles entre entornos.
- **Pin de versiones**: fijar versiones de dependencias directas; las transitivas quedan resueltas por el lockfile. Evitar rangos abiertos (`*`) en producción.
- **Escaneo de CVEs**: correr `pip-audit` en CI para detectar dependencias con vulnerabilidades conocidas; el pipeline falla ante hallazgos críticos.
- **Actualización automatizada**: usar `dependabot` (o equivalente) para PRs de bump periódicos; revisar changelog y correr la suite completa antes de mergear.
- **Cadencia**: actualizar dependencias de seguridad de inmediato; el resto en ventanas planificadas. Nunca actualizar mayor de versión sin correr tests de integración.
