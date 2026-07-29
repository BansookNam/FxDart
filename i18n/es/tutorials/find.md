---
slug: find
title: firstWhereOrNull — FxDart 101
description: Tutorial de firstWhereOrNull en FxDart: obtén el primer elemento que cumple un predicado, de forma perezosa y con cortocircuito, y null si no hay ninguno.
heading: <code>firstWhereOrNull</code>
section: 8
crumb: firstWhereOrNull
prev: nth.html
prevLabel: nth
next: findIndex.html
nextLabel: findIndex
---
  <p class="hero-sub">Devuelve el primer elemento para el que el predicado es cierto, o <code>null</code>.</p>

  {{signature}}

  <h2>Lección</h2>
  <p>
    <code>firstWhereOrNull</code> es el nombre idiomático en Dart; fxdart
    también acepta la grafía <code>find</code> de FxTS: son el mismo
    operador. Es lo que resulta de fusionar <code>head</code> y
    <code>filter</code> — de hecho está implementado exactamente así:
    <code>head(filter(f, iterable))</code>. Esa fusión es la que lo hace
    perezoso y capaz de cortocircuitar: tira de los elementos de uno en uno,
    probando cada uno contra <code>f</code>, y se detiene en cuanto encuentra
    una coincidencia. Nada de lo que viene después llega a tocarse.
  </p>
  <p>
    Igual que <code>head</code>, una búsqueda sin coincidencias devuelve
    <code>null</code> en lugar del <code>undefined</code> de FxTS. Está
    disponible en versión data-first, como variante asíncrona y como método
    tanto en la cadena síncrona como en la asíncrona.
  </p>

  <h2>Demo 1 · Fundamentos</h2>
  {{playground:0}}

  <h2>Demo 2 · Cortocircuito &amp; asíncrono</h2>
  <p>De un millón de elementos solo se comprueban 6:</p>
  {{playground:1}}

  <h2>Pruébalo tú</h2>
  <p>Ejercicio: usa <code>firstWhereOrNull</code> para obtener el primer artículo con <code>qty &gt; 0</code>, o <code>null</code>.</p>
  {{playground:2}}

  <div class="callout">
    <strong>Relacionado:</strong>
    <a href="findIndex.html"><code>findIndex</code></a> — la misma búsqueda, pero devuelve una posición ·
    <a href="filter.html"><code>filter</code></a> — todas las coincidencias, no solo la primera ·
    <a href="head.html"><code>head</code></a> — la pieza con la que se construye <code>find</code> ·
    <a href="matches.html"><code>matches</code></a> — un predicado ya hecho para comparar formas
  </div>
