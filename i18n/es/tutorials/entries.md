---
slug: entries
title: entries — FxDart 101
description: Tutorial de entries en FxDart: convierte los pares (clave, valor) de un Map en un iterable perezoso de records, listo para encadenar.
heading: <code>entries</code>
section: 2
crumb: entries
prev: cycle.html
prevLabel: cycle
next: keys.html
nextLabel: keys
---
  <p class="hero-sub">Emite los pares (clave, valor) de un Map como records: el punto de entrada para encadenar sobre un Map.</p>

  {{signature}}

  <h2>Lección</h2>
  <p>
    Un <code>Map</code> de Dart no es un <code>Iterable</code> como sí lo es
    una <code>List</code>, así que no existe un <code>fx(someMap)</code>
    directo. <code>entries</code> es el puente: emite cada par clave/valor del
    map como un record <code>(K, V)</code>, dándote un <code>Iterable</code>
    perezoso normal que <em>sí</em> puedes envolver con <code>fx()</code> y
    encadenar como cualquier otro. Esto refleja el <code>entries</code> de
    FxTS, que hace lo mismo con un objeto de JS.
  </p>
  <p>
    Como los pares son records de Dart, puedes desestructurarlos directamente
    en un bucle <code>for</code> — <code>for (final (key, value) in
    entries(map))</code> — o acceder a los campos posicionales
    <code>.$1</code> (clave) y <code>.$2</code> (valor) dentro de una
    retrollamada de <code>map</code>/<code>filter</code> cuando desestructurar
    no resulte cómodo.
  </p>
  <p>
    <code>entries</code> es perezoso como todo lo demás aquí, pero las
    entradas de un <code>Map</code> no son infinitas, así que rara vez hay
    motivo para acotarlo con <code>take</code>: se trata más de convertir un
    Map en algo encadenable que de controlar cuánto se llega a consumir.
  </p>

  <h2>Demo 1 · Fundamentos</h2>
  {{playground:0}}

  <h2>Demo 2 · Encadenar sobre un Map</h2>
  <p>Envuelve <code>entries(map)</code> con <code>fx()</code> para filtrar y
    transformar el contenido de un Map:</p>
  {{playground:1}}

  <h2>Pruébalo tú</h2>
  <p>Ejercicio: convierte un Map de notas en cadenas "nombre: PASS/FAIL".</p>
  {{playground:2}}

  <div class="callout">
    <strong>Relacionado:</strong>
    <a href="keys.html"><code>keys</code></a> — solo las claves de un Map ·
    <a href="values.html"><code>values</code></a> — solo los valores de un Map ·
    <a href="fromEntries.html"><code>fromEntries</code></a> — la inversa: reconstruir un Map a partir de los pares ·
    <a href="fx.html"><code>fx</code></a> — la cadena a la que alimentan los resultados de entries
  </div>
