---
slug: zip3
title: zip3 — FxDart 101
description: Tutorial de zip3 en FxDart: la forma de tres iterables de zip, que emite records (A, B, C) y para en la entrada más corta, con playground en vivo.
heading: <code>zip3</code>
section: 6
crumb: zip3
prev: zip.html
prevLabel: zip
next: zipWith.html
nextLabel: zipWith
---
  <p class="hero-sub">Tres iterables recorridos en paralelo: <a href="zip.html"><code>zip</code></a> con una entrada más.</p>

  {{signature}}

  <h2>Lección</h2>
  <p>
    <code>zip3</code> es <a href="zip.html"><code>zip</code></a> con un tercer
    iterable. Todo lo que explica la página de
    <a href="zip.html"><code>zip</code></a> sigue valiendo igual: un record
    por paso, pereza y parada en el momento en que <em>cualquiera</em> de las
    entradas se agota, así que el resultado es tan largo como la más corta de
    las tres. El tipo de elemento es un record de Dart
    <code>(A, B, C)</code>, así que desestructúralo con patrones en vez de por
    índice.
  </p>
  <p>
    Existe como función propia porque Dart no tiene genéricos variádicos: un
    único <code>zip</code> que tomara una lista de iterables tendría que
    borrar los tipos de cada entrada, y <code>(A, B, C)</code> es justo lo que
    hace que el resultado merezca la pena. La misma razón por la que a
    <a href="tee.html"><code>tee</code></a> le acompaña <code>tee3</code>.
  </p>
  <p>
    Una asimetría que conviene conocer: <code>zip</code> tiene método de
    cadena (<code>fx(a).zip(b)</code>) y <code>zip3</code> no — una cadena
    tiene un solo receptor y <code>zip3</code> necesita tres iguales. Llámalo
    como función de nivel superior y envuelve el resultado en
    <code>fx()</code> para seguir, como hace la última línea de la demo.
    <code>zip3Async</code> es la forma asíncrona y, igual que
    <code>zipAsync</code>, lanza las tres llamadas a <code>next()</code> antes
    de esperar ninguna, así que las fuentes se tiran en paralelo por cada
    record en lugar de una detrás de otra.
  </p>

  <h2>Demo · Tres entradas, un record por paso</h2>
  {{playground:0}}

  <div class="callout">
    <strong>Relacionado:</strong>
    <a href="zip.html"><code>zip</code></a> — la forma de dos iterables, y la explicación completa ·
    <a href="zipWith.html"><code>zipWith</code></a> — combina en vez de emparejar ·
    <a href="transpose.html"><code>transpose</code></a> — cualquier número de iterables, a costa de un tipo de elemento común
  </div>
