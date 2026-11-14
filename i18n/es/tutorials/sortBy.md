---
slug: sortBy
title: sortBy — FxDart 101
description: Tutorial de sortBy en FxDart: ordena de forma ascendente por una clave extraída, siempre en una lista nueva, con un playground en vivo.
heading: <code>sortBy</code>
section: 7
crumb: sortBy
prev: sort.html
prevLabel: sort
next: sortByDesc.html
nextLabel: sortByDesc
---
  <p class="hero-sub">Ordena de forma ascendente por una clave que extraes, en lugar de escribir un comparador a mano.</p>

  {{signature}}

  <h2>Lección</h2>
  <p>
    <code>sortBy</code> es el hermano cómodo de
    <code><a href="sort.html">sort</a></code>: en lugar de escribir tú
    <code>(a, b) =&gt; a.age.compareTo(b.age)</code>, le das a
    <code>sortBy</code> un extractor de clave — <code>(a) =&gt; a['age']</code> —
    y ordena por las claves extraídas, siempre de forma ascendente, comparándolas
    siempre con <code>Comparable.compare</code>.
  </p>
  <p>
    Por debajo <em>no</em> es <code>sort((a, b) =&gt; compare(f(a), f(b)))</code>,
    y la diferencia se nota en tu callback: esa forma llamaría a <code>f</code>
    dos veces por comparación, unas <code>2·n·log n</code> veces.
    <code>sortBy</code> extrae cada clave <strong>exactamente una vez</strong> y
    después ordena por las claves extraídas, así que un extractor costoso cuesta
    <code>n</code> llamadas, no <code>2·n·log n</code>. Aun así, mantén
    <code>f</code> pura y barata: el número de llamadas está garantizado, el
    orden en que ocurren no.
  </p>
  <p>
    Todas las garantías de <code>sort</code> se mantienen sin cambios: el
    resultado siempre es una lista <strong>nueva</strong>, nunca una mutación de
    la entrada. Y el mismo matiz de la forma de cadena también se aplica: en la
    cadena síncrona <code>Fx</code>, <code>.sortBy(f)</code> devuelve otro
    <code>Fx&lt;T&gt;</code>, así que sigues necesitando
    <code><a href="../101/index.html">.toList()</a></code> para materializarlo,
    mientras que en la cadena <code>FxAsync</code>, <code>.sortBy(f)</code> ya
    es un terminal que devuelve <code>Future&lt;List&lt;T&gt;&gt;</code>.
  </p>
  <p>
    <code>sortBy</code> es <strong>estable</strong>: los elementos con claves
    iguales conservan el orden en que llegaron, sea cual sea el tipo de la
    clave. (Antes de 0.9.1 eso solo valía para claves <code>int</code> y
    <code>double</code> — las claves <code>String</code> y las demás pasaban
    por <code>List.sort</code>, que puede reordenar los empates.) La
    estabilidad es lo que permite un orden de dos niveles sin comparador:
    ordena por la clave secundaria y después por la principal.
  </p>
  <p>
    Para el orden descendente usa <a href="sortByDesc.html"><code>sortByDesc</code></a>,
    que también es estable. Para cualquier cosa más allá de encadenar claves
    simples, vuelve a <code>sort</code> con un comparador explícito.
  </p>

  <h2>Demo 1 · Fundamentos</h2>
  {{playground:0}}

  <h2>Demo 2 · Asíncrono — ya es un terminal</h2>
  {{playground:1}}

  <h2>Demo 3 · Estable — un orden de dos niveles</h2>
  {{playground:3}}

  <h2>Pruébalo tú</h2>
  <p>Ejercicio: ordena a las personas <strong>por edad</strong>, de menor a mayor.</p>
  {{playground:2}}

  <div class="callout">
    <strong>Relacionado:</strong>
    <a href="sort.html"><code>sort</code></a> — la forma basada en comparador sobre la que se construye ·
    <a href="min.html"><code>min</code></a> · <a href="max.html"><code>max</code></a> — para un solo extremo en lugar de una ordenación completa ·
    <a href="pluck.html"><code>fxPluck</code></a> — extrae la misma clave sin ordenar
  </div>
