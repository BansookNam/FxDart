---
slug: predicateOps
title: predicate combinators — FxDart 101
description: Tutorial de los combinadores de predicados de FxDart: construye condiciones con and, or, xor, negate y contramap, con playground en vivo.
heading: predicate combinators
section: 10
crumb: and · or · xor · contramap
prev: not.html
prevLabel: not
next: when.html
nextLabel: when
---
  <p class="hero-sub">Construye una condición a partir de predicados con nombre — <code>and</code>, <code>or</code>, <code>xor</code>, <code>negate</code>, <code>contramap</code> — en lugar de anidar lambdas.</p>

  {{signature}}

  <h2>Lección</h2>
  <p>
    Todos los operadores de filtrado de la biblioteca toman un predicado:
    <a href="filter.html"><code>filter</code></a>,
    <a href="reject.html"><code>reject</code></a>,
    <a href="takeWhile.html"><code>takeWhile</code></a>,
    <a href="dropWhile.html"><code>skipWhile</code></a>,
    <a href="countWhere.html"><code>countWhere</code></a>,
    <a href="partition.html"><code>partition</code></a>. Una vez que has
    puesto nombre a las condiciones — <code>isEven</code>,
    <code>isPositive</code>, <code>isBlank</code> —, combinarlas no debería
    costarte una lambda nueva con el parámetro vuelto a tipar cada vez. Estos
    combinadores son justo eso.
  </p>
  <p>
    Son una extensión sobre <code>bool Function(T)</code>, así que a cualquier
    predicado que ya tengas le crecen los métodos: una función de nivel
    superior, un tear-off, un closure guardado o el resultado de otro
    combinador. Cada uno devuelve un predicado nuevo y no llama a nada hasta
    que se ejecuta <em>ese</em> predicado.
  </p>
  <p>
    <code>and</code> y <code>or</code> cortocircuitan exactamente como
    <code>&amp;&amp;</code> y <code>||</code>: el predicado de la derecha se
    salta cuando el de la izquierda ya ha decidido, lo que importa cuando es
    la mitad cara. <code>xor</code> no tiene nada que cortocircuitar y siempre
    llama a los dos.
  </p>
  <p>
    <code>contramap</code> es el raro y el útil. Transforma el
    <em>argumento</em> en vez del resultado — eso es lo que significa el
    <em>contra</em> —, así que un predicado sobre <code>int</code> pasa a ser
    un predicado sobre cualquier cosa que puedas convertir en
    <code>int</code>: <code>isEven.contramap&lt;String&gt;((s) =&gt; s.length)</code>
    prueba la longitud de una cadena sin una palabra sobre cadenas dentro de
    <code>isEven</code>.
  </p>
  <p>
    <code>.negate</code> es la forma de getter de extensión del
    <a href="negate.html"><code>negate</code></a> de nivel superior: la misma
    función, alcanzada desde el otro lado. Usa la que se lea mejor en el punto
    de llamada; <code>isBlank.or(isShort).negate</code> se lee de izquierda a
    derecha, mientras que <code>negate(...)</code> metería la expresión entera
    dentro de una llamada.
  </p>

  <h2>Demo 1 · and, or, xor, negate</h2>
  {{playground:0}}

  <h2>Demo 2 · contramap, y el cortocircuito</h2>
  {{playground:1}}

  <h2>Pruébalo tú</h2>
  <p>Ejercicio: conserva las filas que no están en blanco ni son cortas.</p>
  {{playground:2}}

  <div class="callout">
    <strong>Relacionado:</strong>
    <a href="negate.html"><code>negate</code></a> — la forma de nivel superior de <code>.negate</code> ·
    <a href="not.html"><code>not</code></a> — voltea un solo valor booleano, no un predicado ·
    <a href="filter.html"><code>filter</code></a> / <a href="reject.html"><code>whereNot</code></a> — donde suele acabar un predicado compuesto ·
    <a href="predicates.html"><code>predicates</code></a> — los predicados de tipo integrados con los que combinar
  </div>
