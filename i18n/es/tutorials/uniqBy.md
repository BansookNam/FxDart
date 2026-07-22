---
slug: uniqBy
title: uniqBy — FxDart 101
description: Tutorial de uniqBy en FxDart: elimina duplicados según una clave calculada, con un playground en vivo.
heading: <code>distinctBy</code>
section: 4
crumb: distinctBy
prev: uniq.html
prevLabel: uniq
next: difference.html
nextLabel: difference
---
  <p class="hero-sub">Elimina duplicados según lo que determine una función de clave, en lugar de por igualdad de valores.</p>

  {{signature}}

  <h2>Lección</h2>
  <p>
    <code>uniqBy</code> es la forma general de <code>uniq</code>: en vez de
    comparar los elementos enteros, pasa cada elemento por <code>f</code> y
    conserva solo el primer elemento que produce cada clave distinta. Es la
    herramienta para "una fila por cliente", "un evento por tipo" o para
    deduplicar por cualquier campo o valor calculado — el propio
    <code>uniq</code> no es más que
    <code>uniqBy((a) =&gt; a, iterable)</code>.
  </p>
  <p>
    Igual que <code>uniq</code>, es perezoso y conserva el orden: gana el primer
    elemento de cada clave, y el <code>Set&lt;B&gt;</code> interno de claves
    vistas solo crece a medida que tiras de los valores.
  </p>
  <p>
    Aquí aplica la misma regla asíncrona que en <code>uniq</code>: pon la
    concurrencia en un fetch anterior (<code>.map(...).concurrent(n)</code>) y
    luego aplica <code>uniqBy</code>/<code>uniqByAsync</code> al flujo ya
    resuelto y en orden.
  </p>

  <h2>Demo 1 · Fundamentos</h2>
  {{playground:0}}

  <h2>Demo 2 · Asíncrono, con concurrencia aguas arriba</h2>
  {{playground:1}}

  <h2>Pruébalo tú</h2>
  <p>Ejercicio: usa <code>uniqBy</code> para quedarte solo con el primer evento
    de cada <code>'type'</code>.</p>
  {{playground:2}}

  <div class="callout">
    <strong>Relacionado:</strong>
    <a href="uniq.html"><code>uniq</code></a> — deduplica por igualdad de valores ·
    <a href="differenceBy.html"><code>differenceBy</code></a> — elimina por una clave calculada frente a otro iterable ·
    <a href="intersectionBy.html"><code>intersectionBy</code></a> — conserva por una clave calculada compartida con otro iterable ·
    <a href="../tutorials/groupBy.html"><code>groupBy</code></a> — conserva todos los elementos, agrupados por clave
  </div>
