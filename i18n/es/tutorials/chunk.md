---
slug: chunk
title: chunk — FxDart 101
description: Tutorial de chunk en FxDart: agrupa un iterable perezoso en listas de tamaño fijo, con playground en vivo.
heading: <code>chunk</code>
section: 5
crumb: chunk
prev: slice.html
prevLabel: slice
next: split.html
nextLabel: split
---
  <p class="hero-sub">Devuelve un iterable perezoso de listas, cada una con hasta <code>size</code> elementos consecutivos.</p>

  {{signature}}

  <h2>Lección</h2>
  <p>
    <code>chunk</code> agrupa una secuencia plana en bloques de tamaño fijo:
    repartir cartas en manos, paginar un conjunto de resultados, enviar
    trabajo a una API en lotes de <code>n</code>. Solo mantiene en memoria
    <code>size</code> elementos a la vez antes de emitir cada lista, así que
    sigue siendo perezoso y de memoria acotada incluso sobre una fuente
    enorme; únicamente el último chunk puede quedarse corto, si la fuente no
    se divide de forma exacta.
  </p>
  <p>
    La versión asíncrona, <code>chunkAsync</code>, espera <code>size</code>
    elementos antes de producir cada chunk; combínala con
    <code>.concurrent(n)</code> aguas arriba para resolver de forma
    concurrente el trabajo asíncrono de un chunk entero.
  </p>

  <h2>Demo 1 · Fundamentos</h2>
  <p>10 elementos troceados de 3 en 3 dejan un último chunk más corto:</p>
  {{playground:0}}

  <h2>Demo 2 · Asíncrono</h2>
  {{playground:1}}

  <h2>Pruébalo tú</h2>
  <p>Ejercicio: reparte las cartas en manos de 3.</p>
  {{playground:2}}

  <div class="callout">
    <strong>Relacionado:</strong>
    <a href="slice.html"><code>slice</code></a> — una única ventana arbitraria en lugar de lotes repetidos ·
    <a href="split.html"><code>split</code></a> — agrupa por separador en lugar de por tamaño fijo ·
    <a href="transpose.html"><code>transpose</code></a> — intercambia filas y columnas de datos ya troceados
  </div>
