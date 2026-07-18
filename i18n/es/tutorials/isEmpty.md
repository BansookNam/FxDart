---
slug: isEmpty
title: isEmpty — FxDart 101
description: Tutorial de isEmpty en FxDart: una comprobación de vacío basada en el valor para null, cadenas y colecciones, usable como predicado en filtros.
heading: <code>isEmpty</code>
section: 8
crumb: isEmpty
prev: includes.html
prevLabel: includes
next: every.html
nextLabel: every
---
  <p class="hero-sub">Una comprobación de vacío basada en el valor: true para <code>null</code>, <code>''</code> y colecciones vacías.</p>

  {{signature}}

  <h2>Lección</h2>
  <p>
    Esto <strong>no</strong> es lo mismo que <code>Iterable.isEmpty</code>,
    el getter que ya tienes gratis en cualquier <code>List</code>, <code>Set</code>
    o cadena <code>Fx</code>. Ese getter solo existe en los iterables, y revienta
    (o sencillamente no está disponible) con <code>null</code>. El <code>isEmpty</code>
    de FxTS acepta <em>cualquier</em> valor y responde a una pregunta más amplia:
    ¿esto es "nada" en un sentido práctico? Devuelve <code>true</code> para
    <code>null</code>, un <code>String</code> vacío y un
    <code>Iterable</code>/<code>Map</code>/<code>Set</code> vacío — y
    <code>false</code> para todo lo demás, incluidos números y booleanos,
    que nunca se consideran "vacíos".
  </p>
  <p>
    Como recibe un único argumento <code>Object?</code>, se pasa directamente
    como tear-off a <code>filter</code>, <code>reject</code> o cualquier otro
    hueco con forma de predicado, sin necesidad de una lambda envolvente.
  </p>

  <h2>Demo 1 · Fundamentos</h2>
  {{playground:0}}

  <h2>Demo 2 · Como tear-off listo para filtrar</h2>
  <p>
    Una mezcla variada de valores, reducida a los que <code>isEmpty</code> considera vacíos
    (la cadena vacía impresa aparece como nada entre las comas):
  </p>
  {{playground:1}}

  <h2>Pruébalo tú</h2>
  <p>Ejercicio: usa <code>isEmpty</code> para imprimir <code>'no comment'</code> cuando <code>comment</code> esté vacío, o el propio comentario.</p>
  {{playground:2}}

  <div class="callout">
    <strong>Relacionado:</strong>
    <a href="compact.html"><code>compact</code></a> — descarta los null de un iterable ·
    <a href="compactObject.html"><code>compactObject</code></a> — descarta los null de un Map ·
    <a href="predicates.html"><code>predicates</code></a> — más comprobaciones de tipo listas para filtrar ·
    <a href="includes.html"><code>includes</code></a> — la comprobación de pertenencia vecina
  </div>
