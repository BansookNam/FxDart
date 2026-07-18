---
slug: omitBy
title: omitBy — FxDart 101
description: Tutorial de omitBy en FxDart: descarta las entradas de un Map que cumplan un predicado sobre (clave, valor).
heading: <code>omitBy</code>
section: 9
crumb: omitBy
prev: pick.html
prevLabel: pick
next: pickBy.html
nextLabel: pickBy
---
  <p class="hero-sub">Devuelve una copia de un <code>Map</code> sin las entradas que cumplan un predicado.</p>

  {{signature}}

  <h2>Lección</h2>
  <p>
    Mientras que <code>omit</code> recibe una lista fija de claves,
    <code>omitBy</code> recibe un predicado y decide entrada por entrada. El
    predicado recibe la entrada completa como un record <code>(K, V)</code>,
    así que tienes a mano tanto la clave como el valor: se leen con
    <code>e.$1</code> (clave) y <code>e.$2</code> (valor). Es la misma
    representación que <code>entries(map)</code> le da a un <code>Map</code>
    en el resto de la librería.
  </p>
  <p>
    Úsalo siempre que lo que quieras descartar venga definido por una
    condición —"quitar las notas suspensas", "quitar los artículos sin
    stock"— en lugar de por un conjunto fijo de nombres de clave.
  </p>

  <h2>Demo 1 · Fundamentos</h2>
  {{playground:0}}

  <h2>Demo 2 · Descartar por una condición sobre el valor</h2>
  {{playground:1}}

  <h2>Pruébalo tú</h2>
  <p>Ejercicio: usa <code>omitBy</code> para descartar las entradas cuyo valor sea <code>false</code>.</p>
  {{playground:2}}

  <div class="callout">
    <strong>Relacionado:</strong>
    <a href="pickBy.html"><code>pickBy</code></a> — el inverso: conservar según un predicado ·
    <a href="omit.html"><code>omit</code></a> — descartar según una lista fija de claves ·
    <a href="isMatch.html"><code>isMatch</code></a> — un predicado profundo ya hecho para entradas ·
    <a href="evolve.html"><code>evolve</code></a> — transformar los valores en lugar de descartarlos
  </div>
