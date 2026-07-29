---
slug: each
title: forEach — FxDart 101
description: Tutorial de forEach en FxDart: ejecuta una función por sus efectos secundarios sobre cada elemento de una cadena perezosa, en modo síncrono y asíncrono.
heading: <code>forEach</code>
section: 1
crumb: forEach
prev: toList.html
prevLabel: toList
next: consume.html
nextLabel: consume
---
  <p class="hero-sub">Ejecuta una función una vez por elemento, únicamente por sus efectos secundarios.</p>

  {{signature}}

  <h2>Lección</h2>
  <p>
    <code>forEach</code> es el nombre idiomático en Dart; fxdart también
    acepta la grafía <code>each</code> de FxTS: son el mismo operador. Es un
    operador terminal, igual que <code>toList</code>: al llamarlo tira de
    todos los valores a través de la cadena entera. La diferencia está en qué
    hace con esos valores: en lugar de recogerlos en una <code>List</code>,
    se limita a ejecutar <code>f</code> con cada uno y devuelve
    <code>void</code>. Úsalo cuando estés imprimiendo, registrando logs,
    escribiendo en una base de datos o produciendo cualquier otro efecto, y
    no necesites los valores de vuelta.
  </p>
  <p>
    En una cadena síncrona, <code>.forEach(f)</code> es el propio
    <code>Iterable.forEach</code> de Dart, heredado por <code>Fx</code>; la
    cadena asíncrona y la forma data-first <code>forEach(f, iterable)</code>
    las aporta fxdart, para que el operador se lea igual en todas partes.
  </p>
  <p>
    <code>forEachAsync</code> (o <code>.forEach()</code> sobre una cadena
    <code>FxAsync</code>) espera con await a <code>f</code> para cada
    elemento, estrictamente en el orden en que llegan; aunque algunas
    llamadas individuales pudieran terminar antes que otras,
    <code>forEach</code> siempre procesa una a una y en secuencia. Si quieres
    solapamiento, añade <code>.concurrent(n)</code> antes de
    <code>.forEach()</code> en la cadena.
  </p>

  <h2>Demo 1 · Fundamentos</h2>
  {{playground:0}}

  <h2>Demo 2 · Asíncrono, estrictamente en orden</h2>
  <p>
    Aunque cada elemento duerme durante un tiempo <em>distinto</em>,
    <code>forEachAsync</code> los sigue procesando 1, 2, 3 — nunca fuera de
    orden:
  </p>
  {{playground:1}}

  <h2>Pruébalo tú</h2>
  <p>Ejercicio: usa <code>forEach</code> para imprimir una línea de recibo por
    cada pedido y llevar un total acumulado.</p>
  {{playground:2}}

  <div class="callout">
    <strong>Relacionado:</strong>
    <a href="toList.html"><code>toList</code></a> — operador terminal que en su lugar recoge una List ·
    <a href="consume.html"><code>consume</code></a> — operador terminal que descarta los resultados y puede parar antes ·
    <a href="peek.html"><code>peek</code></a> — la misma idea, pero perezoso (no terminal) ·
    <a href="fx.html"><code>fx</code></a> — la cadena que forEach termina
  </div>
