---
slug: props
title: props — FxDart 101
description: Tutorial de props en FxDart: lee varias claves de un Map a la vez como List; las claves ausentes quedan en null.
heading: <code>props</code>
section: 9
crumb: props
prev: prop.html
prevLabel: prop
next: evolve.html
nextLabel: evolve
---
  <p class="hero-sub">Devuelve los valores de varias claves de un <code>Map</code>, como una <code>List</code>.</p>

  {{signature}}

  <h2>Lección</h2>
  <p>
    <code>props</code> es <code>prop</code> aplicado a varias claves a la vez y
    en orden: le pasas una lista de claves y un mapa, y recibes una
    <code>List&lt;V?&gt;</code> con una posición por cada clave pedida. A
    diferencia de <a href="pick.html"><code>pick</code></a>, una clave que
    falta no se descarta del resultado: queda como <code>null</code> en esa
    posición, así que la <code>List</code> de salida siempre tiene la misma
    longitud que <code>propKeys</code>. Esa garantía posicional es lo que la
    hace encajar tan bien con el patrón de desestructuración de listas de Dart.
  </p>

  <h2>Demo 1 · Fundamentos</h2>
  {{playground:0}}

  <h2>Demo 2 · Desestructurar el resultado</h2>
  {{playground:1}}

  <h2>Pruébalo tú</h2>
  <p>Ejercicio: usa <code>props</code> para sacar <code>['first', 'last']</code> de <code>row</code> como una <code>List</code>.</p>
  {{playground:2}}

  <div class="callout">
    <strong>Relacionado:</strong>
    <a href="prop.html"><code>prop</code></a> — una sola clave cada vez ·
    <a href="pick.html"><code>pick</code></a> — el equivalente con forma de Map ·
    <a href="fromEntries.html"><code>fromEntries</code></a> — reconstruye un Map ·
    <a href="evolve.html"><code>evolve</code></a> — transforma valores concretos in situ
  </div>
