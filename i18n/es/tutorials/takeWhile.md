---
slug: takeWhile
title: takeWhile — FxDart 101
description: Tutorial de takeWhile en FxDart: sigue tomando valores mientras se cumpla un predicado y luego para, con playground en vivo.
heading: <code>takeWhile</code>
section: 5
crumb: takeWhile
prev: takeRight.html
prevLabel: takeRight
next: takeUntilInclusive.html
nextLabel: takeUntilInclusive
---
  <p class="hero-sub">Emite valores mientras un predicado devuelva true; después se detiene definitivamente.</p>

  {{signature}}

  <h2>Lección</h2>
  <p>
    Donde <code>take</code> cuenta valores, <code>takeWhile</code> los pone a prueba.
    Emite los elementos de uno en uno y para en el <em>instante</em> en que
    <code>f</code> devuelve false: nunca mira más allá de ese punto, aunque un
    elemento posterior sí habría pasado. Eso lo hace ideal para situaciones de
    «consume hasta que los datos dejen de tener sentido»: un stream ordenado
    hasta un umbral, un log hasta la primera anomalía, etc.
  </p>
  <p>
    Como es perezoso y cortocircuita en el primer fallo, resulta barato de
    ejecutar incluso sobre una fuente enorme o infinita: solo evalúa el
    prefijo que realmente coincide.
  </p>

  <h2>Demo 1 · Fundamentos</h2>
  <p>Fíjate en que el <code>2</code> del final nunca tiene oportunidad: el
    predicado ya falló en el <code>7</code>:</p>
  {{playground:0}}

  <h2>Demo 2 · Asíncrono</h2>
  {{playground:1}}

  <h2>Pruébalo tú</h2>
  <p>Ejercicio: conserva las temperaturas solo mientras se mantengan por debajo de 25.</p>
  {{playground:2}}

  <div class="callout">
    <strong>Relacionado:</strong>
    <a href="take.html"><code>take</code></a> — toma por cantidad en lugar de por predicado ·
    <a href="takeUntilInclusive.html"><code>takeUntilInclusive</code></a> — para después de la coincidencia, incluyéndola ·
    <a href="dropWhile.html"><code>dropWhile</code></a> — el inverso ·
    <a href="filter.html"><code>filter</code></a> — conserva las coincidencias en todas partes, no solo en un prefijo
  </div>
