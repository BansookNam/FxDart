---
slug: comparisons
title: gt · gte · lt · lte — FxDart 101
description: Tutorial de comparaciones en FxDart: gt, gte, lt y lte en estilo data-first, y cómo currificarlos en predicados unarios, con un playground en vivo.
heading: <code>gt</code> · <code>gte</code> · <code>lt</code> · <code>lte</code>
section: 10
crumb: gt · gte · lt · lte
prev: add.html
prevLabel: add
next: delay.html
nextLabel: delay &amp; sleep
---
  <p class="hero-sub">Comparaciones data-first, como valores de función en lugar de operadores.</p>

  {{signature}}

  <h2>Lección</h2>
  <p>
    <code>gt</code>, <code>gte</code>, <code>lt</code> y <code>lte</code>
    son los cuatro operadores de orden empaquetados como funciones
    <strong>data-first</strong>: <code>gt(a, b) == (a &gt; b)</code>, con el primer
    argumento a la izquierda, exactamente igual que el operador. Eso los
    convierte en comparadores listos para usar allí donde una API espera una
    función en vez de un operador infijo.
  </p>
  <p>
    Por dentro exigen que ambos valores sean mutuamente
    <code>Comparable</code> y — con una excepción — del mismo tipo exacto en
    tiempo de ejecución: <code>num</code> con <code>num</code> y
    <code>String</code> con <code>String</code> sí pueden mezclarse (así que
    un <code>int</code> puede compararse con un <code>double</code>), pero
    cualquier otra combinación de tipos distintos lanza un
    <code>ArgumentError</code> en lugar de convertir en silencio.
  </p>
  <p>
    Ninguna de las cuatro está currificada — no existe la aplicación parcial
    <code>gt(5)</code>. Para obtener un predicado unario reutilizable (por
    ejemplo, para <code>filter</code>), escribe un pequeño closure que fije
    uno de los lados: <code>(b) =&gt; gt(b, 5)</code>.
  </p>

  <h2>Demo 1 · Fundamentos, y el error por tipos incompatibles</h2>
  {{playground:0}}

  <h2>Demo 2 · Currificar en un predicado para filter</h2>
  {{playground:1}}

  <h2>Pruébalo tú</h2>
  <p>Ejercicio: quédate solo con las edades que son <code>gte</code> 18 (adultos).</p>
  {{playground:2}}

  <div class="callout">
    <strong>Relacionado:</strong>
    <a href="add.html"><code>add</code></a> — la contraparte aritmética de estas comparaciones ·
    <a href="sort.html"><code>sort</code></a> / <a href="sortBy.html"><code>sortBy</code></a> — construye un comparador a partir de lt/gt ·
    <a href="min.html"><code>min</code></a> / <a href="max.html"><code>max</code></a> — las versiones agregadas de estas comparaciones ·
    <a href="negate.html"><code>negate</code></a> — invierte un predicado de comparación currificado
  </div>
