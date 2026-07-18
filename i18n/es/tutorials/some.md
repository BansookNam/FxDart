---
slug: some
title: some — FxDart 101
description: Tutorial de some en FxDart: comprueba que al menos un elemento cumple un predicado, cortocircuitando en el primer acierto, en versión síncrona y asíncrona.
heading: <code>some</code>
section: 8
crumb: some
prev: every.html
prevLabel: every
next: predicates.html
nextLabel: predicates
---
  <p class="hero-sub">Es true cuando al menos un elemento cumple un predicado — false para un iterable vacío.</p>

  {{signature}}

  <h2>Lección</h2>
  <p>
    <code>some</code> es la imagen especular de <code>every</code>: recorre de
    izquierda a derecha y cortocircuita en cuanto encuentra una coincidencia,
    devolviendo <code>true</code> de inmediato. Si no encuentra ninguna
    —incluido el caso del iterable vacío, que es el caso trivial opuesto al de
    <code>every</code>— devuelve <code>false</code> solo después de haberlo
    comprobado todo.
  </p>
  <p>
    A diferencia de <code>every</code>, <code>Fx</code> <em>sí</em> define su
    propio método encadenable <code>.some()</code> (no viene ya cubierto por
    <code>Iterable</code>, porque el <code>Iterable</code> de Dart no tiene un
    <code>some</code> integrado: lo más parecido, <code>any</code>, hace el
    mismo trabajo con otro nombre).
  </p>

  <h2>Demo 1 · Fundamentos &amp; cortocircuito</h2>
  {{playground:0}}

  <h2>Demo 2 · Asíncrono</h2>
  {{playground:1}}

  <h2>Pruébalo tú</h2>
  <p>Ejercicio: usa <code>some</code> para comprobar si algo del carrito cuesta más de 10.</p>
  {{playground:2}}

  <div class="callout">
    <strong>Relacionado:</strong>
    <a href="every.html"><code>every</code></a> — la contraparte «todos ellos» ·
    <a href="includes.html"><code>includes</code></a> — una especialización de <code>some</code> ·
    <a href="find.html"><code>find</code></a> — obtiene el elemento coincidente, no solo un bool ·
    <a href="predicates.html"><code>predicates</code></a> — predicados ya hechos para combinar con <code>some</code>
  </div>
