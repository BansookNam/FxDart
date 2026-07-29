---
slug: last
title: lastOrNull — FxDart 101
description: Tutorial de lastOrNull en FxDart: obtén el último elemento de un iterable, seguro frente a entradas vacías, y cuidado con la trampa del getter en la cadena.
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
    <code>lastOrNull</code> recorre el iterable entero y devuelve lo último que
    vio — <code>null</code> si nunca vio nada. <code>lastOrNull</code> es el
    nombre idiomático en Dart (refleja <code>Iterable.lastOrNull</code>);
    fxdart también acepta la grafía de FxTS <code>last</code> — son el mismo
    operador. A diferencia de <code>head</code>, aquí no hay atajo: como un
    iterable perezoso no sabe dónde termina sin que se lo pregunten,
    <code>lastOrNull</code> tiene que consumir todos los elementos, así que es
    <code>O(n)</code> aunque el pipeline aguas arriba se haya construido de
    forma perezosa.
  </p>
  <p>
    <strong>Ojo en la cadena síncrona:</strong> <code>Fx</code> extiende
    <code>Iterable</code>, así que <code>fx(iterable).lastOrNull</code> resuelve
    al <em>getter</em> <code>Iterable.lastOrNull</code> heredado de Dart (sin
    paréntesis), que <em>sí</em> es seguro frente a nulos y devuelve
    <code>null</code> con un iterable vacío. La trampa es el getter vecino
    <code>.last</code> (sin «OrNull»): <code>fx(&lt;int&gt;[]).last</code> lanza
    <code>StateError</code> en lugar de devolver <code>null</code>. Recurre a
    <code>.lastOrNull</code>, o a la función de nivel superior
    <code>lastOrNull(iterable)</code>. En la cadena <em>asíncrona</em>,
    <code>.lastOrNull()</code> es un método — con paréntesis.
  </p>

  <h2>Demo 1 · Fundamentos y la trampa del getter en la cadena</h2>
  {{playground:0}}

  <h2>Demo 2 · Async, donde la forma encadenada SÍ es segura frente a nulos</h2>
  <p><code>FxAsync</code> define su propio método <code>.lastOrNull()</code>, así que en la cadena asíncrona la trampa del getter anterior no se aplica:</p>
  {{playground:1}}

  <h2>Pruébalo tú</h2>
  <p>Ejercicio: usa <code>lastOrNull</code> para que esto imprima la última línea del log, o <code>'no logs yet'</code> cuando no haya ninguna.</p>
  {{playground:2}}

  <div class="callout">
    <strong>Relacionado:</strong>
    <a href="head.html"><code>head</code></a> — el extremo opuesto, en O(1) ·
    <a href="nth.html"><code>nth</code></a> — obtener cualquier índice ·
    <a href="find.html"><code>find</code></a> — la primera coincidencia con un predicado ·
    <a href="reverse.html"><code>reverse</code></a> — invertir toda la secuencia
  </div>
