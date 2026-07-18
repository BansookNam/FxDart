---
slug: map
title: map — FxDart 101
description: Tutorial de map en FxDart: transforma cada elemento de un pipeline perezoso, en sync y en async, con un playground en vivo.
heading: <code>map</code>
section: 3
crumb: map
next: mapEffect.html
nextLabel: mapEffect
---
  <p class="hero-sub">Devuelve un iterable perezoso con los valores que resultan de pasar cada elemento por una función.</p>

  {{signature}}

  <h2>Lección</h2>
  <p>
    <code>map</code> es el transformador más fundamental: aplica una función
    a cada elemento. En FxDart es <strong>perezoso</strong> — llamar a
    <code>map</code> no hace absolutamente nada de trabajo. La función solo se
    ejecuta cuando un operador terminal (<code>toArray</code>,
    <code>each</code>, <code>reduce</code>, …) tira de los valores a través
    del pipeline. Eso significa que puedes hacer <code>map</code> sobre una
    secuencia enorme — incluso infinita — mientras solo pidas lo que
    necesitas.
  </p>
  <p>
    Viene en forma data-first (<code>map(f, iterable)</code>) y como método de
    cadena (<code>fx(iterable).map(f)</code>). Ambas devuelven el mismo
    resultado perezoso.
  </p>

  <h2>Demo 1 · Fundamentos &amp; pereza</h2>
  <p>Fíjate en que la función de mapeo solo se ejecuta para los 3 valores que
    <code>take(3)</code> pide — de un millón:</p>
  {{playground:0}}

  <h2>Demo 2 · Asíncrono, con concurrencia</h2>
  <p>
    <code>mapAsync</code> (o <code>.toAsync().map(...)</code>) acepta una
    función asíncrona. Por sí sola espera cada elemento en orden; añade
    <code>concurrent(n)</code> y el pipeline anterior evalúa <code>n</code>
    elementos a la vez — los resultados siguen llegando en orden:
  </p>
  {{playground:1}}

  <h2>Pruébalo tú</h2>
  <p>Ejercicio: usa <code>map</code> para convertir esta lista de maps en una
    lista de nombres formateados como <code>"KIM (32)"</code>.</p>
  {{playground:2}}

  <div class="callout">
    <strong>Relacionado:</strong>
    <a href="mapEffect.html"><code>mapEffect</code></a> — igual que map, pero señala efectos secundarios ·
    <a href="flatMap.html"><code>flatMap</code></a> — map + aplanado ·
    <a href="peek.html"><code>peek</code></a> — observar sin transformar ·
    <a href="concurrent.html"><code>concurrent</code></a> — evaluación en paralelo
  </div>
