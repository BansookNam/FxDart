---
slug: countWhere
title: countWhere — FxDart 101
description: Tutorial de countWhere en FxDart — cuenta los valores que cumplen la condición en una sola pasada, filter y size fusionados. Con playground en vivo.
heading: <code>countWhere</code>
section: 7
crumb: countWhere
prev: foldBy.html
prevLabel: foldBy
next: sort.html
nextLabel: sort
---
  <p class="hero-sub">¿Cuántos cumplen? Una pasada, un número — <code>filter</code> + <code>size</code>, fusionados.</p>

  {{signature}}

  <h2>Lección</h2>
  <p>
    «¿Cuántos de estos están vencidos / en oferta / son pares?» se seguía
    escribiendo como <code>filter(pred).size()</code> — dos pasos de cadena
    y un intermedio perezoso para lo que conceptualmente es un solo fold.
    <code>countWhere(pred)</code> es ese fold: recorre el pipeline una vez,
    incrementa en cada coincidencia y devuelve el conteo. Nada se
    materializa por el camino.
  </p>
  <p>
    Usa <code><a href="countBy.html">countBy</a></code> cuando quieras
    conteos <em>por clave</em> (un mapa de ellos), y
    <code>countWhere</code> cuando el conteo de un solo predicado sea toda
    la respuesta. El gemelo async espera su predicado por elemento, como
    todo operador <code>*Async</code>.
  </p>
  <p>
    Adición nativa de Dart — la forma del <code>count { }</code> de Kotlin.
  </p>

  <h2>Demo 1 · Un predicado, un número</h2>
  {{playground:0}}

  <h2>Demo 2 · Async</h2>
  {{playground:1}}

  <h2>Pruébalo tú</h2>
  <p>Ejercicio: cuenta los precios de respaldo sin un <code>filter</code>.</p>
  {{playground:2}}

  <div class="callout">
    <strong>Relacionados:</strong>
    <a href="countBy.html"><code>countBy</code></a> — conteos por clave ·
    <a href="count.html"><code>size</code>/<code>count</code></a> — contarlo todo ·
    <a href="filter.html"><code>filter</code></a> — cuando necesitas las coincidencias en sí
  </div>
