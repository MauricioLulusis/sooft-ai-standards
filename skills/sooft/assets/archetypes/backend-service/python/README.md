# Arquetipo backend — Python (FastAPI)

Arquetipo genérico y market-standard para construir servicios backend en Python con FastAPI, alineado a la metodología **Sooft Engineering AI Rails**. Es material de referencia para agentes de IA y developers de **Sooft**: describe estructura, preocupaciones transversales y decisiones por defecto para arrancar un servicio productivo sin reinventar cimientos.

## Qué es y cuándo usarlo

Usá este arquetipo cuando necesites:

- **API REST**: exponer recursos vía HTTP con contratos versionados y documentación OpenAPI.
- **Microservicio**: unidad de despliegue independiente, con su propio ciclo de vida, config y observabilidad.
- **Servicio de datos o ML-serving liviano**: exponer inferencia de modelos ya entrenados o endpoints de consulta/transformación de datos con baja latencia.

No lo uses para: jobs batch puros sin interfaz HTTP (usá un worker/CLI), pipelines de entrenamiento pesado de ML, o front-ends. Para esos casos aplican otros arquetipos.

FastAPI es la elección por defecto por su soporte nativo de async, validación con pydantic v2, generación automática de OpenAPI y madurez del ecosistema.

## Layout recomendado

Organización por capas con dependencias apuntando siempre hacia el dominio (arquitectura hexagonal simplificada):

```
mi-servicio/
├── app/
│   ├── main.py                 # Composición: crea la app FastAPI, monta routers, middlewares, lifespan
│   ├── api/
│   │   └── routers/            # Endpoints HTTP: solo request/response + delegación a services
│   │       ├── health.py
│   │       └── items.py
│   ├── services/               # Lógica de negocio / casos de uso. Orquesta domain + repositories + clients
│   │   └── item_service.py
│   ├── domain/
│   │   └── models/             # Entidades y value objects del dominio (pydantic o dataclasses)
│   │       └── item.py
│   ├── repositories/           # Acceso a persistencia (DB). Abstrae SQLAlchemy detrás de interfaces
│   │   └── item_repository.py
│   ├── clients/                # Integraciones salientes (HTTP a terceros, colas, storage)
│   │   └── pricing_client.py
│   └── core/
│       ├── config.py           # Settings con pydantic-settings
│       ├── logging.py          # Configuración de structlog
│       ├── errors.py           # Excepciones de dominio + exception handlers
│       └── observability.py    # Setup de OpenTelemetry
├── tests/
│   ├── unit/                   # Tests de services/domain con dependencias mockeadas
│   └── integration/            # Tests de routers y repositories (TestClient / DB efímera)
├── pyproject.toml              # Deps, metadata y config de herramientas (ruff, mypy, pytest)
├── Dockerfile
├── .env.example                # Documenta variables; NUNCA commitear .env real
└── README.md
```

**Reglas de dependencia:**

- `api/routers` depende de `services`, nunca al revés.
- `services` depende de `domain`, `repositories` y `clients` a través de abstracciones.
- `domain` no depende de nada de infraestructura (ni FastAPI, ni SQLAlchemy).
- La construcción de dependencias (DB, clients) se resuelve con el sistema de `Depends` de FastAPI.

## Bootstrap

Elegí **uv** (recomendado por velocidad y lockfile reproducible) o **poetry**. Ambos generan lockfile commiteable.

### Con uv

```bash
uv init mi-servicio && cd mi-servicio
uv add fastapi uvicorn[standard] pydantic pydantic-settings structlog httpx tenacity
uv add --dev pytest pytest-asyncio coverage ruff mypy
uv run uvicorn app.main:app --reload --port 8000
```

### Con poetry

```bash
poetry new mi-servicio && cd mi-servicio
poetry add fastapi uvicorn[standard] pydantic pydantic-settings structlog httpx tenacity
poetry add --group dev pytest pytest-asyncio coverage ruff mypy
poetry run uvicorn app.main:app --reload --port 8000
```

### Con venv + pip (fallback)

```bash
python -m venv .venv
source .venv/bin/activate      # Windows: .venv\Scripts\activate
pip install fastapi "uvicorn[standard]" pydantic pydantic-settings structlog httpx tenacity
uvicorn app.main:app --reload --port 8000
```

En producción se sirve con **gunicorn** gestionando workers de **uvicorn** (`gunicorn app.main:app -k uvicorn.workers.UvicornWorker -w 4`), nunca con `--reload`.

## Preocupaciones transversales

### Configuración (12-factor)

Toda la config viene del entorno, jamás hardcodeada. Usá `pydantic-settings` para tipar y validar variables al arranque; si falta una requerida, la app falla rápido (fail-fast).

```python
# app/core/config.py
from pydantic import Field
from pydantic_settings import BaseSettings, SettingsConfigDict

class Settings(BaseSettings):
    model_config = SettingsConfigDict(env_file=".env", env_prefix="APP_")

    environment: str = Field(default="local")   # local | dev | staging | prod
    log_level: str = Field(default="INFO")
    database_url: str                            # requerida, sin default: falla si no está
    http_timeout_seconds: float = Field(default=5.0)

settings = Settings()
```

Un solo objeto `Settings` por proceso. Nunca leas `os.environ` disperso por el código. Los secretos (DB, tokens) llegan por variables de entorno inyectadas por la plataforma, nunca en el repo.

### Logging estructurado

Logs en **JSON** con `structlog`, para que sean parseables por el stack de observabilidad. **Nunca loguees PII, secretos ni tokens.** Incluí un `request_id` correlacionable.

```python
# app/core/logging.py
import structlog

def configure_logging(log_level: str) -> None:
    structlog.configure(
        processors=[
            structlog.contextvars.merge_contextvars,
            structlog.processors.add_log_level,
            structlog.processors.TimeStamper(fmt="iso"),
            structlog.processors.JSONRenderer(),
        ],
        wrapper_class=structlog.make_filtering_bound_logger(log_level),
    )
```

### Manejo de errores + envelope

Definí excepciones de dominio y registralas con exception handlers que devuelven un **envelope de error consistente**. Nunca filtres stack traces ni detalles internos al cliente.

```python
# app/core/errors.py
from fastapi import Request
from fastapi.responses import JSONResponse

class DomainError(Exception):
    def __init__(self, code: str, message: str, status_code: int = 400):
        self.code, self.message, self.status_code = code, message, status_code

async def domain_error_handler(request: Request, exc: DomainError) -> JSONResponse:
    return JSONResponse(
        status_code=exc.status_code,
        content={"error": {"code": exc.code, "message": exc.message}},
    )
```

Envelope estándar de error: `{"error": {"code": "...", "message": "..."}}`. Los `500` devuelven un mensaje genérico y loguean el detalle internamente.

### Validación de input

Toda entrada se valida con **pydantic v2** vía modelos de request. FastAPI rechaza automáticamente payloads inválidos con `422`. Definí modelos explícitos de request y response (no expongas entidades de dominio ni de DB directamente); usá `response_model` para controlar qué sale.

### Health endpoints

Exponé `GET /health/live` (liveness: el proceso responde) y `GET /health/ready` (readiness: dependencias como DB están disponibles). La plataforma los usa para routing y reinicios.

```python
# app/api/routers/health.py
from fastapi import APIRouter

router = APIRouter(prefix="/health", tags=["health"])

@router.get("/live")
async def live() -> dict:
    return {"status": "ok"}

@router.get("/ready")
async def ready() -> dict:
    # Chequear dependencias críticas (DB, cache) antes de reportar ready
    return {"status": "ready"}
```

### Cliente HTTP con reintentos

Consumí APIs externas con `httpx` (async) más `tenacity` para reintentos con backoff exponencial en errores transitorios. Configurá siempre timeouts explícitos.

```python
# app/clients/pricing_client.py
import httpx
from tenacity import retry, stop_after_attempt, wait_exponential, retry_if_exception_type

class PricingClient:
    def __init__(self, base_url: str, timeout: float):
        self._client = httpx.AsyncClient(base_url=base_url, timeout=timeout)

    @retry(
        stop=stop_after_attempt(3),
        wait=wait_exponential(multiplier=0.2, max=2),
        retry=retry_if_exception_type(httpx.TransportError),
    )
    async def get_price(self, sku: str) -> dict:
        resp = await self._client.get(f"/prices/{sku}")
        resp.raise_for_status()
        return resp.json()
```

Reintentá solo errores transitorios (timeouts, 5xx, errores de red); nunca reintentes `4xx` de negocio.

### Observabilidad (OpenTelemetry)

Instrumentá con **OpenTelemetry Python**: traces distribuidos, métricas y correlación con logs. Usá la instrumentación automática de FastAPI y httpx para propagar contexto entre servicios, y exportá por OTLP al collector del entorno.

### Seguridad

- **Sin secretos hardcodeados**: todo por entorno.
- **Sin PII en logs**: sanitizá antes de loguear.
- **AuthN/AuthZ**: OAuth2/JWT validando tokens en cada request protegido; hashing de credenciales con `passlib`.
- **Validación de input**: pydantic en todos los bordes; nunca confíes en datos externos.
- **Dependencias sin CVEs**: escaneá con `pip-audit` en CI y mantené el lockfile actualizado.
- **HTTPS/TLS**: terminado en el borde de la plataforma; el servicio asume tráfico interno confiable pero valida igual.
- **Rate limiting y CORS**: configurados explícitamente según el consumidor.

## Referencias

- Reglas de oro transversales del arquetipo: [../golden-rules.md](../golden-rules.md)
- Stack tecnológico detallado: [tech-stack.md](tech-stack.md)
