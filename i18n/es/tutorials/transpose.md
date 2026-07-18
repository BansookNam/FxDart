---
slug: transpose
title: transpose — FxDart 101
description: Tutorial de transpose en FxDart: convierte filas en columnas para cualquier número de iterables, con playground en vivo.
heading: <code>transpose</code>
section: 6
crumb: transpose
prev: zipWithIndex.html
prevLabel: zipWithIndex
next: reverse.html
nextLabel: reverse
---
  <p class="hero-sub">Convierte una colección de filas en una colección de columnas.</p>

  {{signature}}

  <h2>Lección</h2>
  <p>
    <code>transpose</code> es <code>zip</code> generalizado a <em>cualquier</em>
    número de iterables: la n-ésima lista de salida contiene el n-ésimo
    elemento de cada fila de entrada que aún tenga uno. Mientras que
    <code>zip</code>/<code>zip3</code> toman cada fila como un argumento
    aparte (porque Dart no puede expresar genéricos variádicos),
    <code>transpose</code> toma todas las filas como un
    <strong>único</strong> iterable de iterables —
    <code>transpose([row1, row2, row3])</code> — así que funciona para
    cualquier número de filas decidido en tiempo de ejecución.
  </p>
  <p>
    A diferencia de <code>zip</code>, que para en cuanto se agota la entrada
    más corta, <code>transpose</code> sigue mientras <em>alguna</em> fila
    todavía tenga valores: una fila más corta simplemente deja de contribuir a
    las listas de salida posteriores, que pueden acabar siendo más cortas que
    el número de filas. Solo se detiene del todo cuando se han agotado todas
    las filas.
  </p>

  <h2>Demo 1 · Fundamentos &amp; filas desiguales</h2>
  {{playground:0}}

  <h2>Demo 2 · Asíncrono</h2>
  {{playground:1}}

  <h2>Pruébalo tú</h2>
  <p>Ejercicio: transpón la matriz (las filas pasan a ser columnas).</p>
  {{playground:2}}

  <div class="callout">
    <strong>Relacionado:</strong>
    <a href="zip.html"><code>zip</code></a> — el caso particular de dos filas ·
    <a href="chunk.html"><code>chunk</code></a> — agrupa antes una fuente plana en filas ·
    <a href="reverse.html"><code>reverse</code></a>
  </div>
