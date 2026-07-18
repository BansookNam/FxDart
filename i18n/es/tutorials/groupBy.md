---
slug: groupBy
title: groupBy — FxDart 101
description: Tutorial de groupBy en FxDart: reparte cada elemento en cubetas según una clave calculada, obteniendo un Map de Lists, con playground en vivo.
heading: <code>groupBy</code>
section: 7
crumb: groupBy
prev: join.html
prevLabel: join
next: indexBy.html
nextLabel: indexBy
---
  <p class="hero-sub">Reparte cada elemento en un <code>Map&lt;K, List&lt;A&gt;&gt;</code> según una clave calculada.</p>

  {{signature}}

  <h2>Lección</h2>
  <p>
    <code>groupBy</code> es un operador terminal que tira de todo el
    pipeline y coloca cada valor en una cubeta, identificada por lo que
    <code>f</code> devuelva para él. Todos los elementos se conservan: no se
    descarta ninguno, a diferencia de
    <code><a href="filter.html">filter</a></code>; simplemente se
    reorganizan en cubetas.
  </p>
  <p>
    La versión de FxTS devuelve un objeto JS normal; como Dart no tiene
    literales de objeto anónimos con claves calculadas arbitrarias, FxDart
    devuelve en su lugar un <code>Map&lt;K, List&lt;A&gt;&gt;</code>: una de las
    conversiones estándar de objeto TS a Map de Dart que se usan en toda esta sección
    (<code><a href="indexBy.html">indexBy</a></code> y
    <code><a href="countBy.html">countBy</a></code> hacen lo mismo).
  </p>
  <p>
    El orden importa dentro de cada cubeta: los elementos caen en cada lista en el mismo
    orden relativo en que aparecían en la fuente. Y como es un terminal,
    esto funciona exactamente igual tanto si aguas arriba hay una lista simple
    como una cadena de pasos perezosos <code>map</code>/<code>filter</code>: solo
    pagas el coste una vez, cuando <code>groupBy</code> tira de ella.
  </p>

  <h2>Demo 1 · Fundamentos</h2>
  {{playground:0}}

  <h2>Demo 2 · Asíncrono</h2>
  {{playground:1}}

  <h2>Pruébalo tú</h2>
  <p>Ejercicio: agrupa las palabras <strong>por su longitud</strong>.</p>
  {{playground:2}}

  <div class="callout">
    <strong>Relacionado:</strong>
    <a href="indexBy.html"><code>indexBy</code></a> — un solo valor por clave en vez de una lista ·
    <a href="countBy.html"><code>countBy</code></a> — cuenta por clave en vez de recolectar ·
    <a href="partition.html"><code>partition</code></a> — agrupar en exactamente dos cubetas
  </div>
