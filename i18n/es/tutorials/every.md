---
slug: every
title: every — FxDart 101
description: Tutorial de every en FxDart: comprueba que todos los elementos cumplen un predicado, cortocircuitando en el primer fallo, en modo síncrono y asíncrono.
heading: <code>every</code>
section: 8
crumb: every
prev: isEmpty.html
prevLabel: isEmpty
next: some.html
nextLabel: some
---
  <p class="hero-sub">Verdadero cuando todos los elementos cumplen un predicado — trivialmente verdadero para un iterable vacío.</p>

  {{signature}}

  <h2>Lección</h2>
  <p>
    <code>every</code> recorre de izquierda a derecha y abandona
    —cortocircuita— en cuanto encuentra un elemento que no cumple el
    predicado, devolviendo <code>false</code> ahí mismo sin tocar el resto
    del iterable. Si nada falla (incluido el caso en que no hay nada en
    absoluto), devuelve <code>true</code>: un iterable vacío cumple de forma
    trivial "todos los elementos son X".
  </p>
  <p>
    En la cadena síncrona no hay un <code>Fx.every</code> propio, y no hace
    falta: <code>Fx</code> ya hereda el <code>Iterable.every</code> de Dart,
    que tiene exactamente este comportamiento de cortocircuito. La cadena
    asíncrona sí define su propio <code>.every()</code>, porque tiene que
    hacer <code>await</code> de cada llamada al predicado.
  </p>

  <h2>Demo 1 · Fundamentos &amp; cortocircuito</h2>
  <p>El contador de peek se detiene en 3, no en 4; la evaluación se detiene justo en el primer fallo:</p>
  {{playground:0}}

  <h2>Demo 2 · Asíncrono</h2>
  {{playground:1}}

  <h2>Pruébalo tú</h2>
  <p>Ejercicio: usa <code>every</code> para comprobar si todo el mundo aprobó (nota &gt;= 60).</p>
  {{playground:2}}

  <div class="callout">
    <strong>Relacionado:</strong>
    <a href="some.html"><code>some</code></a> — la contraparte "al menos uno" ·
    <a href="filter.html"><code>filter</code></a> — recoge todas las coincidencias en lugar de un bool ·
    <a href="find.html"><code>find</code></a> — obtén el primer elemento que falla o coincide ·
    <a href="predicates.html"><code>predicates</code></a> — predicados listos para usar junto a <code>every</code>
  </div>
