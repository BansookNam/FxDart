---
slug: juxt
title: juxt — FxDart 101
description: Tutorial de juxt en FxDart: aplica varias funciones al mismo valor y recoge todos los resultados, con un playground en vivo.
heading: <code>juxt</code>
section: 10
crumb: juxt
prev: apply.html
prevLabel: apply
next: memoize.html
nextLabel: memoize
---
  <p class="hero-sub">Aplica todas las funciones de una lista al mismo valor y recoge los resultados.</p>

  {{signature}}

  <h2>Lección</h2>
  <p>
    Dale a <code>juxt</code> una lista de funciones que acepten todas la misma
    entrada, y te devuelve una única función que pasa esa entrada por cada una
    de ellas y devuelve una <code>List</code> con los resultados, en
    orden. Es una forma compacta de calcular varias vistas independientes de un
    mismo valor sin repetirte.
  </p>
  <p>
    El <code>juxt</code> de FxTS es variádico y admite funciones con
    distinto número de argumentos. Dart no tiene genéricos variádicos, así que la
    versión de FxDart toma una sola función unaria <code>T -&gt; R</code> por entrada
    — suficiente para cubrir el caso habitual de "aplica estas N proyecciones de
    solo lectura a este valor".
  </p>

  <h2>Demo 1 · Fundamentos</h2>
  <p>El ejemplo clásico del dartdoc: calcular el mínimo y el máximo de una
    lista en una sola pasada:</p>
  {{playground:0}}

  <h2>Demo 2 · Proyectar varios campos</h2>
  <p>Extraer varios campos de un <code>Map</code> con forma de registro de una vez:</p>
  {{playground:1}}

  <h2>Pruébalo tú</h2>
  <p>Ejercicio: usa <code>juxt</code> para calcular <code>sum</code> y
    <code>average</code> de esta lista en una sola pasada.</p>
  {{playground:2}}

  <div class="callout">
    <strong>Relacionado:</strong>
    <a href="apply.html"><code>apply</code></a> — llama a una función con una lista de argumentos dinámica ·
    <a href="cases.html"><code>cases</code></a> — elige una función según un predicado en vez de ejecutarlas todas ·
    <a href="min.html"><code>min</code></a> / <a href="max.html"><code>max</code></a> — usadas juntas en la demo de arriba ·
    <a href="zip.html"><code>zip</code></a> — combina valores de dos secuencias en vez de una
  </div>
