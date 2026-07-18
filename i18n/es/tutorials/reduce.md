---
slug: reduce
title: reduce — FxDart 101
description: Tutorial de reduce en FxDart: colapsa un pipeline en un solo valor usando su primer elemento como valor inicial, con un playground en vivo.
heading: <code>reduce</code>
section: 7
crumb: reduce
prev: fork.html
prevLabel: fork
next: fold.html
nextLabel: fold
---
  <p class="hero-sub">Colapsa un pipeline en un único valor, usando su primer elemento como valor inicial.</p>

  {{signature}}

  <h2>Lección</h2>
  <p>
    <code>reduce</code> es un operador <strong>terminal</strong>: a diferencia
    de <code>map</code> o <code>filter</code>, llamarlo tira de inmediato de
    todos los valores a través de todo el pipeline perezoso que tiene detrás y
    produce un resultado concreto. Nada de lo que hay aguas arriba se ejecuta
    hasta que llamas a un terminal como este.
  </p>
  <p>
    Esta es la forma <em>sin valor inicial</em>: toma el primer elemento del
    iterable como acumulador de partida y va combinando el resto sobre él. Por
    eso mismo, llamarlo sobre un iterable vacío no tiene sentido —no hay primer
    elemento del que partir— y por tanto lanza un <code>StateError</code>.
  </p>
  <p>
    FxTS sobrecarga <code>reduce</code> para los casos con y sin valor inicial
    según el número de argumentos: <code>reduce(f, iterable)</code> frente a
    <code>reduce(f, seed, iterable)</code>. Dart no tiene sobrecarga por
    aridad, así que FxDart reserva <code>reduce</code> para la forma sin valor
    inicial y renombra la otra como <code><a href="fold.html">fold</a></code>,
    siguiendo la nomenclatura del propio <code>Iterable.fold</code> de Dart. Si
    tienes un valor inicial, usa <code>fold</code>.
  </p>
  <p>
    En la cadena síncrona, <code>Fx</code> extiende <code>Iterable</code>, así
    que <code>.reduce(f)</code> es simplemente el método integrado de Dart:
    mismo contrato, mismo <code>StateError</code> cuando está vacío. En la
    cadena asíncrona, <code>FxAsync.reduce</code> está escrito de forma
    explícita y espera cada paso de combinación.
  </p>

  <h2>Demo 1 · Fundamentos &amp; el error con entrada vacía</h2>
  {{playground:0}}

  <h2>Demo 2 · Asíncrono, con concurrencia</h2>
  <p>
    <code>reduce</code> sigue tirando de todo el pipeline que tiene detrás,
    incluida una etapa <code>.concurrent(n)</code>, que evalúa <code>n</code>
    valores aguas arriba a la vez mientras <code>reduce</code> los combina
    conforme van llegando en orden:
  </p>
  {{playground:1}}

  <h2>Pruébalo tú</h2>
  <p>Ejercicio: usa <code>reduce</code> para encontrar la palabra <strong>más larga</strong> de la lista.</p>
  {{playground:2}}

  <div class="callout">
    <strong>Relacionado:</strong>
    <a href="fold.html"><code>fold</code></a> — la contraparte con valor inicial ·
    <a href="reduceLazy.html"><code>reduceLazy</code></a> — un reductor currificado y reutilizable ·
    <a href="sum.html"><code>sum</code></a> — reduce especializado para números ·
    <a href="concurrent.html"><code>concurrent</code></a> — evaluación paralela aguas arriba
  </div>
