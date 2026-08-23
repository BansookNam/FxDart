---
slug: streams
title: Stream bridges — FxDart 101
description: Puentes con Stream en FxDart: fromStream, fxStream y toStream() — ida y vuelta entre los Stream de Dart y FxAsyncIterable, con un playground en vivo.
heading: Stream bridges
section: 11
crumb: Stream bridges
next: concurrent.html
nextLabel: concurrent
---
  <p class="hero-sub">fromStream, fxStream y .toStream() — cruza libremente entre el Stream de Dart y el FxAsyncIterable de FxDart.</p>

  {{signature}}

  <h2>Lección</h2>
  <p>
    <code>fromStream</code> convierte cualquier <code>Stream</code> —de
    suscripción única o broadcast— en un <code>FxAsyncIterable</code>, para
    que puedas aplicar todo el conjunto de operadores de FxDart
    (<code>map</code>, <code>filter</code>, <code>concurrent</code>, …) sobre
    datos que llegan desde un socket, un fichero, el stream de eventos de un
    widget o de cualquier otro sitio donde Dart te dé un <code>Stream</code>.
    <code>fxStream(stream)</code> hace lo mismo, pero devuelve directamente un
    <code>FxAsync</code> encadenable en lugar de un
    <code>FxAsyncIterable</code> a secas — el equivalente asíncrono de
    <code>fx</code> y <code>fxAsync</code>.
  </p>
  <p>
    En el sentido contrario, <code>.toStream()</code> lleva un
    <code>FxAsyncIterable</code> (o una cadena <code>FxAsync</code>) hasta el
    final y reemite sus valores como un <code>Stream</code> normal — útil
    cuando otra API (un <code>StreamBuilder</code>, por ejemplo) espera uno.
    Una advertencia: <code>toStream()</code> siempre tira de los valores
    <strong>secuencialmente</strong>, ignorando cualquier
    <code>concurrent(n)</code> que haya aguas arriba — aplica
    <code>concurrent</code>/<code>concurrentPool</code> a la cadena
    <em>antes</em> de llamar a <code>.toStream()</code> si quieres que el
    paralelismo ocurra de verdad; la conversión a stream por sí sola no lo
    añade.
  </p>
  <p>
    Cruzar de push a pull no es una operación: son cuatro, porque un
    stream puede seguir emitiendo mientras el consumidor está ocupado.
    RxJS 9 nombra las cuatro <code>iterateEach</code>,
    <code>iterateLatest</code>, <code>iterateBuffered</code> e
    <code>iterateNext</code>. FxDart las mapea a
    <code>fromStream*</code> (iterable crudo) y
    <code>FxEvents.pull*</code> (cadena):
  </p>
  <table>
    <thead><tr><th>RxJS 9</th><th>FxDart</th><th>mientras estás ocupado</th></tr></thead>
    <tbody>
      <tr><td><code>iterateEach</code></td><td><code>fromStream</code> / <code>.pull()</code></td><td>FIFO sin pérdidas — pausa la fuente, encola cada valor</td></tr>
      <tr><td><code>iterateLatest</code></td><td><code>fromStreamLatest</code> / <code>.pullLatest()</code></td><td>descarta lo superado — quédate solo con el no leído más nuevo</td></tr>
      <tr><td><code>iterateBuffered</code></td><td><code>fromStreamChunked</code> / <code>.pullChunked()</code></td><td>lote — emite las llegadas como una lista</td></tr>
      <tr><td><code>iterateNext</code></td><td><code>fromStreamNext</code> / <code>.pullNext()</code></td><td>descarte por demanda — ignora lo que llegó sin un pull esperando</td></tr>
    </tbody>
  </table>
  <p>
    <code>fromStream</code> es el valor por defecto y el que usa la Demo 1,
    porque un fichero o un socket no deberían perder bytes. Usa latest
    cuando una UI solo le importa la lectura actual, chunked cuando el
    consumidor quiere trabajo en lotes, y next cuando los eventos viejos
    son peores que los huecos.
  </p>

  <h2>Demo 1 · fromStream y fxStream</h2>
  <p>Ambos envuelven un <code>Stream.fromIterable</code> para que puedas pasar
    un stream existente por los operadores de FxDart:</p>
  {{playground:0}}

  <h2>Demo 2 · Ida y vuelta, con un stream periódico finito</h2>
  <p>
    <code>Stream.periodic</code> nunca termina por sí solo, así que
    <code>.take(n)</code> mantiene la demo finita. La segunda mitad muestra la
    dirección inversa — construir una cadena <code>FxAsync</code> y devolverla
    hacia fuera como un <code>Stream</code> normal con
    <code>.toStream()</code>:
  </p>
  {{playground:1}}

  <h2>Demo 3 · Cuatro formas de tirar de un stream</h2>
  <p>
    Un ráfaga síncrona de 1, 2, 3 llega mientras un pull ya está
    esperando. <code>fromStream</code> conserva cada valor;
    <code>fromStreamLatest</code> conserva solo el más nuevo;
    <code>fromStreamChunked</code> los emite como una lista;
    <code>fromStreamNext</code> conserva solo el valor que encontró el
    pull en espera. Las grafías de la cadena de eventos son
    <code>.pull()</code>, <code>.pullLatest()</code>,
    <code>.pullChunked()</code>, <code>.pullNext()</code>.
  </p>
  {{playground:3}}

  <h2>Dos cadenas, un Stream</h2>
  <p>
    Un <code>Stream</code> es la única fuente que pertenece a las dos mitades
    de FxDart, así que lleva dos getters. No son variantes uno del otro: son
    <strong>modelos distintos</strong>.
  </p>
  <table>
    <thead><tr><th></th><th><code>stream.fx</code></th><th><code>stream.fxEvents</code></th></tr></thead>
    <tbody>
      <tr><td>devuelve</td><td><code>FxAsync&lt;T&gt;</code></td><td><code>FxEvents&lt;T&gt;</code></td></tr>
      <tr><td>equivale a</td><td><code>fxStream(stream)</code></td><td><code>fxEvents(stream)</code></td></tr>
      <tr><td>modelo</td><td><strong>pull</strong> — datos bajo demanda</td><td><strong>push</strong> — eventos en el tiempo</td></tr>
      <tr><td>quién marca el ritmo</td><td>el consumidor, un <code>next()</code> cada vez</td><td>el stream; los operadores reajustan el tiempo</td></tr>
      <tr><td>operadores típicos</td><td><code>map</code>, <code>filter</code>, <code>concurrent</code>, <code>toList</code></td><td><code>debounce</code>, <code>throttle</code>, <code>switchMap</code>, <code>combineLatest</code></td></tr>
      <tr><td>contrapresión</td><td>sí — nada se tira hasta pedirlo</td><td>no — el stream emite cuando emite</td></tr>
    </tbody>
  </table>
  <p>
    La regla práctica: si la pregunta es <em>«¿cuántos a la vez?»</em> quieres
    la cadena pull, porque <code>concurrent(n)</code> solo significa algo
    cuando el consumidor controla la demanda. Si la pregunta es <em>«¿con qué
    frecuencia, y cuál gana?»</em> quieres la cadena de eventos. Empieza por
    cualquiera y cruza —
    <code>.pull()</code> / <code>.pullLatest()</code> /
    <code>.pullChunked()</code> / <code>.pullNext()</code> convierten un
    <code>FxEvents</code> en la cadena pull, <code>.toStream()</code> convierte
    un <code>FxAsync</code> de nuevo en un <code>Stream</code>.
  </p>
  <p>
    Lecciones completas: <a href="fxEvents.html"><code>fxEvents</code></a> para
    la cadena push, <a href="fx.html"><code>fx</code></a> para el modelo de
    cadena y las formas con getter, y
    <a href="concurrent.html"><code>concurrent</code></a> para lo que solo el
    lado pull puede hacer.
  </p>

  <h2>Pruébalo tú</h2>
  <p>Ejercicio: quédate solo con los valores &gt;= 10 de este stream.</p>
  {{playground:2}}

  <div class="callout">
    <strong>Relacionado:</strong>
    <a href="toAsync.html"><code>toAsync</code></a> — eleva un Iterable normal en su lugar ·
    <a href="asyncVariants.html">variantes asíncronas</a> — la convención de nombres *Async ·
    <a href="concurrent.html"><code>concurrent</code></a> — aplícalo antes de toStream() para tener paralelismo real ·
    <a href="concurrentPool.html"><code>concurrentPool</code></a> — variante por orden de finalización ·
    <a href="fxEvents.html"><code>fxEvents</code></a> — la cadena push; <code>.pull()</code> / <code>.pullLatest()</code> / <code>.pullChunked()</code> / <code>.pullNext()</code> cruzan de vuelta
  </div>
