---
slug: product
title: product — FxDart 101
description: Tutorial de product y productBy en FxDart: multiplica todos los números (o una clave de cada elemento), con 1 para una entrada vacía y los int conservados como int, síncrono y asíncrono, con un playground en vivo.
heading: <code>fxProduct</code> · <code>fxProductBy</code>
section: 7
crumb: product
prev: sumByDouble.html
prevLabel: sumByDouble
next: average.html
nextLabel: average
---
  <p class="hero-sub">El hermano multiplicador de <code>sum</code> — y una entrada vacía es <code>1</code>, no <code>0</code>.</p>

  {{signature}}

  <h2>Lección</h2>
  <p>
    <code>fxProduct(xs)</code> multiplica todos los números del iterable;
    <code>fxProductBy(f, xs)</code> multiplica una clave numérica de cada
    elemento — <code>map</code> + <code>product</code> en una sola pasada,
    la contrapartida de <code><a href="sumBy.html">sumBy</a></code>. Ambos
    son terminales: consumen la entrada entera y devuelven un único
    <code>num</code>.
  </p>
  <p>
    Una entrada vacía devuelve <strong><code>1</code></strong>, el elemento
    neutro de la multiplicación, por la misma razón por la que el
    <code>sum</code> de nada es <code>0</code>: es el único valor que
    mantiene verdadera
    <code>product(xs + ys) == product(xs) * product(ys)</code> cuando uno
    de los lados está vacío. Si devolviera <code>0</code>, partir un lote en
    trozos anularía todo total que tuviera un trozo vacío.
  </p>
  <p>
    La acumulación sigue a la de <code>sum</code>: mientras todos los
    valores son <code>int</code>, el resultado es <code>int</code>; el
    primer <code>double</code> lo pasa a <code>double</code> partiendo del
    total acumulado — exactamente lo que guardaría un
    <code>num acc *= v</code> en caja. En la cadena son
    <code>fx(numbers).product()</code> y
    <code>fx(items).productBy(f)</code>, y las variantes asíncronas
    (<code>fxProductAsync</code>, <code>fxProductByAsync</code> y los
    mismos nombres en <code>FxAsync</code>) aceptan una función de clave
    que devuelve un <code>Future</code>. Extensión de fxdart (FxTS tiene
    <code>sum</code> pero no <code>product</code>).
  </p>

  <h2>Demo 1 · Fundamentos, entrada vacía &amp; int frente a double</h2>
  {{playground:0}}

  <h2>Demo 2 · productBy y asíncrono</h2>
  {{playground:1}}

  <h2>Pruébalo tú</h2>
  <p>Ejercicio: sustituye el bucle que multiplica por una sola llamada.</p>
  {{playground:2}}

  <div class="callout">
    <strong>Relacionado:</strong>
    <a href="sum.html"><code>sum</code></a> · <a href="sumBy.html"><code>sumBy</code></a> — la pareja aditiva, vacío es <code>0</code> ·
    <a href="fold.html"><code>fold</code></a> — cualquier otra acumulación, con tu propia semilla ·
    <a href="average.html"><code>average</code></a> — el siguiente agregado numérico
  </div>
