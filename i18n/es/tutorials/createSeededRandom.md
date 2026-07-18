---
slug: createSeededRandom
title: createSeededRandom — FxDart 101
description: Tutorial de createSeededRandom en FxDart: un PRNG determinista con semilla para barajados y tests reproducibles, con un playground en vivo.
heading: <code>createSeededRandom</code>
section: 12
crumb: createSeededRandom
prev: shuffle.html
prevLabel: shuffle
---
  <p class="hero-sub">Un generador aleatorio determinista con semilla: el motor detrás de los barajados reproducibles.</p>

  {{signature}}

  <h2>Lección</h2>
  <p>
    <code>createSeededRandom(seed)</code> devuelve una función sin argumentos
    que produce doubles pseudoaleatorios en <code>[0, 1)</code>. La secuencia
    queda completamente determinada por la semilla: dos generadores creados a
    partir de la misma semilla dan exactamente los mismos números, en el mismo
    orden, en cualquier plataforma.
  </p>
  <p>
    Es un port del <code>seededRandom</code> interno de FxTS (un PRNG al
    estilo Mulberry32). En FxTS es privado, pero FxDart lo expone porque la
    aleatoriedad determinista resulta útil en muchos sitios: tests
    reproducibles, datos de demo estables, fuzzing basado en propiedades con
    fallos que se pueden reproducir, o cualquier caso donde lo que de verdad
    quieres es "aleatorio, pero igual en cada ejecución". Es lo que usa
    <a href="shuffle.html"><code>shuffle</code></a> por debajo cuando le pasas
    una semilla.
  </p>
  <p>
    A diferencia del <code>Random(seed)</code> de <code>dart:math</code>, la
    secuencia forma parte del contrato de la librería con FxTS: un
    <code>shuffle</code> con semilla en FxDart y en FxTS produce el mismo
    orden para la misma semilla.
  </p>

  <h2>Demo 1 · Misma semilla, misma secuencia</h2>
  {{playground:0}}

  <h2>Demo 2 · Selecciones y barajados reproducibles</h2>
  <p>
    Convierte el generador en la forma aleatoria que necesites; aquí, tiradas
    de dados y un <code>shuffle</code> con semilla:
  </p>
  {{playground:1}}

  <h2>Pruébalo tú</h2>
  <p>Ejercicio: reparte dos manos "aleatorias" idénticas construyendo ambas a
    partir de la misma semilla.</p>
  {{playground:2}}

  <div class="callout">
    <strong>Relacionado:</strong>
    <a href="shuffle.html"><code>shuffle</code></a> — barajado con semilla construido sobre este generador ·
    <a href="cycle.html"><code>cycle</code></a> &amp; <a href="repeat.html"><code>repeat</code></a> — fuentes infinitas deterministas
  </div>
