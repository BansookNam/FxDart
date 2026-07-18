---
slug: reverse
title: reverse — FxDart 101
description: Tutorial de reverse en FxDart: recorre un iterable finito del final al principio, con un playground en vivo.
heading: <code>reverse</code>
section: 6
crumb: reverse
prev: transpose.html
prevLabel: transpose
next: fork.html
nextLabel: fork
---
  <p class="hero-sub">Devuelve la fuente en orden inverso.</p>

  {{signature}}

  <h2>Lección</h2>
  <p>
    <code>reverse</code> emite los elementos de una fuente del último al
    primero. Igual que <code>takeRight</code> y <code>dropRight</code>, no hay
    forma de saber qué significa "el último" sin haberlo visto todo antes, así
    que <code>reverse</code> <strong>materializa</strong> la fuente entera en
    una lista antes de emitir un solo valor. Es un operador para fuentes
    finitas y bufferizables: nunca terminará con una fuente infinita.
  </p>
  <p>
    <code>reverseAsync</code> sigue la misma regla: primero espera todos los
    elementos de aguas arriba y luego los reproduce del final al principio. Si
    solo necesitas la cola de una secuencia en lugar de una inversión de
    verdad, prefiere <code>takeRight</code>: también materializa, pero al menos
    para en cuanto tiene los valores que necesita para emitirlos en orden.
  </p>

  <h2>Demo 1 · Fundamentos</h2>
  {{playground:0}}

  <h2>Demo 2 · Asíncrono (primero hay que almacenar toda la fuente en memoria)</h2>
  {{playground:1}}

  <h2>Pruébalo tú</h2>
  <p>Ejercicio: invierte el historial para que la visita más reciente aparezca primero.</p>
  {{playground:2}}

  <div class="callout">
    <strong>Relacionado:</strong>
    <a href="takeRight.html"><code>takeRight</code></a> — también materializa, pero solo necesita la cola ·
    <a href="dropRight.html"><code>dropRight</code></a> ·
    <a href="sort.html"><code>sort</code></a> — también materializa en una lista nueva
  </div>
