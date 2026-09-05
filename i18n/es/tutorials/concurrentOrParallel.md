---
slug: concurrentOrParallel
title: concurrent o parallel — FxDart 101
description: Tutorial de concurrent o parallel en FxDart: cuándo solapar Futures en este isolate, y cuándo enviar trabajo de CPU a un pool de isolates.
heading: concurrent o parallel
section: 11
crumb: concurrent or parallel
prev: using.html
prevLabel: using
next: parallel.html
nextLabel: parallel
---
  <p class="hero-sub">Dos maneras de solapar trabajo. No son el mismo operador con dos nombres.</p>

  {{signature}}

  <h2>Lección</h2>
  <p>
    <code><a href="concurrent.html">concurrent(n)</a></code> solapa
    <code>Future</code>s en <em>este</em> isolate — I/O, espera.
    <code><a href="parallel.html">parallel(n, worker)</a></code> solapa
    trabajo de CPU entre <em>otros</em> isolates. Elige según en qué gasta
    el tiempo el callback, no según cuánto quieras «ir más rápido».
  </p>
  <table>
    <tr><th></th><th><code>concurrent(n)</code></th><th><code>parallel(n)</code></th></tr>
    <tr><td>Qué se solapa</td><td><code>Future</code>s en este isolate</td><td>isolates worker</td></tr>
    <tr><td>Callback</td><td>cualquier closure</td><td>función top-level o static</td></tr>
    <tr><td>Valores</td><td>cualquier cosa</td><td>enviables</td></tr>
    <tr><td>Plataformas</td><td>VM, Flutter, web</td><td>solo VM / Flutter</td></tr>
    <tr><td>Trabajo barato (<code>x + 1</code>, <code>Future.delayed(0)</code>)</td><td>un marcador; los hops son baratos</td><td>un mensaje de isolate por elemento — casi siempre una pérdida</td></tr>
    <tr><td>El trabajo adecuado</td><td>HTTP, DB, archivos, <code>await</code></td><td>parseo JSON, imágenes, crypto, un bucle apretado</td></tr>
  </table>
  <p>
    I/O es sobre todo espera. Mientras una petición está en vuelo el isolate
    está idle, así que solapar cuatro <code>Future</code>s con
    <code>concurrent(4)</code> recorta el tiempo de reloj y no necesita
    otro isolate. El trabajo de CPU <em>es</em> el isolate: bloquea el
    event loop (y un frame de Flutter) hasta que vuelve. Para eso está
    <code>parallel</code>.
  </p>
  <p>
    El hop de isolate no es gratis. Cada elemento se serializa, se envía,
    se ejecuta, se serializa de vuelta y se reordena. Un callback cuyo
    cuerpo es <code>x + 1</code> gasta más tiempo en ese hop que en la
    suma — cuatro workers entonces lo hacen <em>más lento</em> que uno,
    porque pagas cuatro veces el porte sin CPU que recuperar.
    Medido: mil <code>x + 1</code> con cuatro workers tardaron
    aproximadamente el doble que con uno; un bucle apretado de 20000
    iteraciones con cuatro workers fue aproximadamente el doble de
    <em>rápido</em> que con uno. Si el trabajo no es más pesado que el hop,
    quédate en este isolate.
  </p>
  <pre><code>// I/O — overlap Futures here
fx(ids).mapConcurrent(8, fetchUser);

// CPU — only when the body is heavy enough
fx(blobs).parallel(parallelWorkers, parseJson);

// This is a loss. The hop is bigger than the work.
fx(nums).parallel(4, (x) =&gt; x + 1);</code></pre>

  <div class="callout">
    <strong>Relacionado:</strong>
    <a href="concurrent.html"><code>concurrent</code></a> — I/O, cualquier closure ·
    <a href="mapConcurrent.html"><code>mapConcurrent</code></a> — la forma combinada de I/O ·
    <a href="parallel.html"><code>parallel</code></a> — CPU, worker enviable ·
    <a href="parallel.html"><code>mapParallel</code></a> — alias de <code>parallel</code>
  </div>
