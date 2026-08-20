# SOOFT · Sitio de overview (HTML)

Sitio estático de **una sola página** que explica **SOOFT** (Sooft Engineering AI Rails): qué es,
cómo se inserta en el SDLC de Sooft, cómo está armado por dentro, el proceso de instalación
completo, preguntas frecuentes y el monitor de tareas. Pensado para que un developer o alguien de
más alto nivel entienda la propuesta y la arquitectura **de un vistazo**, sin leer archivo por
archivo.

## Cómo verlo

Es un sitio estático de un solo archivo: abrí `index.html` en cualquier navegador (doble click) y
navegá con la barra superior (ancla dentro de la misma página, no hay archivos separados).

```powershell
# desde la raíz del repo
start sooft-overview/index.html
```

> La sección **Doc. técnica** usa [Mermaid](https://mermaid.js.org/) desde CDN para los diagramas,
> así que esa parte necesita conexión en la primera carga. Todo el resto (HTML/CSS/JS) es 100%
> local y va embebido en el archivo — incluida la lógica del **Monitor**.

## Estructura

```
sooft-overview/
├── index.html   # Sitio único: Home · Estrategia · Doc. técnica · FAQ · Monitor · Instalación
└── README.md    # este archivo
```

### Navegación

Una sola barra superior para todo el sitio, con anclas a las secciones:

`Home · Estrategia · Doc. técnica · FAQ · Monitor` (+ `Instalar` → sección Instalación del Home)

El toggle de tema (claro/oscuro) se persiste en `localStorage` (`sooft-theme`).
Por defecto arranca en **oscuro**.

## Secciones

- **Home** — qué es SOOFT, cómo se usa, y la sección **Instalación** con las 3 formas reales de
  arrancar (CLI `sooft`, `npx skills add`, o sin instalar nada).
- **Estrategia** — dónde encaja SOOFT dentro del SDLC de Sooft (E1–E6, con foco hoy en E3).
- **Doc. técnica** — arquitectura, estructura de carpetas, las 8 skills, las 10 primitivas
  internas, assets (incluido el hook de sesión agnóstico a la herramienta), los 5 gates, la
  máquina de estados (con la rama de rigor DIRECT/LEAN/FULL) y el enrutamiento de
  modelos/subagentes.
- **FAQ** — preguntas frecuentes en formato acordeón.
- **Monitor** — monitor de tareas en vivo (File System Access API + IndexedDB); requiere un
  navegador basado en Chromium (Chrome / Edge). Conectás la carpeta del proyecto una vez; el
  handle persiste entre recargas.

## Mantenimiento

El contenido está hardcodeado a partir de la fuente de verdad (`skills/sooft/SKILL.md`,
`skills/sooft/workflow.yml` y `AGENTS.md`). Si cambia la estructura de skills, el enrutamiento de
modelos, los gates o la máquina de estados, actualizá las secciones correspondientes de
`index.html` — sobre todo **Doc. técnica**. Este sitio es un **mapa**, no reemplaza la
constitución.
