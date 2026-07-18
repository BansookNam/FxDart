---
slug: each
title: each — FxDart 101
description: Tutorial de each en FxDart: ejecuta una función por sus efectos secundarios sobre cada elemento de una cadena perezosa, en modo síncrono y asíncrono.
heading: <code>each</code>
section: 1
crumb: each
prev: toArray.html
prevLabel: toArray
next: consume.html
nextLabel: consume
---
  <p class="hero-sub">Ejecuta una función una vez por elemento, únicamente por sus efectos secundarios.</p>

  {{signature}}

  <h2>Lección</h2>
  <p>
    <code>each</code> es un operador terminal, igual que <code>toArray</code>:
    al llamarlo tira de todos los valores a través de la cadena entera. La
    diferencia está en qué hace con esos valores: en lugar de recogerlos en
    una <code>List</code>, se limita a ejecutar <code>f</code> con cada uno y
    devuelve <code>void</code>. Úsalo cuando estés imprimiendo, registrando
    logs, escribiendo en una base de datos o produciendo cualquier otro
    efecto, y no necesites los valores de vuelta.
  </p>
  <p>
    Es el gemelo con sabor a FxTS del <code>Iterable.forEach</code> propio de
    Dart: la misma idea, con un nombre coherente con el resto de la API de
    FxTS para que componga con naturalidad junto al vocabulario de la cadena.
  </p>
  <p>
    <code>eachAsync</code> (o <code>.each()</code> sobre una cadena
    <code>FxAsync</code>) espera con await a <code>f</code> para cada
    elemento, estrictamente en el orden en que llegan; aunque algunas
    llamadas individuales pudieran terminar antes que otras, <code>each</code>
    siempre procesa una a una y en secuencia. Si quieres solapamiento, añade
    <code>.concurrent(n)</code> antes de <code>.each()</code> en la cadena.
  </p>

  <h2>Demo 1 · Fundamentos</h2>
  {{playground:0}}

  <h2>Demo 2 · Asíncrono, estrictamente en orden</h2>
  <p>
    Aunque cada elemento duerme durante un tiempo <em>distinto</em>,
    <code>eachAsync</code> los sigue procesando 1, 2, 3 — nunca fuera de
    orden:
  </p>
  {{playground:1}}

  <h2>Pruébalo tú</h2>
  <p>Ejercicio: usa <code>each</code> para imprimir una línea de recibo por
    cada pedido y llevar un total acumulado.</p>
  {{playground:2}}

  <div class="callout">
    <strong>Relacionado:</strong>
    <a href="toArray.html"><code>toArray</code></a> — operador terminal que en su lugar recoge una List ·
    <a href="consume.html"><code>consume</code></a> — operador terminal que descarta los resultados y puede parar antes ·
    <a href="peek.html"><code>peek</code></a> — la misma idea, pero perezoso (no terminal) ·
    <a href="fx.html"><code>fx</code></a> — la cadena que each termina
  </div>
