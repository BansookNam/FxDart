---
slug: takeRight
title: takeRight — FxDart 101
description: Tutorial de takeRight en FxDart: quédate solo con los últimos n valores de un iterable finito, con un playground en vivo.
heading: <code>takeRight</code>
section: 5
crumb: takeRight
prev: take.html
prevLabel: take
next: takeWhile.html
nextLabel: takeWhile
---
  <p class="hero-sub">Devuelve un iterable perezoso con los últimos <code>length</code> valores de una fuente.</p>

  {{signature}}

  <h2>Lección</h2>
  <p>
    <code>takeRight</code> es la imagen especular de <code>take</code>: en lugar
    de los primeros <code>length</code> valores, obtienes los últimos. Pero hay
    una pega: para saber cuáles son los «últimos», <code>takeRight</code> tiene que
    ver antes todos los elementos. Internamente <strong>materializa</strong> la
    fuente entera en una lista antes de emitir nada, así que, a diferencia de la
    mayoría de operadores de FxDart, no funciona sobre secuencias infinitas.
  </p>
  <p>
    La versión asíncrona tiene la misma restricción: <code>takeRightAsync</code>
    vacía todo lo que hay aguas arriba (esperando cada elemento) antes de poder
    devolver la cola. Úsalo solo cuando sepas que la fuente es finita y lo
    bastante pequeña como para almacenarla en memoria.
  </p>

  <h2>Demo 1 · Fundamentos</h2>
  {{playground:0}}

  <h2>Demo 2 · Asíncrono (primero hay que almacenar toda la fuente en memoria)</h2>
  {{playground:1}}

  <h2>Pruébalo tú</h2>
  <p>Ejercicio: quédate solo con las últimas 3 puntuaciones.</p>
  {{playground:2}}

  <div class="callout">
    <strong>Relacionado:</strong>
    <a href="take.html"><code>take</code></a> — los primeros n en vez de los últimos n ·
    <a href="dropRight.html"><code>dropRight</code></a> — descarta los últimos n ·
    <a href="reverse.html"><code>reverse</code></a> — también materializa la fuente ·
    <a href="slice.html"><code>slice</code></a> — una ventana de índices arbitraria
  </div>
