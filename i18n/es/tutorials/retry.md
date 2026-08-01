---
slug: retry
title: retry — FxDart 101
description: Tutorial de retry y mapRetry en FxDart: reejecuta efectos inestables con backoff, por elemento o por pipeline, seguro en paralelo — con playground en vivo.
heading: <code>retry</code>
section: 11
crumb: retry
prev: concurrentPool.html
prevLabel: concurrentPool
next: timeout.html
nextLabel: timeout
---
  <p class="hero-sub">Ejecuta de nuevo un efecto inestable hasta que tenga éxito — hasta <code>attempts</code> veces, con backoff opcional entre fallos.</p>

  {{signature}}

  <h2>Lección</h2>
  <p>
    Los pipelines reales llaman a servicios reales, y los servicios
    reales fallan de vez en cuando. La respuesta hecha a mano es un bucle
    <code>for</code> con un <code>try</code>/<code>catch</code>, un
    contador y un <code>Future.delayed</code> — copiada en cada proyecto,
    sutilmente distinta cada vez. <code>retry(attempts, f)</code> es ese
    bucle, una sola vez: ejecuta <code>f</code>, y ante un error vuelve a
    ejecutarlo, hasta <code>attempts</code> ejecuciones en total; agotado
    el presupuesto, el <em>último</em> error se relanza con su stack
    trace original. El hook <code>delay</code> recibe el número de fallos
    (<code>1, 2, …</code>), así que el backoff es una línea:
    <code>delay: (failed)&nbsp;=&gt;&nbsp;Duration(seconds:&nbsp;failed)</code>.
  </p>
  <p>
    <code>mapRetry(attempts, f)</code> es la misma idea por elemento: un
    <code><a href="map.html">map</a></code> en el que cada llamada tiene
    su propio presupuesto de reintentos. Está construido sobre el
    <code>mapAsync</code> seguro en paralelo, así que bajo
    <code><a href="concurrent.html">concurrent(n)</a></code> cada
    elemento en vuelo reintenta de forma <em>independiente</em> — un
    elemento lento e inestable se reejecuta mientras sus vecinos avanzan
    sin problema, y el orden se sigue preservando. Para reintentar un
    pipeline entero, envuelve su terminal:
    <code>retry(3, ()&nbsp;=&gt;&nbsp;fxAsync(…).toList())</code> — el
    resultado parcial se descarta y el pipeline se reejecuta desde un
    iterador nuevo.
  </p>
  <p>
    Extensión de fxdart (sin contraparte en FxTS), inspirada en
    <code>retry</code>/<code>retryWhen</code> de Rx — rediseñada para el
    modelo pull, donde «resuscribirse» significa «construir el iterable
    otra vez». Para un manejo <em>tipado</em> del fallo cuando los
    reintentos se agotan, pásale el resultado a
    <code><a href="eitherPipelines.html">eitherCatching</a></code>.
  </p>

  <h2>Demo 1 · Un fetch inestable, con backoff</h2>
  {{playground:0}}

  <h2>Demo 2 · mapRetry bajo concurrent</h2>
  {{playground:1}}

  <h2>Pruébalo tú</h2>
  <p>Ejercicio: haz que la importación sobreviva a sus filas inestables.</p>
  {{playground:2}}

  <div class="callout">
    <strong>Relacionado:</strong>
    <a href="timeout.html"><code>timeout</code></a> — acota cuánto puede tardar cada pull ·
    <a href="concurrent.html"><code>concurrent</code></a> — los reintentos son independientes por elemento en vuelo ·
    <a href="eitherPipelines.html">errores tipados</a> — cuando el fallo debe ser un valor, no una excepción
  </div>
