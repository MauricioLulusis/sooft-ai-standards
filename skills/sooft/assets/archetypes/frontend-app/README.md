# Arquetipo — Frontend app (Sooft)

Guía de referencia para construir **aplicaciones frontend** (SPA / web) en Sooft Technology.
Es **agnóstica del framework**: los principios valen para React, Angular o Vue, y cada equipo
elige el suyo. Se apoya en herramientas **estándar del mercado**, sin librerías internas.

> Alineada con prácticas de frontend vigentes a **2026** y con el ciclo **SDLC** + enfoque
> **SDD** de Sooft. Para las reglas de calidad y seguridad que comparte con backend, ver también
> [`../backend-service/golden-rules.md`](../backend-service/golden-rules.md).

## Cuándo usar este arquetipo

- SPA o aplicación web que consume APIs (dashboards, portales, back-offices, productos).
- Micro-frontend o módulo dentro de una app mayor.

## Stack de referencia (elegí uno)

| Framework | Cuándo | Herramientas típicas |
|---|---|---|
| **React** | Ecosistema amplio, equipos JS/TS | Vite, React Router, TanStack Query, Zustand/Redux Toolkit |
| **Angular** | App grande y opinada, equipos que quieren batteries-included | Angular CLI, RxJS, Signals |
| **Vue** | Curva suave, productividad | Vite, Vue Router, Pinia |

Transversal a todos: **TypeScript**, **Vite** (o el bundler del framework), testing con
**Vitest/Jest + Testing Library**, y **Playwright/Cypress** para e2e.

## Estructura recomendada (agnóstica)

```
src/
  app/            → bootstrap, router, providers globales
  pages/ (o views)→ pantallas / rutas
  features/       → módulos por dominio (componentes + estado + hooks/servicios del feature)
  components/     → componentes de UI reutilizables (design system local o wrappers)
  lib/            → utilidades, cliente HTTP, helpers
  hooks/          → hooks reutilizables (React) / composables (Vue)
  services/       → acceso a APIs (una capa, no fetch suelto en componentes)
  config/         → configuración por entorno (variables VITE_*/NG/…)
```

## Preocupaciones transversales

| Preocupación | Cómo |
|---|---|
| Estado del servidor | Data-fetching con cache (TanStack Query / RTK Query / Pinia colada). No recargar a mano lo que la lib ya cachea. |
| Estado del cliente | Store liviano (Zustand/Pinia/Signals) solo para estado realmente global. Evitar overengineering. |
| Consumo de API | Una capa `services/` con un cliente HTTP configurado (base URL, timeouts, manejo de errores, auth). Nunca `fetch` crudo esparcido. |
| Config | Por variables de entorno del bundler (`VITE_*`, etc.), nunca secretos en el bundle. |
| Errores | Error boundaries + manejo consistente; no exponer detalles internos en el DOM. |
| Accesibilidad | **WCAG 2.1 AA** como piso: roles/ARIA correctos, foco manejable, contraste ≥ 4.5:1, operable por teclado. |
| Performance | Code-splitting por ruta, lazy loading, presupuesto de bundle, imágenes optimizadas, Core Web Vitals. |
| Seguridad | Sin secretos en el cliente, escape/sanitización (anti-XSS), CSP, tokens en storage seguro, dependencias sin CVEs. |
| i18n | Externalizar textos si el producto lo requiere. |
| Tests | Unit + componente (Testing Library), e2e de los flujos críticos (Playwright/Cypress), accesibilidad automatizada (axe-core). |

## Cómo lo usa el agente

En el **discovery**, el agente detecta el framework del repo y aplica esta guía para proponer
estructura, capa de servicios, gestión de estado y criterios de accesibilidad/performance. No
asume un design system: si hay uno propio del proyecto, lo usa; si no, propone componentes
estándar. Los criterios de aceptación visuales y de accesibilidad se definen en la SPEC (SDD).
