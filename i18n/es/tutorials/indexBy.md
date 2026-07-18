---
slug: indexBy
title: indexBy — FxDart 101
description: Tutorial de indexBy en FxDart: indexa cada elemento por una clave calculada en un Map, donde gana el último duplicado, con un playground en vivo.
heading: <code>indexBy</code>
section: 7
crumb: indexBy
prev: groupBy.html
prevLabel: groupBy
next: countBy.html
nextLabel: countBy
---
  <p class="hero-sub">Indexa cada elemento por una clave calculada en un <code>Map&lt;K, A&gt;</code> — gana el último duplicado.</p>

  {{signature}}

  <h2>Lección</h2>
  <p>
    <code>indexBy</code> es el hermano de
    <code><a href="groupBy.html">groupBy</a></code>: la misma idea — tirar de
    todo el pipeline y calcular una clave por elemento — pero en vez de
    reunir una <em>lista</em> por clave, guarda exactamente
    <strong>un</strong> valor por clave: <code>Map&lt;K, A&gt;</code> en lugar
    de <code>Map&lt;K, List&lt;A&gt;&gt;</code>.
  </p>
  <p>
    Eso significa que los duplicados no se acumulan: se sobrescriben. Si dos
    elementos producen la misma clave, el que se procese en
    <strong>último</strong> lugar (es decir, el que aparece después en el
    iterable) es el que queda en el map. Es el comportamiento natural de ir
    haciendo <code>result[key(a)] = a</code> mientras se avanza, y coincide
    con FxTS. Recurre a <code>indexBy</code> precisamente cuando sepas que las
    claves deben ser únicas (como un ID de base de datos) y quieres una
    búsqueda directa <code>O(1)</code> en vez de una lista en la que tendrías
    que buscar.
  </p>
  <p>
    Si de verdad esperas claves duplicadas y quieres conservar todos los
    valores, usa <code>groupBy</code> en su lugar — nunca descarta nada.
  </p>

  <h2>Demo 1 · Fundamentos &amp; gana el último</h2>
  {{playground:0}}

  <h2>Demo 2 · Asíncrono</h2>
  {{playground:1}}

  <h2>Pruébalo tú</h2>
  <p>Ejercicio: indexa los usuarios <strong>por su id</strong>, para poder buscar uno directamente.</p>
  {{playground:2}}

  <div class="callout">
    <strong>Relacionado:</strong>
    <a href="groupBy.html"><code>groupBy</code></a> — conserva todos los duplicados en lugar de sobrescribirlos ·
    <a href="countBy.html"><code>countBy</code></a> — cuenta en vez de conservar el valor ·
    <a href="fromEntries.html"><code>fromEntries</code></a> — construye un Map directamente a partir de pares clave/valor
  </div>
