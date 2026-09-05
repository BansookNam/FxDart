---
slug: mapConcurrent
title: mapConcurrent — FxDart 101
description: Tutorial de mapConcurrent en FxDart — mapear con límite de concurrencia en un solo paso, toAsync, map y concurrent precombinados. Con playground en vivo.
heading: <code>mapConcurrent</code>
section: 11
crumb: mapConcurrent
prev: concurrent.html
prevLabel: concurrent
next: concurrentPool.html
nextLabel: concurrentPool
---
  <p class="hero-sub">Mapear con límite de concurrencia en un solo paso — <code>toAsync().map(f).concurrent(n)</code>, precombinado.</p>

  {{signature}}

  <h2>Lección</h2>
  <p>
    «Corre esta función async sobre estos valores, como mucho <em>n</em> a
    la vez, resultados en orden» es el pipeline async más común del código
    real — y hasta ahora decirlo costaba tres operadores:
    <code><a href="toAsync.html">toAsync()</a></code> para entrar al mundo
    async, <code>map(f)</code> para transformar y
    <code><a href="concurrent.html">concurrent(n)</a></code> para acotar la
    evaluación. <code>mapConcurrent(n, f)</code> es exactamente esa
    composición como un solo paso de la cadena.
  </p>
  <p>
    Como <em>es</em> la composición — no una reimplementación —, todas las
    garantías se conservan: los resultados llegan en <strong>orden de
    origen</strong> (usa la forma larga con
    <code><a href="concurrentPool.html">concurrentPool</a></code> cuando
    quieras orden de finalización), como mucho <code>concurrency</code>
    callbacks están en vuelo, y los operadores aguas abajo siguen tirando
    perezosamente. Sobre una cadena ya async compone
    <code>map(f).concurrent(n)</code>, saltándose el puente.
  </p>
  <p>
    Es una adición nativa de Dart: FxTS canaliza <code>concurrent</code>
    como paso separado, y esa forma larga sigue disponible cuando necesites
    intercalar otro operador entre el map y el límite.
  </p>

  <h2>Demo 1 · Fan-out acotado, resultados en orden</h2>
  {{playground:0}}

  <h2>Demo 2 · Es exactamente map + concurrent</h2>
  {{playground:1}}

  <h2>Pruébalo tú</h2>
  <p>Ejercicio: trae todos los usuarios de dos en dos, conservando el orden.</p>
  {{playground:2}}

  <div class="callout">
    <strong>Relacionados:</strong>
    <a href="concurrent.html"><code>concurrent</code></a> — el limitador subyacente ·
    <a href="concurrentPool.html"><code>concurrentPool</code></a> — orden de finalización en vez de orden de origen ·
    <a href="toAsync.html"><code>toAsync</code></a> — el puente sync→async que este operador absorbe ·
    <a href="concurrentOrParallel.html">concurrent or parallel</a> — I/O vs CPU
  </div>
