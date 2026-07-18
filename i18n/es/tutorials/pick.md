---
slug: pick
title: pick — FxDart 101
description: Tutorial de pick en FxDart: devuelve una copia de un Map solo con las claves indicadas; las que no existan simplemente no aparecen.
heading: <code>pick</code>
section: 9
crumb: pick
prev: omit.html
prevLabel: omit
next: omitBy.html
nextLabel: omitBy
---
  <p class="hero-sub">Devuelve una copia de un <code>Map</code> solo con las claves indicadas.</p>

  {{signature}}

  <h2>Lección</h2>
  <p>
    <code>pick</code> es el espejo de <code>omit</code>: en vez de enumerar
    qué quitar, enumeras qué conservar. Las claves que pidas y no estén en el
    map de origen simplemente no aparecen en el resultado —
    <code>pick</code> no las inserta con un <code>null</code> de relleno, así
    que el conjunto de claves del resultado puede ser menor que
    <code>keysToPick</code>.
  </p>
  <p>
    Recurre a él cuando quieras una "vista" reducida de un map más grande:
    una respuesta de API pública derivada de un registro interno, una fila
    resumen derivada de una completa, y así sucesivamente.
  </p>

  <h2>Demo 1 · Fundamentos</h2>
  {{playground:0}}

  <h2>Demo 2 · Adelgazar una lista entera</h2>
  {{playground:1}}

  <h2>Pruébalo tú</h2>
  <p>Ejercicio: usa <code>pick</code> para conservar solo <code>'id'</code> y <code>'email'</code> de <code>profile</code>.</p>
  {{playground:2}}

  <div class="callout">
    <strong>Relacionado:</strong>
    <a href="omit.html"><code>omit</code></a> — el inverso: descartar solo algunas claves ·
    <a href="pickBy.html"><code>pickBy</code></a> — conservar según un predicado en lugar de una lista de claves ·
    <a href="props.html"><code>props</code></a> — extraer varios valores como una List ·
    <a href="prop.html"><code>prop</code></a> — extraer un único valor
  </div>
