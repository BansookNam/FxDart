---
slug: memoize
title: memoize — FxDart 101
description: Tutorial de memoize en FxDart: cachea los resultados de una función unaria según su argumento, en modo síncrono y asíncrono, con playground en vivo.
heading: <code>memoize</code>
section: 10
crumb: memoize
prev: juxt.html
prevLabel: juxt
next: negate.html
nextLabel: negate
---
  <p class="hero-sub">Cachea los resultados de una función unaria, indexados por su argumento.</p>

  {{signature}}

  <h2>Lección</h2>
  <p>
    <code>memoize(f)</code> envuelve <code>f</code> en una caché: la primera vez
    que se llama con un argumento dado, ejecuta <code>f</code> y recuerda
    el resultado; toda llamada posterior con un argumento igual según
    <code>==</code> devuelve el resultado cacheado al instante, sin volver a
    llamar a <code>f</code>. Recurre a ella cuando <code>f</code> sea costosa (un cálculo
    pesado, una llamada de red) y sea probable que se llame repetidamente con las
    mismas entradas.
  </p>
  <p>
    El <code>memoize</code> de FxDart es <strong>solo unario</strong> e indexa la
    caché por el <code>==</code>/<code>hashCode</code> del argumento. La versión de
    FxTS es variádica e indexa por la lista completa de argumentos mediante una caché
    respaldada por <code>WeakMap</code>; Dart no tiene un equivalente directo (no hay
    genéricos variádicos, y las claves débiles al estilo <code>WeakMap</code> no están
    disponibles para objetos arbitrarios), así que las funciones de varios argumentos
    necesitan memoizarse sobre una única clave compuesta (un record funciona bien).
  </p>
  <p>
    Como <code>R</code> no tiene restricciones, <code>f</code> puede devolver un
    <code>Future</code>: memoizar una operación asíncrona cachea el
    <em>Future en sí</em>, de modo que una segunda llamada devuelve de inmediato un
    future ya completado en lugar de rehacer el trabajo.
  </p>

  <h2>Demo 1 · Fundamentos</h2>
  {{playground:0}}

  <h2>Demo 2 · Memoizar una consulta asíncrona</h2>
  <p>
    La segunda llamada a <code>fetchUser(1)</code> devuelve el <code>Future</code>
    cacheado y ya completado, sin esperar los 150 ms:
  </p>
  {{playground:1}}

  <h2>Pruébalo tú</h2>
  <p>Ejercicio: envuelve con <code>memoize</code> esta función «lenta» que eleva al cubo, para
    que llamarla dos veces con <code>3</code> ejecute el cálculo real una sola vez.</p>
  {{playground:2}}

  <div class="callout">
    <strong>Relacionado:</strong>
    <a href="delay.html"><code>delay</code> &amp; <code>sleep</code></a> — usados arriba para simular una llamada asíncrona lenta ·
    <a href="debounce.html"><code>debounce</code></a> — limita la frecuencia de las llamadas en lugar de cachearlas ·
    <a href="identity.html"><code>identity</code></a> — la función más simple posible que envolver ·
    <a href="always.html"><code>always</code></a> — un valor constante, sin necesidad de caché
  </div>
