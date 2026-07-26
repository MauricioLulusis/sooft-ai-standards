# SOOFT · Sitio de overview (HTML)

Sitio estático multipágina que explica **SOOFT** (Sooft Engineering AI Rails): qué es,
cómo se inserta en el SDLC de Sooft, cómo está armado por dentro, preguntas frecuentes
y el monitor de tareas. Pensado para que un developer o alguien de más alto nivel entienda
la propuesta y la arquitectura **de un vistazo**, sin leer archivo por archivo.

## Cómo verlo

Es un sitio estático: abrí `sooft.html` en cualquier navegador (doble click) y navegá
desde la barra superior.

```powershell
# desde la raíz del repo
start sooft-overview/sooft.html
```

> Solo `documentacion-tecnica.html` usa [Mermaid](https://mermaid.js.org/) desde CDN para los
> diagramas, así que esa página necesita conexión en la primera carga. Todo el resto
> (HTML/CSS/JS) es 100% local y va embebido en cada archivo.

## Estructura

```
sooft-overview/
├── sooft.html           # Home — landing / entrada principal
├── estrategia.html     # SOOFT dentro del SDLC de Sooft (etapas E1–E6, E3 activa)
├── documentacion-tecnica.html  # Doc. técnica (sidebar sticky + diagramas Mermaid)
├── faq.html            # Preguntas frecuentes (acordeón)
├── monitor.html        # Monitor de tareas en vivo (File System Access API)
├── assets/             # recursos compartidos (si aplica)
└── README.md           # este archivo
```

### Navegación

Todas las páginas comparten la misma barra superior:

`Home · Estrategia · Doc. técnica · FAQ · Monitor`

El toggle de tema (claro/oscuro) se persiste en `localStorage` (`sooft-theme`) y se
comparte entre todas las páginas. Por defecto arranca en **oscuro**.

## Estado / pendientes

- `sooft.html`: el bloque de video queda como placeholder hasta tener los videos (la idea
  es varios videos cortos con navegación por flechas).
- `monitor.html`: monitor en vivo (File System Access API + IndexedDB); requiere un
  navegador basado en Chromium (Chrome / Edge).

## Mantenimiento

El contenido está hardcodeado en cada HTML a partir de la fuente de verdad
(`skills/sooft/SKILL.md` y `AGENTS.md`). Si cambia la estructura de skills, skills internas,
assets o gates, actualizá las secciones correspondientes de `documentacion-tecnica.html`. Estas
páginas son un **mapa**, no reemplazan la constitución.
