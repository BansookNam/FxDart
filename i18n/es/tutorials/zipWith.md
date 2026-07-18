---
slug: zipWith
title: zipWith — FxDart 101
description: Tutorial de zipWith en FxDart: empareja dos iterables y combina cada par a través de una función en un solo paso, con un playground en vivo.
heading: <code>zipWith</code>
section: 6
crumb: zipWith
prev: zip.html
prevLabel: zip
next: zipWithIndex.html
nextLabel: zipWithIndex
---
  <p class="hero-sub">Empareja dos iterables y combina cada par a través de una función, en un solo paso.</p>

  {{signature}}

  <h2>Lección</h2>
  <p>
    <code>zipWith</code> es exactamente <code>zip</code> seguido de
    <code>map</code> sobre los pares resultantes — de hecho así está
    implementado en FxDart, como
    <code>map((r) => f(r.$1, r.$2), zip(...))</code>. Recurre a él cuando en
    realidad no quieres el record <code>(A, B)</code> intermedio, sino solo el
    resultado combinado: multiplicar dos listas paralelas, formatear un nombre
    y una edad en una sola etiqueta, y cosas así.
  </p>
  <p>
    Se detiene en la más corta de las dos entradas, igual que
    <code>zip</code>, y la forma asíncrona <code>zipWithAsync</code> hereda de
    <code>zipAsync</code> el consumo en paralelo por par. No hay forma
    encadenable en <code>Fx</code> para <code>zipWith</code>: llama
    directamente a la función de nivel superior (o constrúyela tú mismo como
    <code>.zip(other).map((r) => f(r.$1, r.$2))</code>).
  </p>

  <h2>Demo 1 · Fundamentos</h2>
  {{playground:0}}

  <h2>Demo 2 · Asíncrono</h2>
  {{playground:1}}

  <h2>Pruébalo tú</h2>
  <p>Ejercicio: usa <code>zipWith</code> para calcular el total de línea
    (<code>price * quantity</code>) de cada par.</p>
  {{playground:2}}

  <div class="callout">
    <strong>Relacionado:</strong>
    <a href="zip.html"><code>zip</code></a> — la versión de pares simples sobre la que se construye ·
    <a href="zipWithIndex.html"><code>zipWithIndex</code></a> — emparejar con un índice creciente ·
    <a href="map.html"><code>map</code></a>
  </div>
