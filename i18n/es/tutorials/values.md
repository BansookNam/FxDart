---
slug: values
title: values — FxDart 101
description: Tutorial de values en FxDart: un Iterable perezoso con los valores de un Map, listo para alimentar una cadena.
heading: <code>values</code>
section: 2
crumb: values
prev: keys.html
prevLabel: keys
next: map.html
nextLabel: map
---
  <p class="hero-sub">Los valores de un Map, como un Iterable perezoso normal — listo para envolver con fx() y encadenar.</p>

  {{signature}}

  <h2>Lección</h2>
  <p>
    <code>values(map)</code> es el gemelo de <code>keys</code>: un envoltorio
    fino sobre el <code>map.values</code> de Dart, con un nombre coherente con
    el resto del vocabulario de funciones de objeto, para que se lea con
    naturalidad como <code>fx(values(map))</code> junto a
    <code>fx(keys(map))</code> y <code>fx(entries(map))</code>. Igual que el
    propio <code>map.values</code>, ya es una vista perezosa: no añade ningún
    búfer extra.
  </p>
  <p>
    Como te devuelve un <code>Iterable&lt;V&gt;</code> normal, se le aplican
    directamente todos los operadores de cadena que has aprendido hasta ahora
    — incluidos los terminales numéricos (<code>sum()</code>,
    <code>average()</code>, <code>min()</code>, <code>max()</code>) cuando
    <code>V</code> es un <code>num</code>. Eso convierte a <code>values</code>
    en el punto de entrada natural para agregar los datos de un Map: sumar
    precios, promediar puntuaciones, encontrar la marca de tiempo más
    reciente, etc.
  </p>
  <p>
    Esta es además la última parada antes de <code>map</code> en sí — la
    siguiente lección, y el operador al que recurrirás constantemente de aquí
    en adelante para transformar lo que te entreguen <code>values</code>,
    <code>entries</code> o cualquier otra fuente.
  </p>

  <h2>Demo 1 · Fundamentos</h2>
  {{playground:0}}

  <h2>Demo 2 · Agregar los valores de un Map</h2>
  {{playground:1}}

  <h2>Pruébalo tú</h2>
  <p>Ejercicio: usa <code>values</code> para calcular la puntuación media.</p>
  {{playground:2}}

  <div class="callout">
    <strong>Relacionado:</strong>
    <a href="keys.html"><code>keys</code></a> — las claves de un Map ·
    <a href="entries.html"><code>entries</code></a> — claves y valores emparejados ·
    <a href="map.html"><code>map</code></a> — transformar cada valor dentro de una cadena ·
    <a href="sum.html"><code>sum · average · min · max</code></a> — los terminales numéricos usados arriba
  </div>
