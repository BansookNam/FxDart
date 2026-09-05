---
slug: isolateMap
title: isolateMap — FxDart 101
description: Tutorial de isolateMap2..5 en FxDart: fusiona 2–5 etapas de CPU en un worker enviable para que parallel pague un solo hop de isolate, con playground en vivo.
heading: <code>isolateMap2..5</code>
section: 11
crumb: isolateMap2..5
prev: parallel.html
prevLabel: parallel
next: debounce.html
nextLabel: debounce
---
  <p class="hero-sub">Fusiona 2–5 etapas de CPU en un worker enviable — un hop de isolate, no uno por etapa.</p>

  {{signature}}

  <h2>Lección</h2>
  <p>
    Dos llamadas a
    <code><a href="parallel.html">parallel</a></code>
    copian cada resultado de vuelta a este isolate y otra vez hacia
    fuera. Es el mismo hop de ~5µs que <code>chunk</code> existe para
    amortizar, pagado dos veces.
    <code>isolateMap3(parse, normalise, score)</code> es una función
    que corre las tres en el worker:
  </p>
  <pre><code>await fx(lines)
    .parallel(4, isolateMap3(parse, normalise, score), chunked: true)
    .toList();</code></pre>
  <p>
    Cada argumento tiene que ser enviable (top-level o static, o un
    closure cuyos captures lo sean). La función devuelta los captura;
    es enviable cuando ellos lo son. Dart no tiene genéricos
    variádicos, así que los helpers paran en 5 — como
    <code>zipOrAccumulate2..5</code>. Más allá, escribe el worker
    fusionado tú.
  </p>
  <p>
    <code>parallel</code> es solo VM, así que los playgrounds de abajo
    corren el mismo worker fusionado a través de <code>map</code>. El
    resultado es idéntico; solo falta el hop.
  </p>

  <h2>Demo 1 · parse, normalise, score</h2>
  <p>
    Tres etapas, una función. En la VM se lo pasarías a
    <code>parallel</code>; aquí corre en el playground.
  </p>
  {{playground:0}}

  <h2>Demo 2 · Los mismos números que tres maps</h2>
  <p>
    <code>isolateMap3</code> es composición, no un operador nuevo.
    Tres <code>map</code>s y un worker fusionado imprimen la misma
    lista.
  </p>
  {{playground:1}}

  <h2>Pruébalo tú</h2>
  <p>
    Ejercicio: fusiona <code>parse</code> → <code>normalise</code> →
    <code>score</code> y quédate solo con las filas que puntúan al
    menos 4.
  </p>
  {{playground:2}}

  <div class="callout">
    <strong>Relacionado:</strong>
    <a href="parallel.html"><code>parallel</code></a> — el pool de CPU para el que es este worker ·
    <a href="map.html"><code>map</code></a> — la misma composición en este isolate ·
    <a href="concurrentOrParallel.html">concurrent or parallel</a> — I/O vs CPU ·
    <a href="../parallel-benchmark.html">¿merece la pena parallel?</a> — cuando el hop importa
  </div>
