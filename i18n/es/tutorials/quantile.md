---
slug: quantile
title: quantile — FxDart 101
description: Tutorial de quantile y quantileBy en FxDart: una mediana o un percentil por quickselect en O(n), sin ordenar la entrada entera, con playground en vivo.
heading: <code>fxQuantile</code> · <code>fxQuantileBy</code>
section: 7
crumb: quantile
prev: minBy.html
prevLabel: minBy
next: topBy.html
nextLabel: topBy
---
  <p class="hero-sub">La mediana, un p95 o cualquier percentil — en tiempo lineal, sin ordenarlo todo.</p>

  {{signature}}

  <h2>Lección</h2>
  <p>
    La forma habitual de leer un percentil es ordenar una copia e indexarla:
    <code>sorted[((n - 1) * q).round()]</code>. Eso es
    <code>O(n log n)</code> para leer una sola posición.
    <code>fxQuantile(q, xs)</code> devuelve el mismo valor mediante
    <strong>quickselect</strong>, que solo particiona hasta que esa posición
    queda fijada — <code>O(n)</code> de media, y los pivotes por mediana de
    tres mantienen también lineales las entradas ya ordenadas e invertidas,
    las formas reales más comunes. La entrada nunca se reordena; el trabajo
    se hace sobre una copia.
  </p>
  <p>
    El rango es de <em>rango más cercano</em>: el valor en el índice
    <code>((n - 1) * q).round()</code> de la entrada ordenada. Así,
    <code>q = 0</code> es el mínimo, <code>1</code> el máximo y
    <code>0.5</code> la mediana — el mayor de los dos valores centrales cuando
    la longitud es par. No se interpola nada: la respuesta es siempre una de
    las entradas. Una entrada vacía devuelve <code>null</code>; un
    <code>q</code> fuera de <code>[0, 1]</code> lanza <code>ArgumentError</code>.
  </p>
  <p>
    <code>fxQuantileBy(q, f, xs)</code> ordena por una clave numérica y
    devuelve el <em>elemento</em> — el producto de precio mediano, no el
    precio mediano. <code>f</code> se ejecuta una vez por elemento. En la
    cadena son <code>fx(numbers).quantile(q)</code> y
    <code>fx(items).quantileBy(q, f)</code>. Extensión de fxdart (sin
    contraparte en FxTS).
  </p>

  <h2>Demo 1 · Mediana y percentiles</h2>
  {{playground:0}}

  <h2>Demo 2 · quantileBy devuelve el elemento</h2>
  {{playground:1}}

  <h2>Pruébalo tú</h2>
  <p>Ejercicio: sustituye el ordenar-e-indexar por una sola llamada.</p>
  {{playground:2}}

  <div class="callout">
    <strong>Relacionado:</strong>
    <a href="minBy.html"><code>minBy</code></a> · <a href="maxBy.html"><code>maxBy</code></a> — los dos extremos, en un solo recorrido ·
    <a href="sortBy.html"><code>sortBy</code></a> — cuando necesitas el orden completo ·
    <a href="averageBy.html"><code>averageBy</code></a> — la media en lugar de la mediana
  </div>
