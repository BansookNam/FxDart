---
slug: timeout
title: timeout — FxDart 101
description: Tutorial de timeout en FxDart: haz fallar un pull que tarda demasiado — límites de tiempo por elemento en el modelo pull — con playground en vivo.
heading: <code>timeout</code>
section: 11
crumb: timeout
prev: retry.html
prevLabel: retry
next: using.html
nextLabel: using
---
  <p class="hero-sub">Hace fallar cualquier pull individual que tarde más de <code>limit</code> con una <code>TimeoutException</code>.</p>

  {{signature}}

  <h2>Lección</h2>
  <p>
    Un pipeline es tan reactivo como su await más lento.
    <code>timeout(limit)</code> le pone un límite a eso: cada pull — el
    trabajo de producir <em>un</em> elemento, atraviese los operadores de
    aguas arriba que atraviese — debe terminar dentro de
    <code>limit</code>, o el pull falla con una
    <code>TimeoutException</code>. Los elementos rápidos quedan intactos;
    el operador no añade retardo propio.
  </p>
  <p>
    Semántica del modelo pull, y conviene ser preciso: el límite mide el
    <strong>tiempo de demanda a elemento</strong> — desde el momento en
    que aguas abajo pide hasta que el elemento llega. No mide los huecos
    entre elementos (no los hay sin demanda) ni acota el pipeline entero
    (eso es <code>Future.timeout</code> sobre el terminal:
    <code>fxAsync(…).toList().timeout(…)</code>). El <code>timeout</code>
    de RxDart vigila los huecos entre eventos de un stream push — mismo
    nombre, medido desde el otro lado.
  </p>
  <p>
    Extensión de fxdart (sin contraparte en FxTS). Seguro en paralelo:
    bajo <code><a href="concurrent.html">concurrent(n)</a></code> cada
    pull solapado lleva su propio temporizador, así que <em>n</em>
    elementos algo lentos que se solapan siguen pasando individualmente.
    Combínalo con <code><a href="retry.html">retry</a></code> — timeout
    convierte «colgarse» en «fallar», y retry convierte «fallar» en
    «inténtalo otra vez».
  </p>

  <h2>Demo 1 · Atrapando el atasco</h2>
  {{playground:0}}

  <h2>Demo 2 · Por pull, no por pipeline</h2>
  {{playground:1}}

  <h2>Pruébalo tú</h2>
  <p>Ejercicio: acota el feed lento y luego recupérate.</p>
  {{playground:2}}

  <div class="callout">
    <strong>Relacionado:</strong>
    <a href="retry.html"><code>retry</code></a> — qué hacer después de que salte el timeout ·
    <a href="concurrent.html"><code>concurrent</code></a> — los pulls solapados expiran de forma independiente ·
    <a href="eitherPipelines.html">errores tipados</a> — capturar la <code>TimeoutException</code> como valor
  </div>
