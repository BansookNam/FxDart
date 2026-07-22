---
slug: shuffle
title: shuffle — FxDart 101
description: Tutorial de shuffle en FxDart: barajado de Fisher-Yates con semilla opcional para un orden reproducible, en versión síncrona y asíncrona, con playground en vivo.
heading: <code>shuffle</code>
section: 12
crumb: shuffle
next: createSeededRandom.html
nextLabel: createSeededRandom
---
  <p class="hero-sub">Devuelve una nueva lista con los elementos barajados — pasa una semilla para obtener un resultado reproducible.</p>

  {{signature}}

  <h2>Lección</h2>
  <p>
    <code>shuffle</code> aplica un barajado de Fisher-Yates a los elementos de
    <code>iterable</code> y devuelve una <code>List&lt;T&gt;</code> totalmente
    nueva: la entrada nunca se muta. Si lo llamas sin semilla, usa
    <code>Random</code> de <code>dart:math</code>, así que cada llamada da un
    orden distinto, justo lo que esperas para una baraja de cartas o un
    cuestionario aleatorizado.
  </p>
  <p>
    Si le pasas un <code>seed</code> de tipo <code>int</code>, shuffle cambia a
    un PRNG con semilla (un port a Dart del mismo generador estilo Mulberry32
    que usa FxTS), de modo que la <em>misma semilla produce siempre el mismo
    orden</em>: en cualquier ejecución y en cualquier máquina. Ese determinismo
    es lo que hace útil el barajado con semilla para fixtures de test
    reproducibles, puzles de «reto diario» donde todo el mundo con la semilla de
    hoy ve la misma disposición, o repeticiones deterministas de una simulación
    aleatorizada.
  </p>
  <p>
    <code>shuffleAsync</code> es el gemelo <code>*Async</code>: primero
    materializa el <code>FxAsyncIterable</code> (internamente con
    <code>toListAsync</code>) y luego baraja el resultado, así que un barajado
    asíncrono con semilla produce exactamente el mismo orden que su equivalente
    síncrono con la misma semilla.
  </p>

  <h2>Demo 1 · Determinismo con semilla</h2>
  <p>Misma semilla, mismo orden, siempre. Una semilla distinta da un orden
    distinto (pero igual de reproducible):</p>
  {{playground:0}}

  <h2>Demo 2 · shuffleAsync coincide con el orden síncrono, y no se pierde nada</h2>
  <p>
    La misma semilla da un orden idéntico tanto si la fuente es síncrona como
    asíncrona, y todos los elementos de la entrada siguen ahí, solo que
    reordenados:
  </p>
  {{playground:1}}

  <h2>Pruébalo tú</h2>
  <p>Ejercicio: dale una semilla a este orden de turnos para que sea
    reproducible entre reinicios de la app en lugar de aleatorio cada vez.</p>
  {{playground:2}}

  <div class="callout">
    <strong>Relacionado:</strong>
    <a href="throttle.html"><code>throttle</code></a> — limitación de frecuencia para callbacks ·
    <a href="debounce.html"><code>debounce</code></a> — limitación que espera a que haya calma ·
    <a href="toAsync.html"><code>toAsync</code></a> — eleva una lista para usarla con shuffleAsync ·
    <a href="sort.html"><code>sort</code></a> — el instinto contrario: orden determinista
  </div>
