---
slug: partition
title: partition — FxDart 101
description: Tutorial de partition en FxDart: divide un pipeline en un record (los que pasan, los que no) según un predicado, con playground en vivo.
heading: <code>partition</code>
section: 7
crumb: partition
prev: sortBy.html
prevLabel: sortBy
next: head.html
nextLabel: head
---
  <p class="hero-sub">Divide un pipeline en dos listas de una sola vez, con un único predicado.</p>

  {{signature}}

  <h2>Lección</h2>
  <p>
    <code>partition</code> es un operador terminal que recorre el pipeline
    una sola vez y reparte cada elemento en una de dos listas según un
    predicado: los elementos para los que el predicado devuelve
    <code>true</code> van a la primera lista, y todo lo demás a la segunda.
    Equivale a llamar por separado a
    <code><a href="filter.html">filter</a></code> y
    <code><a href="reject.html">reject</a></code>, pero en una sola pasada
    sobre los datos.
  </p>
  <p>
    FxTS devuelve una tupla de dos elementos, <code>[pass, fail]</code>. Dart
    no tiene un tipo tupla integrado al estilo de los arrays de JS, así que
    FxDart usa un <strong>record</strong> nativo de Dart:
    <code>(List&lt;A&gt;, List&lt;A&gt;)</code>. Accede a las dos listas con
    <code>.$1</code> (los que pasan) y <code>.$2</code> (los que no), o
    desestructúralas directamente con la sintaxis de patrones:
    <code>final (pass, fail) = partition(f, iterable);</code>. Es la misma
    convención de tupla a record que usan
    <code><a href="zip.html">zip</a></code> y
    <code><a href="entries.html">entries</a></code> en el resto de FxDart.
  </p>
  <p>
    Como todos los terminales de esta sección, tira de todo el pipeline
    perezoso que tenga aguas arriba, sea síncrono o asíncrono.
  </p>

  <h2>Demo 1 · Fundamentos y desestructuración</h2>
  {{playground:0}}

  <h2>Demo 2 · Asíncrono</h2>
  {{playground:1}}

  <h2>Pruébalo tú</h2>
  <p>Ejercicio: reparte las notas en <strong>aprobadas</strong> (&gt;= 60) y <strong>suspensas</strong> (&lt; 60).</p>
  {{playground:2}}

  <div class="callout">
    <strong>Relacionado:</strong>
    <a href="filter.html"><code>filter</code></a> · <a href="reject.html"><code>reject</code></a> — las dos mitades que partition combina ·
    <a href="groupBy.html"><code>groupBy</code></a> — agrupar en más de dos cubetas ·
    <a href="sort.html"><code>sort</code></a> — ordenar dentro de cada lado, si lo necesitas
  </div>
