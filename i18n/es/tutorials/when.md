---
slug: when
title: when — FxDart 101
description: Tutorial de when en FxDart: aplica una transformación solo cuando se cumple un predicado y, si no, deja pasar el valor tal cual, con un playground en vivo.
heading: <code>when</code>
section: 10
crumb: when
prev: not.html
prevLabel: not
next: unless.html
nextLabel: unless
---
  <p class="hero-sub">Aplica un callback cuando se cumple un predicado; si no, devuelve el valor sin cambios.</p>

  {{signature}}

  <h2>Lección</h2>
  <p>
    <code>when(predicate, callback, value)</code> es un único condicional
    expresado como datos: si <code>predicate(value)</code> es verdadero, el
    resultado es <code>callback(value)</code>; si no, el resultado es el
    propio <code>value</code>, intacto. Se lee muy bien dentro de un callback
    de <code>map</code> cuando quieres transformar solo los elementos que lo
    necesitan y dejar el resto en paz.
  </p>
  <p>
    La versión de FxTS puede ampliar el tipo de retorno a una unión
    <code>T | R</code> cuando las ramas no coinciden. Dart no tiene tipos
    de unión, así que tanto la rama del <code>callback</code> como la de paso
    directo deben compartir el mismo tipo <code>T</code>; si de verdad
    necesitas tipos de resultado distintos, recurre a
    <a href="cases.html"><code>cases</code></a>, que sí permite que
    <code>R</code> difiera del tipo de entrada.
  </p>

  <h2>Demo 1 · Fundamentos</h2>
  {{playground:0}}

  <h2>Demo 2 · Acotar valores en un pipeline</h2>
  {{playground:1}}

  <h2>Pruébalo tú</h2>
  <p>Ejercicio: usa <code>when</code> para duplicar solo los precios
    positivos, dejando los negativos intactos.</p>
  {{playground:2}}

  <div class="callout">
    <strong>Relacionado:</strong>
    <a href="unless.html"><code>unless</code></a> — el hermano de when con la condición invertida ·
    <a href="cases.html"><code>cases</code></a> — varios predicados y un tipo de resultado distinto ·
    <a href="not.html"><code>not</code></a> / <a href="negate.html"><code>negate</code></a> — construir el predicado que le pasas ·
    <a href="map.html"><code>map</code></a> — el sitio habitual donde usar when como callback
  </div>
