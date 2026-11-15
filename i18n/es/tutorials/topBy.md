---
slug: topBy
title: topBy — FxDart 101
description: Tutorial de topBy y bottomBy en FxDart: los k elementos mayores o menores por clave en una sola pasada, ya ordenados, con los empates para el primero visto — en lugar de ordenarlo todo y tomar k — con un playground en vivo.
heading: <code>fxTopBy</code> · <code>fxBottomBy</code>
section: 7
crumb: topBy
prev: quantile.html
prevLabel: quantile
next: size.html
nextLabel: count
---
  <p class="hero-sub">Los 3 mejores, los 5 más baratos — en una sola pasada, ya en orden, sin ordenar el resto.</p>

  {{signature}}

  <h2>Lección</h2>
  <p>
    La forma habitual de leer una clasificación es
    <code>sortByDesc(f, xs).take(k)</code>: ordenar toda la entrada,
    quedarse con <code>k</code> y tirar el resto.
    <code>fxTopBy(k, f, xs)</code> devuelve los mismos <code>k</code>
    elementos en <strong>una sola pasada</strong> que solo mantiene una
    frontera de tamaño <code>k</code> — la memoria es proporcional a
    <code>k</code>, no a la entrada, y nada fuera de la frontera se
    retiene. <code>fxBottomBy(k, f, xs)</code> es su imagen especular: las
    <code>k</code> claves más pequeñas, de menor a mayor.
  </p>
  <p>
    El resultado no necesita una segunda pasada. Está
    <strong>ordenado</strong> — descendente en <code>topBy</code>,
    ascendente en <code>bottomBy</code> — y <strong>un empate lo gana el
    primer elemento visto</strong>: un elemento posterior cuya clave solo
    iguala a la más débil de la frontera no la desplaza, y las claves
    iguales dentro del resultado conservan el orden de entrada.
    <code>k &lt;= 0</code> devuelve una lista vacía; un <code>k</code> mayor
    que la entrada devuelve todos los elementos, ordenados. Las claves se
    comparan exactamente como en
    <code><a href="sortBy.html">sortBy</a></code>, así que sirve cualquier
    <code>Comparable</code>.
  </p>
  <p>
    La frontera se mantiene por inserción, así que el peor caso es
    <code>O(n·k)</code>: es para un <code>k</code> pequeño sobre una entrada
    grande; cuando <code>k</code> se acerca a la longitud de la entrada,
    ordena. En la cadena síncrona <code>fx(xs).topBy(k, f)</code> es un
    <em>paso</em> — devuelve un <code>Fx</code>, así que puedes seguir
    encadenando —, mientras que <code>FxAsync.topBy</code> y las variantes
    <code>fxTopByAsync</code> terminan la cadena con un
    <code>Future&lt;List&gt;</code>; su función de clave sigue siendo
    síncrona. Extensión de fxdart (no forma parte de FxTS) — la forma de
    <code>heapq.nlargest</code> de Python.
  </p>

  <h2>Demo 1 · Orden, empates &amp; k</h2>
  {{playground:0}}

  <h2>Demo 2 · En la cadena, síncrona y asíncrona</h2>
  {{playground:1}}

  <h2>Pruébalo tú</h2>
  <p>Ejercicio: sustituye el ordenar-y-tomar por una sola llamada.</p>
  {{playground:2}}

  <div class="callout">
    <strong>Relacionado:</strong>
    <a href="sortByDesc.html"><code>sortByDesc</code></a> — cuando necesitas el orden completo ·
    <a href="maxBy.html"><code>maxBy</code></a> · <a href="minBy.html"><code>minBy</code></a> — cuando <code>k</code> es 1 ·
    <a href="quantile.html"><code>quantile</code></a> — una posición, no los primeros <code>k</code>
  </div>
