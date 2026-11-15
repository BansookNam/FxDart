---
slug: sumByDouble
title: sumByDouble — FxDart 101
description: Tutorial de sumByDouble y sumByInt en FxDart: suma un selector con el resultado ya tipado como double o int, síncrono y asíncrono, con playground en vivo.
heading: <code>sumByDouble</code> · <code>sumByInt</code>
section: 7
crumb: sumByDouble
prev: sumBy.html
prevLabel: sumBy
next: product.html
nextLabel: product
---
  <p class="hero-sub"><code>sumBy</code> con el resultado ya tipado: un <code>double</code> o un <code>int</code>, sin cast.</p>

  {{signature}}

  <h2>Lección</h2>
  <p>
    <code><a href="sumBy.html">sumBy</a></code> devuelve <code>num</code>,
    porque su selector puede devolver cualquiera de los dos tipos de número.
    Eso es lo correcto para una columna mixta y un incordio para una tipada:
    una tasa de oro guardada en un campo <code>double</code>, o un recuento
    guardado en un <code>int</code>, necesita <code>.toDouble()</code> o
    <code>.toInt()</code> después de cada suma. <code>sumByDouble(f)</code> y
    <code>sumByInt(f)</code> reciben un selector que ya devuelve ese tipo y lo
    devuelven sin cambios.
  </p>
  <p>
    Además hacen algo menos de trabajo. <code>sumBy</code> mantiene un
    acumulador <code>int</code> y cambia a un <code>double</code> la primera
    vez que llega un no entero, lo que cuesta una comprobación de tipo por
    elemento; estas dos empiezan en el acumulador adecuado y simplemente
    suman. El orden de suma es el mismo recorrido de izquierda a derecha, así
    que <code>sumByDouble</code> redondea exactamente igual que
    <code>sumBy</code>. Una entrada vacía devuelve <code>0.0</code> y
    <code>0</code>, conservando el tipo.
  </p>
  <p>
    Extensión de fxdart (sin contraparte en FxTS). Son tres palabras
    camelCase, así que por la regla de nombres la forma de nivel superior no
    lleva el prefijo <code>fx</code>.
  </p>

  <h2>Demo 1 · Sin cast</h2>
  {{playground:0}}

  <h2>Demo 2 · Entrada vacía y asíncrono</h2>
  {{playground:1}}

  <h2>Pruébalo tú</h2>
  <p>Ejercicio: elimina los dos casts usando las sumas tipadas.</p>
  {{playground:2}}

  <div class="callout">
    <strong>Relacionado:</strong>
    <a href="sumBy.html"><code>sumBy</code></a> — la forma <code>num</code> para columnas mixtas ·
    <a href="sum.html"><code>sum</code></a> — los propios números ·
    <a href="averageBy.html"><code>averageBy</code></a> — la media de un selector
  </div>
