---
slug: concurrentPool
title: concurrentPool — FxDart 101
description: Tutorial de concurrentPool en FxDart: un pool de tamaño fijo de peticiones en vuelo que emite los resultados por orden de finalización, con un playground en vivo.
heading: <code>concurrentPool</code>
section: 11
crumb: concurrentPool
next: debounce.html
nextLabel: debounce
---
  <p class="hero-sub">Como concurrent, pero emite los resultados por orden de finalización — el primero que acaba es el primero que sale.</p>

  {{signature}}

  <h2>Lección</h2>
  <p>
    <code>concurrentPool(n)</code> mantiene hasta <code>n</code> peticiones en
    vuelo contra la fuente de aguas arriba, igual que <code>concurrent(n)</code>
    — pero te devuelve los resultados en el orden en que <strong>terminan</strong>,
    no en el que empezaron. Piénsalo como un pool de workers: en cuanto se libera
    un hueco, se lanza en él el siguiente elemento pendiente, y el primero que
    acaba es el primero que se emite. Esto coincide con el
    <code>concurrentPool</code> de FxTS y es la herramienta adecuada cuando no te
    importa qué resultado vino de qué entrada — solo quieres reaccionar a cada
    resultado en cuanto está listo (por ejemplo, actualizar una lista de progreso
    conforme aterriza cada fetch), en lugar de bloquearte con el más lento para
    conservar el orden.
  </p>
  <p>
    A diferencia de <code>concurrent</code>, que se guía por el marcador de
    demanda que llega de aguas abajo, <code>concurrentPool</code> <strong>mantiene
    su pool lleno de forma ansiosa</strong>: desde el primer pull conserva hasta
    <code>n</code> peticiones en vuelo, haya los consumidores que haya
    esperando. Incluso un operador terminal que tira de uno en uno como
    <code>.toArray()</code> o <code>.each()</code> obtiene todo el solapamiento
    — y ve los resultados en el orden en que terminan.
  </p>

  <h2>Demo 1 · Orden de finalización</h2>
  <p>El elemento 1 es el más lento (300ms) y el 2 el más rápido (100ms) — el
    resultado sale con el más rápido primero, directamente desde <code>.toArray()</code>:</p>
  {{playground:0}}

  <h2>Demo 2 · Contraste con concurrent</h2>
  <p>Los mismos retardos, el mismo pool de tamaño 3 — la única diferencia es en
    qué orden llegan los resultados:</p>
  {{playground:1}}

  <h2>Pruébalo tú</h2>
  <p>Ejercicio: este pool de tamaño 1 procesa los elementos de uno en uno, en el
    orden en que se lanzan. Súbelo a 3 para que los tres compitan a la vez y
    observa cómo el orden impreso pasa a ser el de finalización.</p>
  {{playground:2}}

  <div class="callout">
    <strong>Relacionado:</strong>
    <a href="concurrent.html"><code>concurrent</code></a> — variante que preserva el orden ·
    <a href="toAsync.html"><code>toAsync</code></a> — el modelo basado en pull en el que se apoya ·
    <a href="streams.html">puentes con Stream</a> — aplica concurrentPool antes de toStream() ·
    <a href="debounce.html"><code>debounce</code></a> — limitación de frecuencia para callbacks
  </div>
