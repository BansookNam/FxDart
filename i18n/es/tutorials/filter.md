---
slug: filter
title: filter — FxDart 101
description: Tutorial de filter en FxDart: conserva solo los elementos que acepta un predicado, en versión síncrona y asíncrona, con un playground en vivo.
heading: <code>where</code>
section: 4
crumb: where
prev: pluck.html
prevLabel: pluck
next: reject.html
nextLabel: reject
---
  <p class="hero-sub">Devuelve un iterable perezoso con los elementos para los que el predicado devuelve true.</p>

  {{signature}}

  <h2>Lección</h2>
  <p>
    <code>filter</code> es el otro transformador fundamental junto a
    <code>map</code>: conserva todos los elementos para los que el predicado
    devuelve <code>true</code> y descarta el resto, de forma perezosa. No se
    ejecuta nada hasta que un operador terminal tira de los valores y, como
    <code>Fx</code> extiende <code>Iterable</code>, <code>.where(...)</code>
    también funciona — no es más que un alias de <code>.filter(...)</code> en
    la cadena.
  </p>
  <p>
    Al ser perezoso, combinar <code>filter</code> con <code>take</code>
    evalúa solo las llamadas al predicado necesarias para satisfacer el
    <code>take</code> — mira la Demo 1.
  </p>
  <p>
    <code>filterAsync</code> tiene su propia implementación concurrente
    (en vez de reutilizar la de <code>mapAsync</code>): cuando le añades
    <code>.concurrent(n)</code>, se evalúan <code>n</code> predicados en
    paralelo, pero los elementos que pasan se emiten aguas abajo en su orden
    original — la concurrencia cambia el rendimiento, nunca el resultado.
  </p>

  <h2>Demo 1 · Fundamentos &amp; pereza</h2>
  {{playground:0}}

  <h2>Demo 2 · Asíncrono, con concurrencia</h2>
  {{playground:1}}

  <h2>Pruébalo tú</h2>
  <p>Ejercicio: usa <code>filter</code> para conservar solo las edades de 18 en adelante.</p>
  {{playground:2}}

  <div class="callout">
    <strong>Relacionado:</strong>
    <a href="reject.html"><code>reject</code></a> — lo contrario de filter ·
    <a href="compact.html"><code>compact</code></a> — descarta los null ·
    <a href="map.html"><code>map</code></a> — transforma en vez de conservar/descartar ·
    <a href="concurrent.html"><code>concurrent</code></a> — evaluación en paralelo
  </div>
