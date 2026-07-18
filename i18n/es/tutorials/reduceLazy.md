---
slug: reduceLazy
title: reduceLazy — FxDart 101
description: Tutorial de reduceLazy en FxDart: construye una función reductora reutilizable que puedes aplicar a muchos iterables, con un playground en vivo.
heading: <code>reduceLazy</code>
section: 7
crumb: reduceLazy
prev: fold.html
prevLabel: fold
next: sum.html
nextLabel: sum
---
  <p class="hero-sub">Currifica el valor inicial y el combinador de fold en una función reductora reutilizable.</p>

  {{signature}}

  <h2>Lección</h2>
  <p>
    <code>reduceLazy</code> no reduce nada por sí mismo: lo que hace es
    <strong>construir un reductor</strong>. Le das una función de combinación y
    un valor inicial, y recibes de vuelta una función corriente de tipo
    <code>Iterable&lt;A&gt; Function</code> que puedes llamar tantas veces como
    quieras, sobre tantos iterables distintos como quieras, sin repetir cada
    vez el valor inicial y el combinador.
  </p>
  <p>
    Por dentro es solo una envoltura fina sobre
    <code><a href="fold.html">fold</a></code>:
    <code>reduceLazy(f, seed)</code> devuelve
    <code>(iterable) =&gt; fold(seed, f, iterable)</code>. Fíjate en que el
    orden de los argumentos se invierte respecto a <code>fold</code>: aquí es
    <code>(f, seed)</code>, siguiendo el estilo currificado de FxTS, donde el
    iterable se deja deliberadamente para más tarde.
  </p>
  <p>
    Esta es una función Dart corriente (sin currificación más allá de esto),
    así que no tiene método de cadena <code>Fx</code> ni contraparte
    <code>*Async</code>. Pero la función que devuelve acepta cualquier cosa que
    implemente <code>Iterable&lt;A&gt;</code>, lo que incluye a
    <code>Fx&lt;A&gt;</code>. Es decir, puedes pasarla directamente a
    <code>.to(...)</code> sobre una cadena.
  </p>

  <h2>Demo 1 · Un sumador reutilizable</h2>
  {{playground:0}}

  <h2>Demo 2 · Reutilizado sobre listas distintas</h2>
  <p>La gracia está en definir el "cómo combinar" una sola vez y reutilizarlo en todas partes:</p>
  {{playground:1}}

  <h2>Pruébalo tú</h2>
  <p>Ejercicio: construye con <code>reduceLazy</code> un reductor reutilizable que encuentre el valor <strong>máximo</strong>.</p>
  {{playground:2}}

  <div class="callout">
    <strong>Relacionado:</strong>
    <a href="fold.html"><code>fold</code></a> — el reductor con valor inicial al que envuelve ·
    <a href="reduce.html"><code>reduce</code></a> — el terminal sin valor inicial ·
    <a href="pipe.html"><code>pipe</code></a> — compón funciones como esta en un pipeline ·
    <a href="memoize.html"><code>memoize</code></a> — otra forma de construir una función reutilizable
  </div>
