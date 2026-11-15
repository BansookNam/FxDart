---
slug: sumStrings
title: sumStrings — FxDart 101
description: Tutorial de sumStrings en FxDart: concatena todas las cadenas en una sola pasada con Iterable.join en lugar de un fold cuadrático, con un playground en vivo.
heading: <code>fxSumStrings</code>
section: 7
crumb: sumStrings
prev: join.html
prevLabel: join
next: groupBy.html
nextLabel: groupBy
---
  <p class="hero-sub"><code>sum</code> para cadenas — concatenación en tiempo lineal, no el fold cuadrático.</p>

  {{signature}}

  <h2>Lección</h2>
  <p>
    <code>fxSumStrings(xs)</code> concatena todas las cadenas del iterable,
    sin nada entre ellas. Una entrada vacía devuelve <code>''</code>, el
    elemento neutro de la concatenación, igual que el <code>sum</code> de
    nada es <code>0</code>. Recibe un único argumento, así que encaja
    directamente en un <code><a href="pipe.html">pipe</a></code>.
  </p>
  <p>
    La forma obvia de escribirlo es
    <code>fold('', (acc, s) =&gt; acc + s, xs)</code> — y así lo hacía
    fxdart en su día. Pero las cadenas de Dart son inmutables: cada
    <code>+</code> copia el acumulador entero en una cadena nueva, así que
    el coste del fold crece con el <em>cuadrado</em> de la longitud de la
    salida. <code>fxSumStrings</code> es <code>Iterable.join()</code>, que
    escribe cada trozo una sola vez. La medición del changelog, 20.000
    cadenas de 10 caracteres:
    <strong>74.620 µs → 343 µs</strong>.
  </p>
  <p>
    No hay miembro de cadena ni variante asíncrona. En una cadena síncrona,
    <code>fx(xs).join()</code> es la misma llamada — <code>Fx.join</code> es
    el <code>Iterable.join</code> de Dart, cuyo separador por defecto es
    <code>''</code>. En <code>FxAsync</code>, <code>join</code> usa
    <code>','</code> por defecto (el de FxTS), así que escribe el separador
    vacío explícitamente: <code>.join('')</code>.
  </p>

  <h2>Demo 1 · Fundamentos, y el fold que sustituye</h2>
  {{playground:0}}

  <h2>Demo 2 · En una cadena, síncrona y asíncrona</h2>
  {{playground:1}}

  <h2>Pruébalo tú</h2>
  <p>Ejercicio: sustituye el fold cuadrático por una sola llamada.</p>
  {{playground:2}}

  <div class="callout">
    <strong>Relacionado:</strong>
    <a href="join.html"><code>join</code></a> — lo mismo, con separador ·
    <a href="sum.html"><code>sum</code></a> — la versión numérica ·
    <a href="fold.html"><code>fold</code></a> — por qué no concatenar con él
  </div>
