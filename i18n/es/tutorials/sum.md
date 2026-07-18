---
slug: sum
title: sum — FxDart 101
description: Tutorial de sum en FxDart: suma todos los números de un pipeline, con un playground en vivo.
heading: <code>sum</code>
section: 7
crumb: sum
prev: reduceLazy.html
prevLabel: reduceLazy
next: average.html
nextLabel: average
---
  <p class="hero-sub">Suma todos los números que produce un pipeline perezoso.</p>

  {{signature}}

  <h2>Lección</h2>
  <p>
    <code>sum</code> es un operador terminal y uno de los pliegues
    especializados más simples de la librería: por dentro es literalmente
    <code>fold(0, (a, b) =&gt; a + b, iterable)</code>. Como todo operador
    terminal, llamarlo tira de todo el pipeline perezoso que tiene por encima:
    puedes montar una cadena elaborada de pasos <code>map</code>/<code>filter</code>
    y solo pagas por los valores que <code>sum</code> realmente necesita, que
    son todos.
  </p>
  <p>
    Como el valor inicial es <code>0</code>, sumar un iterable vacío da
    <code>0</code>: ni error, ni <code>NaN</code>. Eso lo diferencia de sus
    vecinos <code><a href="min.html">min</a></code>,
    <code><a href="max.html">max</a></code> y
    <code><a href="average.html">average</a></code>, cada uno con su propio
    comportamiento (¡sorprendente!) ante entradas vacías, que conviene conocer.
  </p>
  <p>
    La forma encadenada está disponible como método de extensión,
    <code>Fx&lt;num&gt;.sum()</code> / <code>FxAsync&lt;num&gt;.sum()</code>:
    solo aparece cuando el tipo de elemento de tu cadena se sabe que es
    <code>num</code> (o <code>int</code>/<code>double</code>, gracias a la
    covarianza de los genéricos).
  </p>

  <h2>Demo 1 · Fundamentos</h2>
  {{playground:0}}

  <h2>Demo 2 · Asíncrono</h2>
  {{playground:1}}

  <h2>Pruébalo tú</h2>
  <p>Ejercicio: suma solo los números <strong>pares</strong> de la lista.</p>
  {{playground:2}}

  <div class="callout">
    <strong>Relacionado:</strong>
    <a href="average.html"><code>average</code></a> — la suma dividida entre la cantidad ·
    <a href="fold.html"><code>fold</code></a> — la forma general que sum especializa ·
    <a href="min.html"><code>min</code></a> · <a href="max.html"><code>max</code></a> — los otros terminales numéricos
  </div>
