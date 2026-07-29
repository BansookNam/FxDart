---
slug: maxBy
title: maxBy — FxDart 101
description: Tutorial de maxBy en FxDart: el elemento con la clave más grande en una sola pasada — sin ordenar, null cuando está vacío — con un playground en vivo.
heading: <code>maxBy</code>
section: 7
crumb: maxBy
prev: max.html
prevLabel: max
next: minBy.html
nextLabel: minBy
---
  <p class="hero-sub">El elemento cuya clave es la más grande — una sola pasada, sin ordenar, <code>null</code> cuando está vacío.</p>

  {{signature}}

  <h2>Lección</h2>
  <p>
    <code>maxBy</code> responde a «¿qué <em>elemento</em> tiene la clave más
    grande?», no a «¿cuál es el número más grande?» (eso es
    <code><a href="max.html">max</a></code>). Recorre el pipeline
    <strong>una sola vez</strong>, conservando el mejor elemento visto hasta el
    momento, así que es O(n) mientras que la tentadora forma
    <code>sortBy(key).head()</code> paga O(n&nbsp;log&nbsp;n) y materializa una
    lista ordenada que nunca llega a necesitar.
  </p>
  <p>
    Las claves se comparan exactamente igual que las compara
    <code><a href="sortBy.html">sortBy</a></code>
    (<code>Comparable.compare</code>), y en caso de empate gana el
    <strong>primer</strong> elemento encontrado — así que un <code>maxBy</code>
    sobre una lista ordenada por fecha te da el más antiguo de entre los
    igualmente máximos.
  </p>
  <p>
    Una entrada vacía devuelve <code>null</code>, igual que
    <code><a href="head.html">head</a></code> y
    <code><a href="last.html">last</a></code> — aquí los tipos anulables de
    Dart sustituyen al <code>undefined</code> de FxTS. Es un añadido nativo de
    Dart (FxTS solo trae el <code>max</code> numérico); el nombre sigue la
    forma de <code>maxByOrNull</code> de Kotlin.
  </p>

  <h2>Demo 1 · Fundamentos, caso vacío &amp; empates</h2>
  {{playground:0}}

  <h2>Demo 2 · Asíncrono</h2>
  {{playground:1}}

  <h2>Pruébalo tú</h2>
  <p>Ejercicio: encuentra el gasto más grande <strong>sin ordenar</strong>.</p>
  {{playground:2}}

  <div class="callout">
    <strong>Relacionado:</strong>
    <a href="minBy.html"><code>minBy</code></a> — la imagen especular ·
    <a href="max.html"><code>max</code></a> — cuando quieres la clave en sí, no el elemento ·
    <a href="sortBy.html"><code>sortBy</code></a> — cuando de todas formas necesitas el orden completo
  </div>
