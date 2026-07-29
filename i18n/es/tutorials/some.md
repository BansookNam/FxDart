---
slug: some
title: any — FxDart 101
description: Tutorial de some en FxDart: comprueba que al menos un elemento cumple un predicado, cortocircuitando en el primer acierto, en versión síncrona y asíncrona.
heading: <code>any</code>
section: 8
crumb: any
prev: every.html
prevLabel: every
next: predicates.html
nextLabel: predicates
---
  <p class="hero-sub">Es true cuando al menos un elemento cumple un predicado — false para un iterable vacío.</p>

  {{signature}}

  <h2>Lección</h2>
  <p>
    <code>any</code> es el nombre idiomático en Dart; fxdart también acepta
    <code>some</code>, la grafía de FxTS: son el mismo operador. Es la imagen
    especular de <code>every</code>: recorre de izquierda a derecha y
    cortocircuita en cuanto encuentra una coincidencia, devolviendo
    <code>true</code> de inmediato. Si no encuentra ninguna —incluido el caso
    del iterable vacío, que es el caso trivial opuesto al de
    <code>every</code>— devuelve <code>false</code> solo después de haberlo
    comprobado todo.
  </p>
  <p>
    En una cadena síncrona, <code>.any(f)</code> viene directamente del
    <code>Iterable</code> de Dart —<code>Fx</code> lo hereda—, así que no
    necesita ninguna definición especial. La cadena asíncrona y la forma
    data-first <code>any(f, iterable)</code> las aporta fxdart, y la grafía de
    FxTS <code>some</code> sigue funcionando en todas las posiciones.
  </p>

  <h2>Demo 1 · Fundamentos &amp; cortocircuito</h2>
  {{playground:0}}

  <h2>Demo 2 · Asíncrono</h2>
  {{playground:1}}

  <h2>Pruébalo tú</h2>
  <p>Ejercicio: usa <code>any</code> para comprobar si algo del carrito cuesta más de 10.</p>
  {{playground:2}}

  <div class="callout">
    <strong>Relacionado:</strong>
    <a href="every.html"><code>every</code></a> — la contraparte «todos ellos» ·
    <a href="includes.html"><code>includes</code></a> — una especialización de <code>any</code> ·
    <a href="find.html"><code>find</code></a> — obtiene el elemento coincidente, no solo un bool ·
    <a href="predicates.html"><code>predicates</code></a> — predicados ya hechos para combinar con <code>any</code>
  </div>
