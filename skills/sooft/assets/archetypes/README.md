# Catálogo de arquetipos — Sooft Technology

Inventario de los **arquetipos de proyecto** que Sooft usa como punto de partida y referencia
de buenas prácticas. Un arquetipo describe **cómo se estructura y con qué se construye** un tipo
de proyecto: capas, preocupaciones transversales, stack recomendado y reglas de calidad y seguridad.

> **Genéricos, no atados a librerías internas.** Estos arquetipos se apoyan en herramientas
> **estándar del mercado** (open-source y proveedores públicos). No dependen de plataformas,
> parents de build ni librerías internas privadas. Reflejan prácticas de arquitectura vigentes a **2026**
> y el ciclo **SDLC** + enfoque **SDD** de la metodología Sooft.
>
> **Uso en el discovery.** Cuando el developer pregunta "¿con qué arranco?", "¿cómo estructuro
> esto?" o "¿qué stack conviene?", el agente responde a partir de este catálogo: detecta el tipo
> de proyecto y el stack, y carga el arquetipo correspondiente para proponer estructura, librerías
> y decisiones. Sobre esa base se decide qué se reutiliza y qué se construye.

---

## Mapa rápido

| Tipo de proyecto | Arquetipo | Stacks |
|---|---|---|
| Servicio backend (API / microservicio / BFF) | [`backend-service/`](backend-service/README.md) | Java · .NET · Node · NestJS · Python |
| Aplicación frontend (SPA / web) | [`frontend-app/`](frontend-app/README.md) | React · Angular · Vue (agnóstico) |
| Migración de librería / runtime | [`library-migration/`](library-migration/README.md) | Cualquier stack |

> Reglas transversales de backend (cross-stack, obligatorias):
> [`backend-service/golden-rules.md`](backend-service/golden-rules.md).

---

## 1. Backend service

Servicios que exponen lógica de negocio o de datos por HTTP. El arquetipo cubre el layering
(API → Application → Domain → Adapters), la configuración por entorno, el contrato de errores,
la resiliencia en llamadas externas, la observabilidad y los tests.

Stacks soportados, cada uno con su `README.md` (estructura + preocupaciones) y `tech-stack.md`
(elecciones concretas de librerías y versiones):

| Stack | Framework de referencia | Carpeta |
|---|---|---|
| Java | Spring Boot 3.x | [`backend-service/java/`](backend-service/java/README.md) |
| .NET | ASP.NET Core (.NET 8) | [`backend-service/dotnet/`](backend-service/dotnet/README.md) |
| Node.js | Express / Fastify | [`backend-service/node/`](backend-service/node/README.md) |
| NestJS | NestJS 10 | [`backend-service/nest/`](backend-service/nest/README.md) |
| Python | FastAPI | [`backend-service/python/`](backend-service/python/README.md) |

---

## 2. Frontend app

Aplicaciones de interfaz (SPA / web). El arquetipo es **agnóstico del framework** (React, Angular,
Vue) y se enfoca en estructura, gestión de estado, consumo de APIs, accesibilidad, performance y
seguridad del lado cliente. Detalle: [`frontend-app/`](frontend-app/README.md).

---

## 3. Library / runtime migration

Migraciones de versión de runtime o de dependencias mayores (ej. upgrade de Node/Java/.NET, o de un
framework a otra versión mayor). El arquetipo define cómo relevar el estado actual, planificar por
etapas, mantener los tests en verde y validar la equivalencia de comportamiento.
Detalle: [`library-migration/`](library-migration/README.md).

---

## Cómo se mantiene

Este catálogo es el **inventario canónico** de arquetipos de Sooft. Si se agrega un stack o tipo de
proyecto nuevo —o se deprecia uno— se actualiza acá y en la subcarpeta correspondiente.
