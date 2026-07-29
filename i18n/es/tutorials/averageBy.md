---
slug: averageBy
title: averageBy — FxDart 101
description: Tutorial de averageBy en FxDart: la media de una clave sobre todos los elementos — map + average en un solo paso — con un playground en vivo.
heading: <code>averageBy</code>
section: 7
crumb: averageBy
prev: average.html
prevLabel: average
next: min.html
nextLabel: min
---
  <p class="hero-sub">La media de una clave sobre todos los elementos — <code>map</code> + <code>average</code> en un solo paso, <code>NaN</code> cuando está vacío.</p>

  {{signature}}

  <h2>Lección</h2>
  <p>
    <code>averageBy</code> completa la familia de operadores por clave
    (<code><a href="sumBy.html">sumBy</a></code> ·
    <code><a href="maxBy.html">maxBy</a></code> ·
    <code><a href="minBy.html">minBy</a></code>): extrae una clave numérica de
    cada elemento y promedia esas claves, en una sola pasada que lleva a la vez
    un total y un contador acumulados.
  </p>
  <p>
    El contrato es el de <code><a href="average.html">average</a></code>: un
    pipeline vacío devuelve <code>double.nan</code> (está calculando
    <code>0 / 0</code>), nunca <code>0</code> — comprueba
    <code>result.isNaN</code> cuando la entrada pueda quedar vacía. El
    resultado siempre es un <code>double</code>.
  </p>

  <h2>Demo 1 · Fundamentos &amp; el caso vacío</h2>
  {{playground:0}}

  <h2>Demo 2 · Claves asíncronas</h2>
  {{playground:1}}

  <h2>Pruébalo tú</h2>
  <p>Ejercicio: promedia con una sola llamada las páginas de los libros ya leídos.</p>
  {{playground:2}}

  <div class="callout">
    <strong>Relacionado:</strong>
    <a href="average.html"><code>average</code></a> — cuando el pipeline ya contiene números ·
    <a href="sumBy.html"><code>sumBy</code></a> — el primo que calcula el numerador ·
    <a href="maxBy.html"><code>maxBy</code></a> · <a href="minBy.html"><code>minBy</code></a> — el resto de la familia
  </div>
