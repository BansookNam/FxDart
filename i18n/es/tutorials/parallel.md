---
slug: parallel
title: parallel — FxDart 101
description: Tutorial de parallel en FxDart: el gemelo de CPU de concurrent — un pool de isolates, un worker top-level enviable, orden conservado, y chunk para amortizar el hop. Solo VM y Flutter.
heading: <code>parallel</code>
section: 11
crumb: parallel
prev: concurrentOrParallel.html
prevLabel: concurrent or parallel
next: debounce.html
nextLabel: debounce
---
  <p class="hero-sub">Solapa trabajo de CPU entre isolates, en el orden de la fuente. No es <code>concurrent</code> con otro nombre.</p>

  {{signature}}

  <h2>Lección</h2>
  <p>
    <code><a href="concurrent.html">concurrent(n)</a></code> solapa
    <code>Future</code>s en el mismo isolate — I/O. La historia de CPU de
    Dart son los isolates. <code>parallel(n, worker)</code> es el gemelo: un
    <strong>pool reutilizado</strong> de <code>n</code> isolates, resultados
    en el orden de la fuente, como
    <code><a href="mapConcurrent.html">mapConcurrent</a></code>
    es la forma combinada de map-más-concurrent. No son el mismo operador —
    la comparación está en
    <a href="concurrentOrParallel.html">concurrent or parallel</a>.
  </p>
  <p>
    Prefiere una función top-level o static. Un closure que capture algo no
    enviable (un <code>ReceivePort</code>, un socket abierto) lanza
    <code>ArgumentError</code> al spawn — el contrato de isolate, no un
    invento de fxdart. Un input o un resultado no enviable falla ese pull
    del mismo modo, en lugar de colgarse. En la web el operador lanza
    <code>UnsupportedError</code> — usa <code>concurrent(n)</code>
    ahí. Este listado es solo VM y no es un playground en vivo.
  </p>
  <p>
    ¿No quieres elegir <code>n</code>? <code>parallelWorkers</code> es
    el número de procesadores de la VM — pásalo como primer argumento. Una
    <code>List</code> más corta que <code>n</code> ajusta el pool a la
    lista, así que <code>parallel(8, w)</code> sobre dos elementos arranca
    dos isolates, no ocho. Quien venga de
    <code>mapConcurrent</code> puede escribir <code>mapParallel</code>; es
    el mismo operador.
  </p>
  <pre><code>int timesTen(int x) =&gt; x * 10;

Future&lt;void&gt; main() async {
  print(await fx([1, 2, 3, 4]).parallel(2, timesTen).toList());
  // [10, 20, 30, 40]
}</code></pre>

  <h2><code>chunk</code> — cuántos elementos viajan en un mensaje</h2>
  <p>
    Por defecto cada elemento cruza a un worker por su cuenta. Ese viaje
    de ida y vuelta cuesta unos <strong>5µs</strong>, más que la mayoría
    de callbacks, y es toda la razón por la que un worker barato es
    <em>más lento</em> bajo <code>parallel</code> que en un bucle simple.
    <code>chunk: k</code> lo paga una vez cada <code>k</code> elementos:
  </p>
  <pre><code>// 20,000 elements, ~0.4µs of work each, 4 workers:
await fx(rows).parallel(4, parseRow).toList();             // ~142ms
await fx(rows).parallel(4, parseRow, chunk: 512).toList(); //   ~3ms

// the same work in a plain loop, no isolates:            //   ~8ms</code></pre>
  <p>
    47× en esa forma, y la forma por lotes es la primera que de verdad
    gana al bucle que sustituye. Elige <code>k</code> para que
    <code>k × callback</code> supere holgadamente 5µs, y aun así queden
    varios lotes por worker para equilibrar —
    <code>length ~/ (workers * 4)</code> es un buen punto de partida.
  </p>
  <p>
    Un lote no cambia lo que observas: el orden es el mismo, la
    contrapresión es la misma, y un worker que lanza sigue emitiendo los
    resultados de los elementos <em>anteriores</em> y luego raisea en el
    elemento que de verdad falló. Cambian dos cosas. El primer elemento
    ahora espera a todo su lote, así que un <code>take(1)</code> quiere un
    <code>chunk</code> pequeño o ninguno. Y un <em>resultado</em> no
    enviable falla todo el lote en lugar de solo su pull — averiguar qué
    elemento tuvo la culpa significaría enviarlos por separado, que es el
    coste que el lote existe para evitar.
  </p>

  <div class="callout">
    <strong>Relacionado:</strong>
    <a href="concurrent.html"><code>concurrent</code></a> — I/O, cualquier closure ·
    <a href="mapConcurrent.html"><code>mapConcurrent</code></a> — la forma combinada de I/O ·
    <a href="concurrentOrParallel.html">concurrent or parallel</a> — I/O vs CPU ·
    <code>mapParallel</code> — el mismo operador que <code>parallel</code> ·
    <a href="../parallel-benchmark.html">¿merece la pena parallel?</a> — el mismo trabajo de cinco maneras, medido
  </div>
