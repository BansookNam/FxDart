---
slug: delay
title: delay &amp; sleep — FxDart 101
description: Tutorial de delay y sleep en FxDart: los dos ladrillos con los que está construida cada demo asíncrona de este sitio, con playground en vivo.
heading: <code>delay</code> &amp; <code>sleep</code>
section: 10
crumb: delay &amp; sleep
prev: comparisons.html
prevLabel: gt · gte · lt · lte
next: unicodeToArray.html
nextLabel: unicodeToArray
---
  <p class="hero-sub">Espera un poco y produce un valor (delay) — o simplemente espera (sleep).</p>

  {{signature}}

  <h2>Lección</h2>
  <p>
    <code>delay(wait, value)</code> devuelve un <code>Future</code> que se
    completa con <code>value</code> una vez transcurrido <code>wait</code>.
    <code>sleep(wait)</code> es la misma idea pero sin nada que devolver —
    simplemente se completa al cabo de esa duración. Ambas son envoltorios
    finos sobre <code>Future.delayed</code>, y ambas son justo lo que
    usarías para simular una operación lenta: una llamada de red, una
    consulta a base de datos, cualquier cosa que tarde y acabe produciendo
    (o no) un resultado.
  </p>
  <p>
    Estas dos funciones son la columna vertebral de casi todas las demos
    asíncronas de este sitio de tutoriales. Cada vez que veas
    <code>mapAsync</code>, <code>concurrent</code>, <code>debounce</code> o
    <code>throttle</code> demostrados con un <code>Stopwatch</code> que
    prueba que algo corrió en paralelo o quedó limitado en ritmo, es
    <code>delay</code> o <code>sleep</code> quien está esperando por debajo.
  </p>

  <h2>Demo 1 · Fundamentos</h2>
  {{playground:0}}

  <h2>Demo 2 · Simular trabajo concurrente</h2>
  <p>
    Tres "peticiones" tardan 150 ms cada una, pero corren de forma
    concurrente — el lote entero termina bastante por debajo de 450 ms:
  </p>
  {{playground:1}}

  <h2>Pruébalo tú</h2>
  <p>Ejercicio: usa <code>delay</code> para simular un "fetch" de 100 ms que
    devuelve <code>'pong'</code>.</p>
  {{playground:2}}

  <div class="callout">
    <strong>Relacionado:</strong>
    <a href="memoize.html"><code>memoize</code></a> — cachea un Future retardado para que solo espere una vez ·
    <a href="concurrent.html"><code>concurrent</code></a> — ejecuta varios delays en paralelo ·
    <a href="debounce.html"><code>debounce</code></a> / <a href="throttle.html"><code>throttle</code></a> — limitar el ritmo, construido sobre la espera ·
    <a href="toAsync.html"><code>toAsync</code></a> — convierte un Iterable normal en un pipeline asíncrono
  </div>
