---
slug: sortBy
title: sortBy — FxDart 101
description: Tutorial de sortBy en FxDart: ordena de forma ascendente por una clave extraída, siempre en una lista nueva, con un playground en vivo.
heading: <code>sortBy</code>
section: 7
crumb: sortBy
prev: sort.html
prevLabel: sort
next: partition.html
nextLabel: partition
---
  <p class="hero-sub">Ordena de forma ascendente por una clave que extraes, en lugar de escribir un comparador a mano.</p>

  {{signature}}

  <h2>Lección</h2>
  <p>
    <code>sortBy</code> es el hermano cómodo de
    <code><a href="sort.html">sort</a></code>: en lugar de escribir tú
    <code>(a, b) =&gt; a.age.compareTo(b.age)</code>, le das a
    <code>sortBy</code> un extractor de clave — <code>(a) =&gt; a['age']</code> —
    y construye el comparador por ti, siempre ascendente, comparando
    siempre las claves extraídas con <code>Comparable.compare</code>. Por
    debajo es literalmente <code>sort((a, b) =&gt; compare(f(a), f(b)), iterable)</code>.
  </p>
  <p>
    Todas las garantías de <code>sort</code> se mantienen sin cambios: el
    resultado siempre es una lista <strong>nueva</strong>, nunca una mutación de
    la entrada. Y el mismo matiz de la forma de cadena también se aplica: en la
    cadena síncrona <code>Fx</code>, <code>.sortBy(f)</code> devuelve otro
    <code>Fx&lt;T&gt;</code>, así que sigues necesitando
    <code><a href="../101/index.html">.toArray()</a></code> para materializarlo,
    mientras que en la cadena <code>FxAsync</code>, <code>.sortBy(f)</code> ya
    es un terminal que devuelve <code>Future&lt;List&lt;T&gt;&gt;</code>.
  </p>
  <p>
    Si necesitas orden descendente, o una ordenación por varias claves, vuelve
    a <code>sort</code> con un comparador explícito — <code>sortBy</code>
    solo cubre el caso habitual de "ascendente por una clave extraída".
  </p>

  <h2>Demo 1 · Fundamentos</h2>
  {{playground:0}}

  <h2>Demo 2 · Asíncrono — ya es un terminal</h2>
  {{playground:1}}

  <h2>Pruébalo tú</h2>
  <p>Ejercicio: ordena a las personas <strong>por edad</strong>, de menor a mayor.</p>
  {{playground:2}}

  <div class="callout">
    <strong>Relacionado:</strong>
    <a href="sort.html"><code>sort</code></a> — la forma basada en comparador sobre la que se construye ·
    <a href="min.html"><code>min</code></a> · <a href="max.html"><code>max</code></a> — para un solo extremo en lugar de una ordenación completa ·
    <a href="pluck.html"><code>pluck</code></a> — extrae la misma clave sin ordenar
  </div>
