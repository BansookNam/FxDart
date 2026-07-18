---
slug: isMatch
title: isMatch — FxDart 101
description: Tutorial de isMatch en FxDart: coincidencia parcial y profunda contra un patrón de Map o de lista.
heading: <code>isMatch</code>
section: 9
crumb: isMatch
prev: resolveProps.html
prevLabel: resolveProps
next: matches.html
nextLabel: matches
---
  <p class="hero-sub">Coincidencia parcial profunda: ¿contiene <code>target</code> todo lo que describe <code>pattern</code>?</p>

  {{signature}}

  <h2>Lección</h2>
  <p>
    <code>isMatch</code> recorre <code>pattern</code> de forma recursiva y comprueba
    que <code>target</code> lo "contiene", con reglas distintas según la forma:
  </p>
  <p>
    Los <strong>Map</strong> coinciden parcialmente: cada clave de <code>pattern</code>
    debe existir en <code>target</code> con un valor que coincida recursivamente, pero
    <code>target</code> puede tener claves <em>de más</em> que el patrón
    no menciona. Las <strong>listas/iterables</strong> se comparan por pares desde
    el principio, y aquí está el detalle que conviene recordar: el patrón solo
    tiene que ser un <strong>prefijo</strong> del target. <code>[1, 2, 3]</code>
    coincide con el patrón <code>[1, 2]</code>, pero <em>no</em> con el patrón
    <code>[1, 2, 3, 4]</code> — el patrón no puede ser más largo que el target.
    Cualquier otra cosa (números, cadenas, booleanos, …) se compara con un
    <code>==</code> normal.
  </p>
  <p>
    Como las reglas anidan, la coincidencia profunda te sale casi gratis: un
    patrón como <code>{'address': {'city': 'seoul'}}</code> coincide con un map
    de usuario con un valor <code>address</code> mucho más grande y anidado,
    siempre que <code>city</code> sea <code>'seoul'</code> en algún punto dentro de él.
  </p>

  <h2>Demo 1 · Coincidencia de Map</h2>
  {{playground:0}}

  <h2>Demo 2 · Coincidencia por prefijo en listas, y filtrar con ella</h2>
  {{playground:1}}

  <h2>Pruébalo tú</h2>
  <p>Ejercicio: usa <code>isMatch</code> para comprobar si <code>order</code> coincide con <code>{'status': 'shipped'}</code>.</p>
  {{playground:2}}

  <div class="callout">
    <strong>Relacionado:</strong>
    <a href="matches.html"><code>matches</code></a> — la versión currificada de esto, lista para filtrar ·
    <a href="pickBy.html"><code>pickBy</code></a> — suele acompañarla para filtrar por forma ·
    <a href="find.html"><code>find</code></a> — localiza el primer elemento que coincide ·
    <a href="omitBy.html"><code>omitBy</code></a> — descarta entradas según un predicado
  </div>
