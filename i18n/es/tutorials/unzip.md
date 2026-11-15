---
slug: unzip
title: unzip — FxDart 101
description: Tutorial de unzip en FxDart: separa un iterable de pares en dos listas en una sola pasada — la inversa de zip — con un playground en vivo.
heading: <code>fxUnzip</code>
section: 6
crumb: unzip
prev: zipWith.html
prevLabel: zipWith
next: zipWithIndex.html
nextLabel: indexed
---
  <p class="hero-sub">Entran pares, salen dos listas: la inversa de <code>zip</code>, en una sola pasada.</p>

  {{signature}}

  <h2>Lección</h2>
  <p>
    <code><a href="zip.html">zip</a></code> empareja dos iterables;
    <code>fxUnzip(pairs)</code> los vuelve a separar. Devuelve un registro
    <code>(lefts, rights)</code> —dos <code>List</code>, llenadas en
    paralelo en un único recorrido de la entrada—, así que lo habitual es
    recibirlo con una declaración de desestructuración:
    <code>final (names, scores) = fxUnzip(pairs);</code>. La versión larga,
    dos <code>map</code> sobre los mismos pares, recorre la entrada dos
    veces.
  </p>
  <p>
    El viaje de ida y vuelta se cumple salvo por la longitud:
    <code>fxUnzip(fxZip(a, b))</code> devuelve <code>a</code> y
    <code>b</code> truncados a la longitud del más corto, porque
    <code>zip</code> ya descartó el resto. Una entrada vacía da dos listas
    vacías. A diferencia de casi toda la sección 6, <code>unzip</code> es
    <strong>estricto</strong>, y tiene que serlo: uno perezoso tendría que
    devolver dos iterables sobre una misma fuente, y agotar cualquiera de
    ellos obligaría a almacenar todo lo que el otro aún no hubiera alcanzado
    (el coste que paga <code><a href="fork.html">fork</a></code>).
  </p>
  <p>
    <code>fxUnzipAsync</code> consume un <code>FxAsyncIterable</code> de
    pares y devuelve un <code>Future</code> del mismo registro. En la cadena
    es <code>.unzip()</code>: una extensión sobre
    <code>Fx&lt;(A, B)&gt;</code> y <code>FxAsync&lt;(A, B)&gt;</code>, así
    que solo aparece en cadenas de pares posicionales, como los que producen
    <code>zip</code>, <code><a href="attach.html">attach</a></code> y
    <code><a href="pairwise.html">pairwise</a></code>. Adición nativa de
    Dart (FxTS no tiene <code>unzip</code>); Kotlin y Rust lo llaman igual.
  </p>

  <h2>Demo 1 · Pares en dos listas</h2>
  {{playground:0}}

  <h2>Demo 2 · Cerrar una cadena asíncrona</h2>
  {{playground:1}}

  <h2>Pruébalo tú</h2>
  <p>Ejercicio: separa los puntos en una sola pasada.</p>
  {{playground:2}}

  <div class="callout">
    <strong>Relacionado:</strong>
    <a href="zip.html"><code>zip</code></a> — la dirección contraria ·
    <a href="zipWith.html"><code>zipWith</code></a> — emparejar y combinar en un paso ·
    <a href="partition.html"><code>partition</code></a> — dos listas separadas por un predicado ·
    <a href="attach.html"><code>attach</code></a> — construye los pares que separar
  </div>
