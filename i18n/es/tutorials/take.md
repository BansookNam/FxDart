---
slug: take
title: take — FxDart 101
description: Tutorial de take en FxDart: toma los primeros n valores de cualquier pipeline perezoso, incluso de uno infinito, con un playground en vivo.
heading: <code>take</code>
section: 5
crumb: take
prev: compress.html
prevLabel: compress
next: takeRight.html
nextLabel: takeRight
---
  <p class="hero-sub">Devuelve un iterable perezoso con los primeros <code>length</code> valores de una fuente.</p>

  {{signature}}

  <h2>Lección</h2>
  <p>
    <code>take</code> es lo que mantiene finito a un pipeline perezoso. Deja de
    pedir valores a su fuente en cuanto ha emitido <code>length</code> valores:
    aguas arriba nunca recibe más peticiones que esas. Dado que fuentes de
    FxDart como <code>range</code>, <code>repeat</code> y <code>cycle</code>
    pueden ser infinitas, muchas veces <code>take</code> es lo único que hace
    que un pipeline sea seguro de ejecutar.
  </p>
  <p>
    Viene como función data-first (<code>take(n, iterable)</code>) y como método
    de cadena (<code>fx(iterable).take(n)</code>). En el lado asíncrono,
    <code>takeAsync</code>/<code>.take()</code> es transparente: no serializa lo
    que hay aguas arriba, así que un <code>concurrent(n)</code> más arriba en la
    cadena sigue solapando sus peticiones hasta que <code>take</code> tiene lo
    que necesita.
  </p>

  <h2>Demo 1 · Fundamentos, y tomar de una fuente infinita</h2>
  <p><code>cycle</code> repite su entrada para siempre; sin
    <code>take</code>, iterarlo no terminaría nunca:</p>
  {{playground:0}}

  <h2>Demo 2 · Asíncrono, y sigue solapando bajo concurrent</h2>
  <p>
    Aquí solo se piden 4 valores, pero el <code>concurrent(3)</code> de aguas
    arriba los sigue evaluando de 3 en 3 — <code>take</code> no obliga a que
    todo sea secuencial:
  </p>
  {{playground:1}}

  <h2>Pruébalo tú</h2>
  <p>Ejercicio: toma solo los 3 primeros nombres de la cola.</p>
  {{playground:2}}

  <div class="callout">
    <strong>Relacionado:</strong>
    <a href="takeRight.html"><code>takeRight</code></a> — los últimos n en vez de los primeros n ·
    <a href="takeWhile.html"><code>takeWhile</code></a> — tomar según un predicado ·
    <a href="range.html"><code>range</code></a> · <a href="cycle.html"><code>cycle</code></a> — fuentes infinitas ·
    <a href="concurrent.html"><code>concurrent</code></a> — evaluación en paralelo
  </div>
