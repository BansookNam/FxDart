---
slug: job-search
title: Búsqueda con debounce — FxDart 101
description: Un tutorial de trabajo: espera a que la escritura se calme, quédate solo con la consulta más reciente, parsea con un error tipado — fxEvents, debounce, switchMap, mapEither.
heading: Búsqueda con debounce
section: 15
crumb: debounced search
prev: materialize.html
prevLabel: materialize
next: job-fetch.html
nextLabel: bounded concurrent fetch
---
  <p class="hero-sub">Primero el tiempo, luego gana lo más reciente, luego un parse tipado. Una cadena. El empate con RxDart es a propósito — el punto es que no necesitas un segundo paquete.</p>

  {{signature}}

  <h2>Lección</h2>
  <p>
    Una caja de búsqueda no es una lista. Las pulsaciones llegan cuando llegan, una
    ráfaga debería colapsarse a la última consulta, y una petición que aún esté
    en vuelo cuando aterriza la siguiente consulta debería cancelarse — si no,
    un «da» lento puede pisar un «dart» rápido. Eso es un
    trabajo <em>push</em>:
    <code><a href="fxEvents.html">fxEvents</a></code> +
    <code><a href="debounce.html">debounce</a></code> +
    <code><a href="switchMap.html">switchMap</a></code>.
  </p>
  <p>
    La
    <a href="../RxDartComparison/debounced-search.html">comparación con RxDart</a>
    del mismo trabajo es un <strong>empate</strong>. El
    <code>debounceTime</code> de rxdart es la misma idea. La afirmación de FxDart aquí no es
    velocidad — no puedes ganar a esperar — es que la capa de eventos vive
    en el mismo import que los pipelines pull y el sistema de errores tipados,
    así que el siguiente paso (parsear el acierto, quedarte con un <code>Left</code> en vez de
    lanzar) no arranca una librería nueva.
  </p>
  <p>
    <code><a href="mapEither.html">mapEither</a></code> ejecuta cada
    resultado entregado en un ámbito raise. Un payload malo se convierte en un
    <code>Left</code>; las consultas posteriores siguen llegando. Pon
    <code><a href="attempt.html">attempt</a></code> en la fuente solo
    cuando un <em>throw</em> deba convertirse en un valor — y si la cadena también
    reintenta, <code>attempt</code> va
    <strong>después</strong> de <code>retryOn</code>, nunca antes.
  </p>

  <h2>Demo 1 · espera a que la escritura se calme</h2>
  <p>
    El calendario de pulsaciones está simulado: una ráfaga, una pausa, una
    consulta más. <code>debounce(160ms)</code> emite dos veces —
    <code>fxd</code> y <code>fxdart</code> — el mismo contrato que la
    página de comparación.
  </p>
  {{playground:0}}

  <h2>Demo 2 · gana la consulta más reciente, luego un parse tipado</h2>
  <p>
    <code>switchMap</code> arranca una búsqueda por consulta y cancela el
    stream interno anterior. <code>mapEither</code> luego nombra un acierto
    ausente como un <code>Left</code> en vez de lanzar. Ambas búsquedas arrancan;
    solo se entrega el resultado más reciente.
  </p>
  {{playground:1}}

  <div class="callout">
    <strong>Relacionado:</strong>
    <a href="whichSurface.html">which surface</a> — por qué esto es push ·
    <a href="fxEvents.html"><code>fxEvents</code></a> ·
    <a href="debounce.html"><code>debounce</code></a> ·
    <a href="switchMap.html"><code>switchMap</code></a> ·
    <a href="mapEither.html"><code>mapEither</code></a> ·
    <a href="job-fetch.html">fetch concurrente acotado</a> — el trabajo de I/O ·
    <a href="../RxDartComparison/debounced-search.html">RxDart vs FxDart: debounce</a>
  </div>
