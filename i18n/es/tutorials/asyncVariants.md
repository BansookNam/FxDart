---
slug: asyncVariants
title: async variants — FxDart 101
description: La convención de nombres *Async de FxDart: cada operador perezoso y de agregación tiene su gemelo para FxAsyncIterable, con playground en vivo.
heading: The <code>*Async</code> naming convention
section: 11
crumb: async variants
next: streams.html
nextLabel: streams
---
  <p class="hero-sub">Cada operador perezoso y de agregación tiene un gemelo que trabaja sobre FxAsyncIterable: mismo comportamiento, con un callback apto para async.</p>

  {{signature}}

  <h2>Lección</h2>
  <p>
    Como Dart no tiene currificación sin tipos, FxDart no puede sobrecargar un
    único <code>map</code> para que funcione sobre <code>Iterable</code> y
    <code>FxAsyncIterable</code> en posición data-first: los tipos de los
    parámetros chocarían. Por eso cada operador perezoso y de agregación se
    publica en dos formas de nivel superior: la normal para
    <code>Iterable</code>, y un gemelo <code>*Async</code> para
    <code>FxAsyncIterable</code> cuyo callback devuelve
    <code>FutureOr&lt;R&gt;</code> en lugar de <code>R</code>. Ya has visto
    algunos: <code>map</code>/<code>mapAsync</code>,
    <code>filter</code>/<code>filterAsync</code>,
    <code>toList</code>/<code>toListAsync</code>,
    <code>reduce</code>/<code>reduceAsync</code>, <code>fold</code>/<code>foldAsync</code>,
    <code>each</code>/<code>eachAsync</code>, <code>find</code>/<code>findAsync</code>:
    el patrón se cumple prácticamente para todas las funciones de la librería.
  </p>
  <p>
    Las formas encadenadas no necesitan esta división. En cuanto llamas a
    <code>.toAsync()</code> (o empiezas desde <code>fxAsync</code>/<code>fxStream</code>),
    cada método posterior de esa cadena <code>FxAsync</code> conserva su nombre
    <strong>normal</strong> — <code>.map(...)</code>, no
    <code>.mapAsync(...)</code> — porque el tipo del receptor ya le dice a Dart
    qué sobrecarga usar. El sufijo solo existe en el nivel superior, donde las
    llamadas data-first lo necesitan para desambiguar.
  </p>

  <h2>Demo 1 · Unos cuantos gemelos, uno al lado del otro</h2>
  <p>Las llamadas data-first siempre necesitan el sufijo <code>Async</code> en cuanto
    trabajas con un <code>FxAsyncIterable</code>:</p>
  {{playground:0}}

  <h2>Demo 2 · Forma data-first frente a forma encadenada</h2>
  <p>
    La forma encadenada se lee igual que su equivalente síncrona —sin sufijos—
    una vez que <code>.toAsync()</code> ha cambiado el tipo del receptor:
  </p>
  {{playground:1}}

  <h2>Pruébalo tú</h2>
  <p>Ejercicio: usa el gemelo data-first <code>*Async</code> de <code>map</code>
    para poner en mayúsculas cada nombre de este pipeline asíncrono.</p>
  {{playground:2}}

  <div class="callout">
    <strong>Relacionado:</strong>
    <a href="toAsync.html"><code>toAsync</code></a> — donde empiezan los pipelines asíncronos ·
    <a href="streams.html">Puentes con Stream</a> — fromStream, fxStream, toStream ·
    <a href="concurrent.html"><code>concurrent</code></a> — evaluación en paralelo ·
    <a href="map.html"><code>map</code></a> — el original síncrono
  </div>
