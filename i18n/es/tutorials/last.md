---
slug: last
title: last — FxDart 101
description: Tutorial de last en FxDart: obtén el último elemento de un iterable, seguro frente a entradas vacías, y cuidado con la trampa del getter en la cadena.
heading: <code>lastOrNull</code>
section: 8
crumb: lastOrNull
prev: head.html
prevLabel: head
next: nth.html
nextLabel: nth
---
  <p class="hero-sub">Devuelve el último elemento de un iterable, o <code>null</code> si está vacío.</p>

  {{signature}}

  <h2>Lección</h2>
  <p>
    <code>last</code> recorre el iterable entero y devuelve lo último que vio
    — <code>null</code> si nunca vio nada. A diferencia de
    <code>head</code>, aquí no hay atajo: como un iterable perezoso no sabe
    dónde termina sin que se lo pregunten, <code>last</code> tiene que
    consumir todos los elementos, así que es <code>O(n)</code> aunque el
    pipeline anterior se haya construido de forma perezosa.
  </p>
  <p>
    <strong>Ojo en la cadena síncrona:</strong> <code>Fx</code> extiende
    <code>Iterable</code> y no hay ninguna redefinición de
    <code>Fx.last()</code>, así que <code>fx(iterable).last</code> resuelve al
    <code>Iterable.last</code> propio de Dart — el <em>getter</em> — que lanza
    <code>StateError</code> con un iterable vacío en lugar de devolver
    <code>null</code>. El comportamiento seguro frente a nulos solo existe en
    la función de nivel superior <code>last(iterable)</code> (o en
    <code>.last()</code> sobre la cadena <em>asíncrona</em>, que sí tiene su
    propia redefinición). Ante la duda, prefiere la función de nivel superior.
  </p>

  <h2>Demo 1 · Fundamentos y la trampa del getter en la cadena</h2>
  {{playground:0}}

  <h2>Demo 2 · Async, donde la forma encadenada SÍ es segura frente a nulos</h2>
  <p><code>FxAsync</code> define su propio <code>.last()</code>, así que en la cadena asíncrona la trampa del getter anterior no aplica:</p>
  {{playground:1}}

  <h2>Pruébalo tú</h2>
  <p>Ejercicio: usa <code>last</code> para que esto imprima la última línea del log, o <code>'no logs yet'</code> cuando no haya ninguna.</p>
  {{playground:2}}

  <div class="callout">
    <strong>Relacionado:</strong>
    <a href="head.html"><code>head</code></a> — el extremo opuesto, en O(1) ·
    <a href="nth.html"><code>nth</code></a> — obtener cualquier índice ·
    <a href="find.html"><code>find</code></a> — la primera coincidencia con un predicado ·
    <a href="reverse.html"><code>reverse</code></a> — invertir toda la secuencia
  </div>
