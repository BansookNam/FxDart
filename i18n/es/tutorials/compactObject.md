---
slug: compactObject
title: compactObject — FxDart 101
description: Tutorial de compactObject en FxDart: elimina de forma superficial las claves con valor null de un Map.
heading: <code>compactObject</code>
section: 9
crumb: compactObject
prev: evolve.html
prevLabel: evolve
next: resolveProps.html
nextLabel: resolveProps
---
  <p class="hero-sub">Devuelve una copia de un <code>Map</code> sin las claves cuyo valor es <code>null</code> — con un solo nivel de profundidad.</p>

  {{signature}}

  <h2>Lección</h2>
  <p>
    <code>compactObject</code> es la contraparte para <code>Map</code> de
    <a href="compact.html"><code>compact</code></a> (que quita los
    <code>null</code> de un <code>Iterable</code>). Viene muy bien para
    limpiar un formulario o un registro parcialmente relleno antes de
    serializarlo: descarta los campos que nadie rellenó y conserva el resto.
  </p>
  <p>
    La limpieza es <strong>superficial</strong>: solo inspecciona los valores
    del nivel superior. Un <code>null</code> anidado dos niveles más abajo,
    dentro de un valor que a su vez es un <code>Map</code>, se queda
    intacto. Si necesitas una limpieza recursiva, tendrás que escribir esa
    pasada tú mismo (o volver a llamar a <code>compactObject</code> sobre el
    mapa anidado antes de montar el exterior).
  </p>

  <h2>Demo 1 · Fundamentos</h2>
  {{playground:0}}

  <h2>Demo 2 · La prueba de que es superficial</h2>
  {{playground:1}}

  <h2>Pruébalo tú</h2>
  <p>Ejercicio: usa <code>compactObject</code> para descartar las claves con valor null de <code>draft</code>.</p>
  {{playground:2}}

  <div class="callout">
    <strong>Relacionado:</strong>
    <a href="compact.html"><code>compact</code></a> — la versión para <code>Iterable</code> ·
    <a href="isEmpty.html"><code>isEmpty</code></a> — una comprobación relacionada basada en el valor ·
    <a href="omitBy.html"><code>omitBy</code></a> — la versión general con predicado que esta especializa ·
    <a href="evolve.html"><code>evolve</code></a> — transforma los valores en lugar de descartarlos
  </div>
