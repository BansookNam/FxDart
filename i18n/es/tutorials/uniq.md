---
slug: uniq
title: uniq — FxDart 101
description: Tutorial de uniq en FxDart: elimina valores duplicados conservando el orden de primera aparición, con un playground en vivo.
heading: <code>distinct</code>
section: 4
crumb: distinct
prev: compact.html
prevLabel: compact
next: uniqBy.html
nextLabel: uniqBy
---
  <p class="hero-sub">Elimina los valores duplicados, quedándose con la primera aparición de cada uno y conservando el orden.</p>

  {{signature}}

  <h2>Lección</h2>
  <p>
    <code>uniq</code> recorre el iterable una sola vez, manteniendo un
    <code>Set</code> con los valores ya vistos, y emite cada elemento únicamente
    la primera vez que aparece. Está implementado como
    <code>uniqBy((a) =&gt; a, iterable)</code> —con la clave identidad—, así que
    si alguna vez necesitas deduplicar por algo que no sea la igualdad del valor
    completo, recurre a
    <a href="uniqBy.html"><code>uniqBy</code></a> en su lugar.
  </p>
  <p>
    Es perezoso y en streaming: el <code>Set</code> solo crece a medida que se
    piden elementos, así que nunca almacena la fuente entera por adelantado. El
    orden se conserva: lo que sobrevive es la primera aparición de un valor, no
    la última.
  </p>
  <p>
    En el lado asíncrono, <code>uniqAsync</code> se puede combinar sin riesgo con
    <code>.concurrent(n)</code> siempre que la concurrencia viva en una etapa de
    fetch anterior: primero descarga con <code>.map(...).concurrent(n)</code> y
    luego aplica <code>.uniq()</code> a los resultados ya resueltos y en orden,
    como en la Demo 2.
  </p>

  <h2>Demo 1 · Fundamentos</h2>
  {{playground:0}}

  <h2>Demo 2 · Asíncrono, con concurrencia aguas arriba</h2>
  {{playground:1}}

  <h2>Pruébalo tú</h2>
  <p>Ejercicio: usa <code>uniq</code> para eliminar las etiquetas duplicadas,
    conservando el orden de primera aparición.</p>
  {{playground:2}}

  <div class="callout">
    <strong>Relacionado:</strong>
    <a href="uniqBy.html"><code>uniqBy</code></a> — deduplica por una clave calculada ·
    <a href="difference.html"><code>difference</code></a> — elimina los elementos presentes en otro iterable ·
    <a href="intersection.html"><code>intersection</code></a> — conserva solo los elementos comunes ·
    <a href="compact.html"><code>compact</code></a> — descarta los null
  </div>
