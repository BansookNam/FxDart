---
slug: mapValues
title: mapValues, mapKeys &amp; mapEntries — FxDart 101
description: Tutorial de mapValues en FxDart: transforma cada valor, clave o entrada completa de un Map, con playground en vivo.
heading: <code>mapValues</code> &amp; friends
section: 9
crumb: mapValues
prev: props.html
prevLabel: props
next: evolve.html
nextLabel: evolve
---
  <p class="hero-sub">Transforma cada valor, cada clave o la entrada <code>(clave, valor)</code> completa de un map.</p>

  {{signature}}

  <h2>Lección</h2>
  <p>
    El resto de la sección 9 <em>selecciona</em> de un map —
    <a href="pick.html"><code>pick</code></a>,
    <a href="omit.html"><code>omit</code></a>,
    <a href="pickBy.html"><code>pickBy</code></a>,
    <a href="omitBy.html"><code>omitBy</code></a> — o lee una parte de él.
    Estos tres lo <em>transforman</em>. <code>mapValues</code> pasa cada valor
    por un callback y deja las claves en paz, <code>mapKeys</code> hace lo
    contrario, y <code>mapEntries</code> toma el record
    <code>(clave, valor)</code> entero y devuelve uno nuevo.
  </p>
  <p>
    Ese record tiene la misma forma que ya usan <code>pickBy</code>,
    <code>omitBy</code> y
    <a href="fromEntries.html"><code>fromEntries</code></a>, así que los
    cuatro componen sin adaptadores: filtras con uno y transformas con el
    otro. <code>mapEntries</code> generaliza a los otros dos: intercambiar
    <code>e.$1</code> y <code>e.$2</code> invierte un map en una sola llamada.
  </p>
  <p>
    <code>mapValues</code> no puede perder ninguna entrada, porque las claves
    quedan intactas. <code>mapKeys</code> y <code>mapEntries</code> sí pueden:
    si el callback lleva dos claves al mismo resultado, gana la
    <strong>última</strong> en orden de iteración, exactamente como haría una
    clave repetida en un literal de map. Por lo demás el orden de inserción
    sobrevive, siguiendo la primera aparición de cada clave nueva.
  </p>
  <p>
    Aquí no hay <code>filter</code> ni <code>filterWithKey</code>, y es
    deliberado. <code>pickBy</code> y <code>omitBy</code> ya toman el record
    completo, así que ignorar una mitad es la forma de filtrar por la otra;
    míralo en la segunda demo.
  </p>
  <p>
    Compara con <a href="evolve.html"><code>evolve</code></a>, aquí al lado:
    transforma los valores de claves <em>concretas</em> y deja pasar el resto.
    <code>mapValues</code> es el caso en que todos los valores reciben el
    mismo trato.
  </p>

  <h2>Demo 1 · Fundamentos</h2>
  {{playground:0}}

  <h2>Demo 2 · Colisiones, y filtrar al lado</h2>
  {{playground:1}}

  <h2>Pruébalo tú</h2>
  <p>Ejercicio: convierte cada puntuación en una nota con letra, conservando los nombres.</p>
  {{playground:2}}

  <div class="callout">
    <strong>Relacionado:</strong>
    <a href="evolve.html"><code>evolve</code></a> — transforma solo los valores de las claves indicadas ·
    <a href="pickBy.html"><code>pickBy</code></a> / <a href="omitBy.html"><code>omitBy</code></a> — los filtros que conocen la clave, con el mismo record ·
    <a href="fromEntries.html"><code>fromEntries</code></a> — construye un map a partir de records ·
    <a href="compactObject.html"><code>compactObject</code></a> — quita los valores null
  </div>
