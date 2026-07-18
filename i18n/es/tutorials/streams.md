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
    <code>fromStream</code> convierte cualquier <code>Stream</code> — de
    suscripción única o broadcast — en un <code>FxAsyncIterable</code>, para que puedas
    aplicar todo el conjunto de operadores de FxDart (<code>map</code>, <code>filter</code>,
    <code>concurrent</code>, …) sobre datos que llegan desde un socket, un
    fichero, el stream de eventos de un widget, o de cualquier otro sitio donde Dart te dé un
    <code>Stream</code>. <code>fxStream(stream)</code> hace lo mismo, pero
    devuelve directamente un <code>FxAsync</code> encadenable en lugar de un
    <code>FxAsyncIterable</code> a secas — el equivalente asíncrono de <code>fx</code>
    y <code>fxAsync</code>.
  </p>
  <p>
    En el sentido contrario, <code>.toStream()</code> lleva un
    <code>FxAsyncIterable</code> (o una cadena <code>FxAsync</code>) hasta el final
    y reemite sus valores como un <code>Stream</code> normal — útil cuando otra
    API (un <code>StreamBuilder</code>, por ejemplo) espera uno. Una
    advertencia: <code>toStream()</code> siempre tira de los valores <strong>secuencialmente</strong>,
    ignorando cualquier <code>concurrent(n)</code> que haya aguas arriba — aplica
    <code>concurrent</code>/<code>concurrentPool</code> a la cadena
    <em>antes</em> de llamar a <code>.toStream()</code> si quieres que el
    paralelismo ocurra de verdad; la conversión a stream por sí sola no lo añade.
  </p>

  <h2>Demo 1 · fromStream y fxStream</h2>
  <p>Ambos envuelven un <code>Stream.fromIterable</code> para que puedas pasar un
    stream existente por los operadores de FxDart:</p>
  {{playground:0}}

  <h2>Demo 2 · Ida y vuelta, con un stream periódico finito</h2>
  <p>
    <code>Stream.periodic</code> nunca termina por sí solo, así que
    <code>.take(n)</code> mantiene la demo finita. La segunda mitad muestra la
    dirección inversa — construir una cadena <code>FxAsync</code> y devolverla
    hacia fuera como un <code>Stream</code> normal con <code>.toStream()</code>:
  </p>
  {{playground:1}}

  <h2>Pruébalo tú</h2>
  <p>Ejercicio: quédate solo con los valores &gt;= 10 de este stream.</p>
  {{playground:2}}

  <div class="callout">
    <strong>Relacionado:</strong>
    <a href="toAsync.html"><code>toAsync</code></a> — eleva un Iterable normal en su lugar ·
    <a href="asyncVariants.html">variantes asíncronas</a> — la convención de nombres *Async ·
    <a href="concurrent.html"><code>concurrent</code></a> — aplícalo antes de toStream() para tener paralelismo real ·
    <a href="concurrentPool.html"><code>concurrentPool</code></a> — variante por orden de finalización
  </div>
