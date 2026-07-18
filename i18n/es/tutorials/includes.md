---
slug: includes
title: includes — FxDart 101
description: Tutorial de includes en FxDart: comprueba la pertenencia en un iterable usando ==, con cortocircuito, en versión síncrona y asíncrona.
heading: <code>includes</code>
section: 8
crumb: includes
prev: findIndex.html
prevLabel: findIndex
next: isEmpty.html
nextLabel: isEmpty
---
  <p class="hero-sub">Devuelve true cuando un iterable contiene un valor, comparado con <code>==</code>.</p>

  {{signature}}

  <h2>Lección</h2>
  <p>
    <code>includes</code> es una envoltura fina con la forma de FxTS: en el
    lado síncrono es literalmente <code>iterable.contains(a)</code>, así que
    no hay un método de cadena aparte — <code>Fx</code> ya hereda
    <code>.contains()</code> de <code>Iterable</code> y se comporta igual. La
    versión asíncrona, <code>includesAsync</code>, está construida sobre
    <a href="some.html"><code>someAsync</code></a> (con <code>b == a</code>
    como predicado), lo que significa que hereda el mismo cortocircuito: deja
    de tirar de la fuente en cuanto encuentra una coincidencia.
  </p>
  <p>
    La igualdad se comprueba con el <code>==</code> de Dart, así que respeta
    cualquier sobrecarga de <code>operator ==</code> en tus propias clases —
    no se limita a los tipos primitivos.
  </p>

  <h2>Demo 1 · Fundamentos</h2>
  {{playground:0}}

  <h2>Demo 2 · Async, y la prueba del cortocircuito</h2>
  <p>Solo se piden 2 de los 5 elementos antes de que <code>includesAsync</code> se detenga:</p>
  {{playground:1}}

  <h2>Pruébalo tú</h2>
  <p>Ejercicio: usa <code>includes</code> para comprobar si <code>requestId</code> está permitido.</p>
  {{playground:2}}

  <div class="callout">
    <strong>Relacionado:</strong>
    <a href="some.html"><code>some</code></a> — la base sobre la que se construye <code>includesAsync</code> ·
    <a href="find.html"><code>find</code></a> — obtén el valor coincidente, no solo un bool ·
    <a href="findIndex.html"><code>findIndex</code></a> — obtén la posición en su lugar ·
    <a href="isEmpty.html"><code>isEmpty</code></a> — la otra comprobación basada en valores que tienes cerca
  </div>
