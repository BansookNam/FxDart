---
slug: withIndex
title: mapWithIndex &amp; friends — FxDart 101
description: Tutorial de mapWithIndex, filterWithIndex, flatMapWithIndex y foldWithIndex en FxDart: recibe la posición del elemento como segundo argumento, con playground en vivo.
heading: <code>mapWithIndex</code> &amp; friends
section: 6
crumb: …WithIndex
prev: zipWithIndex.html
prevLabel: indexed
next: transpose.html
nextLabel: transpose
---
  <p class="hero-sub">Los cuatro operadores que conocen el índice: <code>map</code>, <code>filter</code>, <code>flatMap</code> y <code>fold</code> con la posición del elemento como segundo argumento.</p>

  {{signature}}

  <h2>Lección</h2>
  <p>
    <a href="zipWithIndex.html"><code>zipWithIndex</code></a> ya te da la
    posición: empareja cada elemento con su índice y luego lees el par. Eso
    funciona, y es la herramienta correcta cuando el par es lo que quieres.
    Cuando no lo es, pagas un record por elemento y un cuerpo de callback
    escrito con <code>p.$1</code> / <code>p.$2</code> en vez de con nombres.
  </p>
  <p>
    Estos cuatro reciben el índice directamente. No hay nada que reservar ni
    nada que desempaquetar, y la cadena dice lo que hace.
  </p>
  <p>
    <strong>El índice cuenta la entrada de esa etapa.</strong> No es la
    posición del elemento en la fuente original: un
    <a href="filter.html"><code>filter</code></a> por encima de
    <code>mapWithIndex</code> renumera lo que lo atraviesa, empezando otra vez
    en 0. El que hay que leer dos veces es <code>filterWithIndex</code>: su
    cuenta avanza también con los elementos que <em>descarta</em>, porque
    siguen siendo entrada. <code>flatMapWithIndex</code> cuenta elementos de
    la fuente, no emitidos, así que un iterable interno de cinco valores
    avanza el índice en uno.
  </p>
  <p>
    Todos tienen su forma <code>…Async</code>, y la numeración sobrevive a
    <a href="concurrent.html"><code>concurrent</code></a>: solapa los tirones
    aguas arriba pero los resuelve igualmente en orden, así que el elemento
    <em>n</em> recibe el índice <em>n</em> fueran cuales fueran las latencias.
    El contador vive además por <em>iteración</em>, así que volver a recorrer
    una cadena empieza otra vez en 0.
  </p>
  <p>
    Una arruga de Dart en <code>foldWithIndex</code>: si el lambda del
    acumulador no lleva tipos, <code>Acc</code> se infiere como
    <code>Object?</code> y la aritmética deja de compilar. No es nada nuevo de
    aquí — el propio <code>Iterable.fold</code> de Dart se comporta igual — y
    la solución es la misma: escribe
    <code>foldWithIndex&lt;int&gt;(…)</code>.
  </p>

  <h2>Demo 1 · mapWithIndex, y a qué sustituye</h2>
  {{playground:0}}

  <h2>Demo 2 · filter, flatMap, fold — y asíncrono</h2>
  {{playground:1}}

  <h2>Pruébalo tú</h2>
  <p>Ejercicio: numera a los que llegan a meta como 1st, 2nd, 3rd usando el índice.</p>
  {{playground:2}}

  <div class="callout">
    <strong>Relacionado:</strong>
    <a href="zipWithIndex.html"><code>indexed</code></a> — la forma de pares, cuando el par es lo que quieres ·
    <a href="map.html"><code>map</code></a> / <a href="filter.html"><code>filter</code></a> / <a href="flatMap.html"><code>flatMap</code></a> — los operadores que estos extienden ·
    <a href="fold.html"><code>fold</code></a> — la reducción con semilla ·
    <a href="foldRight.html"><code>foldRight</code></a> — el mismo fold desde el otro extremo
  </div>
