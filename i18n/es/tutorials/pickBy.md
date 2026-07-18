---
slug: pickBy
title: pickBy — FxDart 101
description: Tutorial de pickBy en FxDart: conserva solo las entradas de un Map que cumplen un predicado sobre (clave, valor).
heading: <code>pickBy</code>
section: 9
crumb: pickBy
prev: omitBy.html
prevLabel: omitBy
next: prop.html
nextLabel: prop
---
  <p class="hero-sub">Devuelve una copia de un <code>Map</code> únicamente con las entradas que cumplen un predicado.</p>

  {{signature}}

  <h2>Lección</h2>
  <p>
    <code>pickBy</code> es el espejo de <code>omitBy</code> y comparte su
    convención de llamada: el predicado recibe un registro
    <code>(K, V)</code> por entrada, así que usa <code>e.$1</code> para la
    clave y <code>e.$2</code> para el valor. Solo sobreviven en el
    resultado las entradas para las que el predicado devuelve
    <code>true</code>.
  </p>
  <p>
    Un uso habitual: reducir un mapa de configuración o de feature flags a
    "los que importan ahora mismo" — flags activos, claves con un prefijo
    determinado, valores por encima de un umbral — sin escribir a mano un
    bucle entrada por entrada.
  </p>

  <h2>Demo 1 · Fundamentos</h2>
  {{playground:0}}

  <h2>Demo 2 · Filtrar por clave</h2>
  {{playground:1}}

  <h2>Pruébalo tú</h2>
  <p>Ejercicio: usa <code>pickBy</code> para conservar solo las entradas cuyo valor sea <code>true</code>.</p>
  {{playground:2}}

  <div class="callout">
    <strong>Relacionado:</strong>
    <a href="omitBy.html"><code>omitBy</code></a> — el inverso: descarta por predicado ·
    <a href="pick.html"><code>pick</code></a> — conserva según una lista fija de claves ·
    <a href="matches.html"><code>matches</code></a> — un predicado ya hecho para comparar formas ·
    <a href="compactObject.html"><code>compactObject</code></a> — un pickBy especializado en "descartar nulls"
  </div>
