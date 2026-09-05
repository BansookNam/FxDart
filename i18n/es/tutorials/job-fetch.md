---
slug: job-fetch
title: Fetch concurrente acotado — FxDart 101
description: Un tutorial de trabajo: trae N registros como máximo K a la vez, conserva el orden, conserva cada fallo — mapConcurrent, mapRetry, mapOrAccumulate.
heading: Fetch concurrente acotado
section: 15
crumb: bounded concurrent fetch
prev: job-search.html
prevLabel: debounced search
---
  <p class="hero-sub">Un límite, el orden conservado, cada fallo conservado. Este es el trabajo para el que <code>Future.wait</code> no tiene un primitivo.</p>

  {{signature}}

  <h2>Lección</h2>
  <p>
    Traer una lista conocida de ids no es un stream de eventos. Los datos están en
    la mano; el trabajo es I/O; la política es «como máximo <em>n</em> en vuelo,
    resultados en el orden original». Eso es
    <code><a href="mapConcurrent.html">mapConcurrent</a></code> (o
    <code>.toAsync().map(f).<a href="concurrent.html">concurrent</a>(n)</code>,
    la misma cadena escrita en tres pasos).
    <code>Future.wait(ids.map(fetch))</code> dispara todo de golpe.
    Agrupar en lotes de <em>n</em> espera al más lento de cada
    grupo. Hacerlo bien a mano es un pool de workers — un cursor compartido,
    huecos preasignados, futures de worker. La palabra de FxDart para ese pool es
    <code>concurrent(n)</code>.
  </p>
  <p>
    Las llamadas inestables se reintentan
    <em>por elemento</em> con
    <code><a href="retry.html">mapRetry</a></code>, no envolviendo el
    terminal entero. La validación que debe reportar cada problema — no
    solo el primero — es
    <code><a href="eitherPipelines.html">mapOrAccumulate</a></code> con
    <code>concurrency: n</code>. Cada elemento corre en su propio ámbito
    raise, así que un fallo en uno no puede filtrarse a un hermano, y los
    fallos salen en el orden de entrada.
  </p>
  <p>
    La
    <a href="../DartComparison/bounded-concurrency.html">comparación con Dart</a>
    del trabajo de pool de workers da el veredicto a <strong>fxdart</strong> en claridad;
    el pool nativo es más corto de lo que parece una vez que lo has escrito
    dos veces. Esta página es ese trabajo más la mitad de errores tipados, que los
    ejemplos de la comparación no muestran.
  </p>

  <h2>Demo 1 · dos en vuelo, orden conservado</h2>
  <p>
    Seis fetches, nunca más de dos solapados. La llamada falsa cuenta
    las peticiones en vuelo para que el límite se vea en la salida.
  </p>
  {{playground:0}}

  <h2>Demo 2 · cada fallo conservado, aún acotado</h2>
  <p>
    Los ids pares fallan. <code>mapOrAccumulate</code> sigue ejecutando tres a la
    vez, sigue devolviendo en orden, y el <code>Left</code> guarda
    <em>cada</em> id par — fail-slow, no fail-fast.
  </p>
  {{playground:1}}

  <div class="callout">
    <strong>Relacionado:</strong>
    <a href="whichSurface.html">which surface</a> — por qué esto es pull-async ·
    <a href="concurrent.html"><code>concurrent</code></a> ·
    <a href="mapConcurrent.html"><code>mapConcurrent</code></a> ·
    <a href="retry.html"><code>retry</code> / <code>mapRetry</code></a> ·
    <a href="eitherPipelines.html"><code>mapOrAccumulate</code></a> ·
    <a href="job-search.html">búsqueda con debounce</a> — el trabajo de tiempo ·
    <a href="../DartComparison/bounded-concurrency.html">Dart vs FxDart: dos a la vez</a>
  </div>
