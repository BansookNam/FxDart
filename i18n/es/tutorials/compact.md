---
slug: compact
title: compact — FxDart 101
description: Tutorial de compact en FxDart: descarta los null y estrecha el tipo del elemento, con un playground en vivo.
heading: <code>compact</code>
section: 4
crumb: compact
prev: reject.html
prevLabel: reject
next: uniq.html
nextLabel: uniq
---
  <p class="hero-sub">Filtra los null y, a la vez, estrecha el tipo del elemento de <code>T?</code> a <code>T</code>.</p>

  {{signature}}

  <h2>Lección</h2>
  <p>
    <code>compact</code> toma un <code>Iterable&lt;A?&gt;</code> y
    devuelve un <code>Iterable&lt;A&gt;</code> — cada <code>null</code>
    desaparece, y el verificador de tipos lo sabe: nada de lo que venga
    después necesita ya comprobar null. Este es el equivalente en FxDart del
    <code>compact</code> de FxTS, que descarta los seis valores falsy de JS
    (<code>undefined</code>, <code>null</code>, <code>0</code>,
    <code>''</code>, <code>NaN</code>, <code>false</code>). Dart no tiene un
    concepto único de "falsy", así que el port solo elimina <code>null</code> —
    un comportamiento deliberadamente más estrecho y fácil de razonar.
  </p>
  <p>
    Aparece constantemente después de <a href="pluck.html"><code>pluck</code></a>
    o de cualquier búsqueda que devuelva <code>T?</code>: <code>compact(pluck(key, records))</code>
    te da una lista limpia y no nullable en un solo paso.
  </p>
  <p>
    <strong>No hay método de cadena</strong> para <code>compact</code> —
    solo existen la función de nivel superior data-first y su contraparte asíncrona.
    Llámala directamente, o envuelve el resultado con <code>fx(...)</code> /
    <code>fxAsync(...)</code> para seguir encadenando.
  </p>

  <h2>Demo 1 · Fundamentos &amp; estrechamiento de tipos</h2>
  {{playground:0}}

  <h2>Demo 2 · Asíncrono, con concurrencia</h2>
  {{playground:1}}

  <h2>Pruébalo tú</h2>
  <p>Ejercicio: usa <code>compact</code> para descartar los null de
    <code>answers</code>.</p>
  {{playground:2}}

  <div class="callout">
    <strong>Relacionado:</strong>
    <a href="pluck.html"><code>pluck</code></a> — una fuente habitual de valores nullable ·
    <a href="reject.html"><code>reject</code></a> — descarta según un predicado cualquiera ·
    <a href="../tutorials/compactObject.html"><code>compactObject</code></a> — el equivalente para Map ·
    <a href="uniq.html"><code>uniq</code></a> — elimina duplicados
  </div>
