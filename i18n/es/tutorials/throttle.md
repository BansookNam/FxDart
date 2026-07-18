---
slug: throttle
title: throttle — FxDart 101
description: Tutorial de throttle en FxDart: invoca una función como máximo una vez por periodo de espera, con flancos leading/trailing y cancel(), más playground en vivo.
heading: <code>throttle</code>
section: 12
crumb: throttle
next: shuffle.html
nextLabel: shuffle
---
  <p class="hero-sub">Invoca una función como máximo una vez por periodo de espera — a un ritmo fijo, a diferencia del «esperar a que haya calma» de debounce.</p>

  {{signature}}

  <h2>Lección</h2>
  <p>
    <code>throttle</code> garantiza que <code>func</code> se ejecute como
    máximo una vez cada <code>wait</code>, por muchas veces que se llame a la
    función con throttle. Esa es la diferencia clave con
    <a href="debounce.html"><code>debounce</code></a>: debounce
    <em>reinicia</em> su temporizador en cada llamada, así que un flujo
    continuo de llamadas puede retrasar la ejecución indefinidamente; la
    ventana de throttle es fija una vez arranca, así que las llamadas siguen
    pasando con una cadencia regular — útil para cosas como manejadores de
    scroll o resize, donde quieres actualizaciones periódicas y no solo una al
    final del todo.
  </p>
  <p>
    Tanto <code>leading</code> como <code>trailing</code> valen
    <code>true</code> por defecto: la primera llamada de una ventana se
    dispara de inmediato (flanco de subida) y, si llegan más llamadas antes de
    que la ventana se cierre, la <em>última</em> se dispara al terminar la
    ventana (flanco de bajada, con el argumento más reciente). Desactiva
    cualquiera de los dos para obtener un comportamiento solo-leading o
    solo-trailing. Igual que <code>debounce</code>, el
    <code>Throttled&lt;T&gt;</code> devuelto es una clase invocable con un
    <code>.cancel()</code> para descartar una llamada trailing pendiente.
  </p>

  <h2>Demo 1 · Leading + trailing (el valor por defecto)</h2>
  <p>La primera llamada se dispara de inmediato; la última de la ventana se
    dispara otra vez cuando la ventana se cierra:</p>
  {{playground:0}}

  <h2>Demo 2 · Ajustar leading/trailing, y cancel()</h2>
  <p>
    Desactiva <code>leading</code> para un comportamiento solo-trailing,
    desactiva <code>trailing</code> para solo-leading, o llama a
    <code>.cancel()</code> para descartar una llamada trailing pendiente:
  </p>
  {{playground:1}}

  <h2>Pruébalo tú</h2>
  <p>Ejercicio: envuelve <code>onClick</code> en <code>throttle</code> (100 ms
    de espera) para que los clics rápidos se registren como mucho dos veces
    —leading y trailing— en lugar de tres veces por separado.</p>
  {{playground:2}}

  <div class="callout">
    <strong>Relacionado:</strong>
    <a href="debounce.html"><code>debounce</code></a> — espera a que haya calma en vez de seguir un ritmo fijo ·
    <a href="delay.html"><code>delay</code> &amp; <code>sleep</code></a> — para construir demos con tiempos ·
    <a href="shuffle.html"><code>shuffle</code></a> — aleatoriedad con semilla ·
    <a href="concurrent.html"><code>concurrent</code></a> — limitación de tasa para pipelines asíncronos
  </div>
