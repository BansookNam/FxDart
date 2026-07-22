---
slug: zipWithIndex
title: zipWithIndex — FxDart 101
description: Tutorial de zipWithIndex en FxDart: empareja cada elemento con su índice (empezando en 0), con playground en vivo.
heading: <code>indexed</code>
section: 6
crumb: indexed
prev: zipWith.html
prevLabel: zipWith
next: transpose.html
nextLabel: transpose
---
  <p class="hero-sub">Empareja cada elemento con su índice (empezando en 0): <code>(index, value)</code>.</p>

  {{signature}}

  <h2>Lección</h2>
  <p>
    <code>zipWithIndex</code> es un <code>zip</code> contra un contador
    implícito: cada elemento sale emparejado como <code>(index, value)</code>,
    contando desde <code>0</code>. Es la respuesta del pipeline perezoso al
    bucle manual <code>for (var i = 0; i &lt; list.length; i++)</code>: sin
    variable contador que gestionar, y se compone con el resto de la cadena.
  </p>
  <p>
    Como solo necesita llevar la cuenta de un contador, <code>zipWithIndex</code>
    sigue siendo perezoso y funciona igual de bien sobre una fuente infinita que
    sobre una finita; la versión asíncrona cuenta igual a medida que se resuelven los elementos.
  </p>

  <h2>Demo 1 · Fundamentos</h2>
  {{playground:0}}

  <h2>Demo 2 · Asíncrono</h2>
  {{playground:1}}

  <h2>Pruébalo tú</h2>
  <p>Ejercicio: empareja a cada corredor con su posición de llegada (empezando en 0).</p>
  {{playground:2}}

  <div class="callout">
    <strong>Relacionado:</strong>
    <a href="zip.html"><code>zip</code></a> — empareja dos iterables entre sí ·
    <a href="zipWith.html"><code>zipWith</code></a> — hace zip y combina en un solo paso ·
    <a href="entries.html"><code>entries</code></a> — empareja las claves de un Map con sus valores
  </div>
