---
slug: findIndex
title: findIndex — FxDart 101
description: Tutorial de findIndex en FxDart: obtén la posición de la primera coincidencia, o -1 si no hay ninguna, de forma perezosa y con cortocircuito.
heading: <code>findIndex</code>
section: 8
crumb: findIndex
prev: find.html
prevLabel: find
next: includes.html
nextLabel: includes
---
  <p class="hero-sub">Devuelve el índice del primer elemento para el que el predicado es cierto, o <code>-1</code>.</p>

  {{signature}}

  <h2>Lección</h2>
  <p>
    <code>findIndex</code> es el hermano de <code>find</code>: el mismo
    recorrido perezoso y con cortocircuito, pero informa de <em>dónde</em>
    estaba la coincidencia en vez de la coincidencia en sí. Fíjate en el
    valor centinela distinto para "no encontrado" — aquí es <code>-1</code>,
    un <code>int</code>, igual que el <code>Array.prototype.findIndex</code>
    de JavaScript. Es un contraste deliberado con
    <code>head</code>/<code>find</code>/<code>nth</code>, que todos usan
    <code>null</code>: un índice tiene un valor "imposible" natural, así que
    FxDart mantiene aquí la convención de FxTS en lugar de inventarse un tipo
    de retorno <code>int?</code>.
  </p>
  <p>
    Por dentro empareja cada elemento con su índice (mediante <code>zipWithIndex</code>)
    y se detiene en el primero que pasa <code>f</code>.
  </p>

  <h2>Demo 1 · Fundamentos</h2>
  {{playground:0}}

  <h2>Demo 2 · Cortocircuito &amp; asíncrono</h2>
  {{playground:1}}

  <h2>Pruébalo tú</h2>
  <p>Ejercicio: usa <code>findIndex</code> para encontrar la posición de bob en la cola, o <code>-1</code>.</p>
  {{playground:2}}

  <div class="callout">
    <strong>Relacionado:</strong>
    <a href="find.html"><code>find</code></a> — la misma búsqueda, pero devuelve el valor ·
    <a href="includes.html"><code>includes</code></a> — solo "¿está o no?" ·
    <a href="nth.html"><code>nth</code></a> — el inverso: entra un índice, sale un valor ·
    <a href="zipWithIndex.html"><code>zipWithIndex</code></a> — lo que lo hace funcionar por dentro
  </div>
