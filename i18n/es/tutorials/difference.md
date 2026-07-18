---
slug: difference
title: difference — FxDart 101
description: Tutorial de difference en FxDart: los elementos de un iterable que no aparecen en otro, con playground en vivo.
heading: <code>difference</code>
section: 4
crumb: difference
prev: uniqBy.html
prevLabel: uniqBy
next: differenceBy.html
nextLabel: differenceBy
---
  <p class="hero-sub">Devuelve los elementos del segundo iterable que no aparecen en el primero — el orden de los argumentos importa.</p>

  {{signature}}

  <h2>Lección</h2>
  <p>
    Lee la firma con atención: <code>difference(iterable1, iterable2)</code>
    recorre <strong><code>iterable2</code></strong> y emite cada uno de sus
    elementos que <em>no</em> se encuentre en <code>iterable1</code>
    (sin duplicados, como <code>uniq</code>). <code>iterable1</code> se usa
    únicamente como conjunto de pertenencia contra el que comprobar —
    ninguno de sus propios elementos puede aparecer en la salida, y sus
    duplicados dan igual. Este orden no es simétrico: intercambiar los
    argumentos produce un resultado completamente distinto (y por lo general
    de distinta longitud). Una forma útil de recordarlo: piensa en
    <code>iterable1</code> como "la lista de exclusión" y en
    <code>iterable2</code> como "la lista que estás filtrando".
  </p>
  <p>
    Por dentro es <code>differenceBy((a) =&gt; a, iterable1, iterable2)</code> —
    mira <a href="differenceBy.html"><code>differenceBy</code></a> si
    necesitas comparar por una clave calculada en vez de por igualdad de
    valor.
  </p>
  <p>
    No hay método de cadena para <code>difference</code>; solo existe como
    función data-first (y su contraparte asíncrona). En el lado asíncrono,
    el marcador de concurrencia de <code>.concurrent(n)</code> se aplica a
    <strong><code>iterable2</code></strong> — el conjunto de exclusión de
    <code>iterable1</code> siempre se consume por completo antes de que
    empiecen a fluir los resultados.
  </p>

  <h2>Demo 1 · Fundamentos &amp; orden de los argumentos</h2>
  {{playground:0}}

  <h2>Demo 2 · Asíncrono, con concurrencia</h2>
  {{playground:1}}

  <h2>Pruébalo tú</h2>
  <p>Ejercicio: usa <code>difference</code> para encontrar las tareas de
    <code>allTasks</code> que aún no están en <code>completed</code>.</p>
  {{playground:2}}

  <div class="callout">
    <strong>Relacionado:</strong>
    <a href="differenceBy.html"><code>differenceBy</code></a> — lo mismo, por una clave calculada ·
    <a href="intersection.html"><code>intersection</code></a> — quedarse con los elementos comunes en su lugar ·
    <a href="uniq.html"><code>uniq</code></a> — elimina duplicados de un solo iterable ·
    <a href="../tutorials/includes.html"><code>includes</code></a> — comprueba la pertenencia en un solo iterable
  </div>
