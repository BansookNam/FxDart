---
slug: uniqStrict
title: uniqStrict — FxDart 101
description: Tutorial de uniqStrict en FxDart: deduplica de forma inmediata en una List en lugar de perezosamente, y cuándo compensa ese cambio, con un playground en vivo.
heading: <code>uniqStrict</code>
section: 4
crumb: uniqStrict
prev: uniqBy.html
prevLabel: distinctBy
next: uniqAdjacent.html
nextLabel: uniqAdjacent
---
  <p class="hero-sub">Deduplica el iterable entero de inmediato y devuelve una <code>List</code>: la contraparte estricta de <code>distinct</code>.</p>

  {{signature}}

  <h2>Lección</h2>
  <p>
    <code>uniqStrict</code> produce exactamente los mismos elementos, en el mismo
    orden, que <a href="uniq.html"><code>distinct</code></a> seguido de
    <code>toList()</code>. Lo que cambia es <em>cuándo</em> ocurre el trabajo y
    quién puede detenerlo. <code>uniqByStrict</code> hace el mismo trato para
    <a href="uniqBy.html"><code>distinctBy</code></a>: deduplicar por una clave
    calculada, de forma inmediata.
  </p>
  <p>
    Una cadena perezosa vuelve a ejecutar su origen en cada recorrido. Recorre
    <code>distinct(...)</code> dos veces y la fuente se recorre dos veces. La
    forma estricta la recorre una sola vez, en la llamada, y te entrega una
    <code>List</code>: así, un resultado que vas a indexar, medir o recorrer más
    de una vez te cuesta una pasada en lugar de <em>n</em>. La Demo 2 cuenta las
    llamadas al callback para hacerlo evidente.
  </p>
  <p>
    El precio es que nada aguas abajo puede interrumpir el trabajo.
    <code>distinct(xs).take(3)</code> deja de tirar de <code>xs</code> en cuanto
    han aparecido 3 valores distintos; <code>uniqStrict(xs).take(3)</code>
    deduplica todo <code>xs</code> primero y luego toma 3. Nunca pongas la forma
    estricta delante de un consumidor que corta pronto, y nunca la apuntes a un
    iterable infinito: no terminará.
  </p>
  <div class="callout">
    <strong>Por defecto, perezoso.</strong> <code>distinct(...).toList()</code> ya
    ejecuta la deduplicación y la acumulación en una sola pasada, así que no
    estás pagando por la pereza. Recurre a <code>uniqStrict</code> solo cuando la
    <code>List</code> deduplicada sea en sí misma lo que quieres, o cuando se
    recorra más de una vez.
  </div>

  <h2>Demo 1 · Lo básico</h2>
  {{playground:0}}

  <h2>Demo 2 · Cuándo compensa y qué cuesta</h2>
  {{playground:1}}

  <h2>Pruébalo tú</h2>
  <p>Ejercicio: usa <code>uniqByStrict</code> para quedarte con la primera visita
    de cada visitante, como una <code>List</code> que puedas indexar sin volver a
    recorrerla.</p>
  {{playground:2}}

  <div class="callout">
    <strong>Relacionados:</strong>
    <a href="uniq.html"><code>distinct</code></a> — el valor por defecto, perezoso ·
    <a href="uniqBy.html"><code>distinctBy</code></a> — deduplicar por una clave calculada ·
    <a href="uniqAdjacent.html"><code>uniqAdjacent</code></a> — quitar solo duplicados adyacentes ·
    <a href="toList.html"><code>toList</code></a> — materializar cualquier cadena
  </div>
