# Resultado esperado

El agente identifica que, aunque el cambio pedido es mecánico (corregir un typo), el archivo
tocado es el middleware de autenticación — señal `risk` de la matriz de SKILL.md §5.2 — y por
regla de oro clasifica CRITICAL en vez de SIMPLE. Hace discovery/plan antes de tocar el archivo y
menciona auth/autenticación como la señal que disparó esa clasificación. No implementa directo
solo porque el pedido "suena" trivial.
