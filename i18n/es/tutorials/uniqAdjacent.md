---
slug: uniqAdjacent
title: uniqAdjacent — FxDart 101
description: Tutorial de uniqAdjacent en FxDart: descarta solo los duplicados adyacentes — detección de cambios de estado sin un conjunto de vistos que crece — con playground en vivo.
heading: <code>uniqAdjacent</code>
section: 4
crumb: uniqAdjacent
prev: uniqStrict.html
prevLabel: uniqStrict
next: takeUniqBy.html
nextLabel: takeUniqBy
---
  <p class="hero-sub">Descarta los elementos iguales a su predecesor — solo se van los duplicados <em>adyacentes</em>, y no se acumula ningún conjunto de vistos.</p>

  {{signature}}

  <h2>Lección</h2>
  <p>
    <code><a href="uniq.html">uniq</a></code> responde a «¿he visto este
    valor <em>alguna vez</em>?» — mantiene un conjunto con todo lo visto
    hasta el momento. <code>uniqAdjacent()</code> responde a otra
    pregunta: «¿el valor <em>cambió</em>?» Compara cada elemento solo con
    su predecesor inmediato, así que <code>[1, 1, 2, 2, 1]</code> se
    convierte en <code>(1, 2, 1)</code> — el <code>1</code> final
    sobrevive, porque es una <em>racha nueva</em>, no una repetición de
    la actual.
  </p>
  <p>
    Eso lo convierte en el operador para colapsar rachas: feeds de estado
    que reportan lo mismo en cada tick, valores de sensores que se
    estabilizan, streams de log que repiten un nivel. Y como no hay
    conjunto de vistos, la memoria se mantiene constante por larga que
    sea la secuencia — seguro sobre fuentes inagotables donde
    <code>uniq</code> crecería sin límite.
    <code>uniqAdjacentBy(key)</code> compara por una clave derivada,
    reflejando a <code><a href="uniqBy.html">uniqBy</a></code>.
  </p>
  <p>
    Extensión de fxdart (sin contraparte en FxTS) — Rx lo llama
    <code>distinctUntilChanged</code>, los streams de Dart lo llaman
    <code>Stream.distinct</code>. El callback de clave async corre de un
    elemento en uno (la comparación es inherentemente ordenada), pero el
    tramo de aguas arriba sigue evaluándose en paralelo bajo
    <code><a href="concurrent.html">concurrent</a></code>.
  </p>

  <h2>Demo 1 · Colapsa rachas, conserva los regresos</h2>
  {{playground:0}}

  <h2>Demo 2 · Cambios de estado por clave</h2>
  {{playground:1}}

  <h2>Pruébalo tú</h2>
  <p>Ejercicio: reporta solo los momentos en que cambia la zona de un sensor.</p>
  {{playground:2}}

  <div class="callout">
    <strong>Relacionado:</strong>
    <a href="uniq.html"><code>uniq</code></a> — deduplicación global con conjunto de vistos ·
    <a href="uniqBy.html"><code>uniqBy</code></a> — deduplicación global por clave ·
    <a href="pairwise.html"><code>pairwise</code></a> — cuando necesitas ambos lados del cambio
  </div>
