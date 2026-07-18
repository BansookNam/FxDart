---
slug: prop
title: prop — FxDart 101
description: Tutorial de prop en FxDart: lee una sola clave de un Map como función reutilizable, con null cuando no existe.
heading: <code>prop</code>
section: 9
crumb: prop
prev: pickBy.html
prevLabel: pickBy
next: props.html
nextLabel: props
---
  <p class="hero-sub">Devuelve el valor de una clave de un <code>Map</code>, o <code>null</code> si no existe.</p>

  {{signature}}

  <h2>Lección</h2>
  <p>
    Por sí solo, <code>prop('name', user)</code> hace exactamente lo mismo que
    <code>user['name']</code> en Dart: si la clave falta, en ambos casos sale
    <code>null</code>. La razón de que exista como función es la
    componibilidad: <code>map[key]</code> es un operador, no un valor que
    puedas pasar por ahí, mientras que <code>(m) => prop('name', m)</code> es
    una función unaria normal que puedes entregar a <code>map</code>, a
    <code>juxt</code>, a los callbacks de <code>evolve</code> o a
    cualquier sitio donde se espere un <code>Function(Map)</code>.
  </p>
  <p>
    Si lo que quieres de verdad es extraer un campo de una <em>lista</em>
    entera de mapas, tira de <a href="pluck.html"><code>pluck</code></a>: es
    <code>prop</code> ya fijado a una clave y aplicado con map sobre toda la
    colección en una sola llamada.
  </p>

  <h2>Demo 1 · Fundamentos</h2>
  {{playground:0}}

  <h2>Demo 2 · Como función suelta, frente a <code>pluck</code></h2>
  {{playground:1}}

  <h2>Pruébalo tú</h2>
  <p>Ejercicio: usa <code>prop</code> para leer <code>'theme'</code>, o <code>'light'</code> si no está.</p>
  {{playground:2}}

  <div class="callout">
    <strong>Relacionado:</strong>
    <a href="props.html"><code>props</code></a> — lee varias claves a la vez ·
    <a href="pluck.html"><code>pluck</code></a> — <code>prop</code> aplicado con map sobre toda una lista ·
    <a href="pick.html"><code>pick</code></a> — conserva varias claves como Map ·
    <a href="evolve.html"><code>evolve</code></a> — transforma un valor in situ
  </div>
