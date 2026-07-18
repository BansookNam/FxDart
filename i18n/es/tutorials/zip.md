---
slug: zip
title: zip — FxDart 101
description: Tutorial de zip en FxDart: empareja los elementos de dos (o tres) iterables en records, con un playground en vivo.
heading: <code>zip</code>
section: 6
crumb: zip
prev: concat.html
prevLabel: concat
next: zipWith.html
nextLabel: zipWith
---
  <p class="hero-sub">Empareja los elementos de dos iterables en records y se detiene en el más corto.</p>

  {{signature}}

  <h2>Lección</h2>
  <p>
    <code>zip</code> recorre dos iterables en paralelo y produce un par por
    paso, deteniéndose en cuanto cualquiera de las entradas se agota. Donde
    FxTS devuelve una tupla de TS, FxDart devuelve un
    <strong>record</strong> de Dart — <code>(A, B)</code> — de modo que
    desestructuras los resultados con <code>.$1</code>/<code>.$2</code> o con
    pattern matching, en lugar de con índices de array. Como Dart no tiene
    genéricos variádicos, cada aridad tiene su propia función:
    <code>zip</code> para dos iterables y <code>zip3</code> para tres.
  </p>
  <p>
    <code>zipAsync</code> lanza las llamadas a <code>next()</code> de ambos
    lados <em>antes</em> de esperar a ninguna de las dos, así que consume las
    dos fuentes en paralelo en cada par, no secuencialmente. Combinar dos fuentes
    de 100 ms por elemento sigue costando ~100 ms por par, no 200 ms.
  </p>

  <h2>Demo 1 · Fundamentos</h2>
  {{playground:0}}

  <h2>Demo 2 · Async, con consumo en paralelo por par</h2>
  {{playground:1}}

  <h2>Pruébalo tú</h2>
  <p>Ejercicio: combina <code>names</code> y <code>ages</code> con zip en
    records <code>(name, age)</code>.</p>
  {{playground:2}}

  <div class="callout">
    <strong>Relacionado:</strong>
    <a href="zipWith.html"><code>zipWith</code></a> — emparejar y combinar en un solo paso ·
    <a href="zipWithIndex.html"><code>zipWithIndex</code></a> — emparejar con un índice creciente ·
    <a href="transpose.html"><code>transpose</code></a> — emparejar un número arbitrario de filas ·
    <a href="concat.html"><code>concat</code></a> — encadenar en vez de emparejar
  </div>
