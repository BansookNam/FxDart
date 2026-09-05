---
slug: mergeScan
title: mergeScan — FxDart 101
description: Tutorial de mergeScan en FxDart: pliega cada evento en estado compartido a través de un stream interno — switchScan cancela, expandEach recorre un árbol — con playground en vivo.
heading: <code>mergeScan</code>, <code>switchScan</code> &amp; <code>expandEach</code>
section: 14
crumb: mergeScan
prev: switchLatest.html
prevLabel: switchLatest
next: race.html
nextLabel: race
---
  <p class="hero-sub">Pliega cada evento en estado compartido a través de un stream interno — fusiónalos, cámbialos o recorre un árbol. La semilla <em>no</em> se emite.</p>

  {{signature}}

  <h2>Lección</h2>
  <p>
    <code>FxEvents.scan</code> emite primero la semilla y luego cada
    acumulación en curso — la convención de la capa pull, igual que
    <code><a href="scan.html">scan</a></code>.
    <code>mergeScan</code> y <code>switchScan</code>
    <strong>no</strong>. La semilla es solo el acumulador de partida,
    nunca un evento. Eso coincide con Rx, y es lo que sorprende a quien
    viene de <code>FxEvents.scan</code>: una fuente vacía
    cierra vacía.
  </p>
  <p>
    <code>mergeScan(seed, acc)</code> pliega cada evento abriendo
    <code>accumulator(state, value)</code> como un stream interno. Cada
    emisión interna se convierte en el nuevo estado y se reenvía. Con
    <code>concurrent: n</code> como mucho <em>n</em> internos corren a la
    vez y el resto espera en una cola; comparten una sola variable de
    estado — gana la última emisión interna. <code>concurrent</code>
    nulo es ilimitado. El resultado cierra cuando la fuente ha cerrado y
    todo interno ha terminado.
  </p>
  <p>
    <code>switchScan</code> es el hermano que cancela: un nuevo valor de
    la fuente <strong>cancela</strong> el interno anterior a mitad de
    vuelo, y la última emisión interna (si la hay) es el estado que se
    entrega a la siguiente llamada del acumulador. Tras cerrar la
    fuente, se deja terminar el interno actual.
  </p>
  <p>
    <code>expandEach</code> es el <code>expand</code> de Rx, renombrado
    porque la capa pull ya usa esa palabra para el
    <code><a href="flatMap.html">flatMap</a></code> de iterables.
    Emite cada valor de la fuente y luego aplana de forma recursiva el
    <code>project</code> de ese valor — y de cada valor que
    <code>project</code> emita a su vez — en anchura primero. Un
    <code>project</code> que nunca devuelve un stream vacío no
    terminará. Capa de eventos de fxdart, siguiendo a
    <code>mergeScan</code>, <code>switchScan</code> y
    <code>expand</code> de Rx.
  </p>

  <h2>Demo 1 · mergeScan — la semilla se queda en silencio</h2>
  {{playground:0}}

  <h2>Demo 2 · switchScan — lo más nuevo cancela</h2>
  {{playground:1}}

  <h2>Pruébalo tú</h2>
  <p>Ejercicio: <code>expandEach</code>, un árbol finito <code>0 → 1 → 2</code>.</p>
  {{playground:2}}

  <div class="callout">
    <strong>Relacionado:</strong>
    <a href="scan.html"><code>scan</code></a> — la semilla <em>sí</em> se emite ·
    <a href="switchMap.html"><code>switchMap</code></a> / <a href="mergeMap.html"><code>mergeMap</code></a> — aplanado sin estado compartido ·
    <a href="flatMap.html"><code>expand</code></a> — aplanado de un nivel en el lado pull, el nombre que este no pudo tomar
  </div>
