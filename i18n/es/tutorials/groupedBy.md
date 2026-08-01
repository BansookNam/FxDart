---
slug: groupedBy
title: groupedBy — FxDart 101
description: Tutorial de groupedBy en FxDart — grupos como registros (key, items) encadenables, agrega por grupo sin reentrar por Map.entries. Con playground en vivo.
heading: <code>groupedBy</code>
section: 7
crumb: groupedBy
prev: groupBy.html
prevLabel: groupBy
next: indexBy.html
nextLabel: indexBy
---
  <p class="hero-sub">Grupos como registros <code>(key, items)</code> encadenables — agrega por grupo sin salir del pipeline.</p>

  {{signature}}

  <h2>Lección</h2>
  <p>
    <code><a href="groupBy.html">groupBy</a></code> es un terminal: te
    entrega un <code>Map</code>, y en cuanto quieres «total por grupo,
    ordenado, top 3» estás reentrando al pipeline por
    <code>fx(map.entries)</code>, con toda la ceremonia de
    <code>kv.key</code> / <code>kv.value</code>. <code>groupedBy</code> es
    el mismo agrupamiento como <strong>vista encadenable</strong>: cada
    grupo es un registro con nombre
    <code>(key:&nbsp;…, items:&nbsp;…)</code>, así que la agregación por
    grupo, el orden y el take continúan en la misma cadena — y el código
    aguas abajo lee <code>g.key</code> / <code>g.items</code> en vez de los
    posicionales <code>$1</code> / <code>$2</code>.
  </p>
  <p>
    Los grupos aparecen en <strong>orden de primera aparición de la
    clave</strong>, exactamente como itera el mapa de <code>groupBy</code>.
    Igual que <code><a href="sortBy.html">sortBy</a></code>, tiene que ver
    todos los valores antes de poder producir el primer grupo, así que el
    agrupamiento en sí es ansioso mientras la cadena a su alrededor sigue
    siendo componible.
  </p>
  <p>
    Es una adición nativa de Dart (sin contraparte en FxTS) — usa
    <code>groupBy</code> cuando quieras búsquedas por clave, y
    <code>groupedBy</code> cuando los grupos sean solo un paso intermedio
    de un pipeline más largo.
  </p>

  <h2>Demo 1 · Agrupar → agregar → rankear, una cadena</h2>
  {{playground:0}}

  <h2>Demo 2 · Async</h2>
  {{playground:1}}

  <h2>Pruébalo tú</h2>
  <p>Ejercicio: la categoría con más gasto sin tocar <code>Map.entries</code>.</p>
  {{playground:2}}

  <div class="callout">
    <strong>Relacionados:</strong>
    <a href="groupBy.html"><code>groupBy</code></a> — el mismo agrupamiento como <code>Map</code> con claves ·
    <a href="countBy.html"><code>countBy</code></a> — cuando el único agregado es un conteo ·
    <a href="sortByDesc.html"><code>sortByDesc</code></a> — el siguiente paso natural de un ranking
  </div>
