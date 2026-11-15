---
slug: conflate
title: conflate — FxDart 101
description: Tutorial de conflate en FxDart: ejecuta un trabajo asíncrono de uno en uno y conserva solo el valor más nuevo que llegó entretanto — seeks, sincronizaciones, vistas previas.
heading: <code>fxConflate</code>
section: 12
crumb: conflate
prev: onChange.html
prevLabel: onChange
next: shuffle.html
nextLabel: shuffle
---
  <p class="hero-sub">Una ejecución asíncrona a la vez; lo que llegue entretanto se colapsa en su valor más nuevo, que es el que se ejecuta después.</p>

  {{signature}}

  <h2>Lección</h2>
  <p>
    Una barra de reproducción de vídeo llama a <code>seekTo</code> en cada tic
    del arrastre, pero un seek tarda más que un tic. Esperar cada uno por turno
    acumula una cola de seeks obsoletos; lanzarlos todos a la vez deja que uno
    antiguo termine el último y gane. Lo que la barra quiere decir es «ve a
    donde esté el control <em>ahora</em>», y <code>fxConflate(run)</code> es
    justo eso: la primera llamada arranca de inmediato; una llamada que llega
    mientras hay una ejecución en curso se retiene, y una llamada más nueva la
    sustituye; cuando la ejecución termina, se ejecuta el valor retenido — el
    más nuevo. Todo lo intermedio se descarta.
  </p>
  <p>
    Nunca espera a que todo se calme (eso es
    <a href="debounce.html"><code>fxDebounce</code></a>) y nunca abandona la
    ejecución en curso (eso es <code>switchLatest</code> en la capa de
    eventos) — un <code>Future</code> no se puede cancelar, así que el
    comportamiento honesto es dejarlo terminar y seguir adelante.
    <code>.isRunning</code> y <code>.isPending</code> describen el estado,
    <code>.idle</code> se completa en cuanto no hay nada ejecutándose ni nada
    esperando, y <code>.cancel()</code> descarta el valor retenido.
  </p>
  <p>
    Un error lanzado por <code>run</code> va a <code>onError</code>, o a la
    zona actual cuando no lo hay, y no detiene la siguiente ejecución — una
    sincronización fallida no debería bloquear la siguiente. Extensión de
    fxdart (sin contraparte en FxTS), inspirada en el <code>conflate</code> de
    Kotlin Flow.
  </p>

  <h2>Demo 1 · Una barra que va más rápido que su seek</h2>
  {{playground:0}}

  <h2>Demo 2 · Estado, errores e idle</h2>
  {{playground:1}}

  <h2>Pruébalo tú</h2>
  <p>Ejercicio: renderiza solo el primer valor del slider y el más nuevo.</p>
  {{playground:2}}

  <div class="callout">
    <strong>Relacionado:</strong>
    <a href="debounce.html"><code>fxDebounce</code></a> — espera a que paren las llamadas ·
    <a href="throttle.html"><code>fxThrottle</code></a> — como mucho una vez por ventana ·
    <a href="switchLatest.html"><code>switchLatest</code></a> — la forma con streams, que abandona la ejecución antigua ·
    <a href="concurrentPool.html"><code>concurrentPool</code></a> — muchas ejecuciones, acotadas
  </div>
