---
slug: countBy
title: countBy — FxDart 101
description: Tutorial de countBy en FxDart: cuenta cuántos elementos caen en cada clave calculada, con un playground en vivo.
heading: <code>countBy</code>
section: 7
crumb: countBy
prev: indexBy.html
prevLabel: indexBy
next: sort.html
nextLabel: sort
---
  <p class="hero-sub">Cuenta cuántos elementos caen en cada clave calculada.</p>

  {{signature}}

  <h2>Lección</h2>
  <p>
    <code>countBy</code> completa el trío junto a
    <code><a href="groupBy.html">groupBy</a></code> e
    <code><a href="indexBy.html">indexBy</a></code>: la misma idea de tirar de
    todo el pipeline y calcular una clave por elemento, pero esta vez no
    conserva los elementos en absoluto — solo incrementa un contador por
    clave. El resultado es un <code>Map&lt;K, int&gt;</code>: cuántos
    elementos produjeron cada clave.
  </p>
  <p>
    Piensa en los tres como respuestas a preguntas distintas sobre la misma
    agrupación: <code>groupBy</code> — "dame todos los elementos de esta clave",
    <code>indexBy</code> — "dame el último elemento de esta clave", y
    <code>countBy</code> — "¿cuántos elementos tuvieron esta clave?". Si lo
    único que necesitas es el recuento, <code>countBy</code> sale más barato que
    <code>groupBy(...).map((k, v) =&gt; MapEntry(k, v.length))</code>, porque
    nunca reserva las listas intermedias.
  </p>
  <p>
    Como siempre, es un operador terminal: nada de lo que hay arriba se ejecuta hasta que <code>countBy</code> tira de ello.
  </p>

  <h2>Demo 1 · Fundamentos</h2>
  {{playground:0}}

  <h2>Demo 2 · Asíncrono</h2>
  {{playground:1}}

  <h2>Pruébalo tú</h2>
  <p>Ejercicio: cuenta cuántos votos recibió cada candidato.</p>
  {{playground:2}}

  <div class="callout">
    <strong>Relacionado:</strong>
    <a href="groupBy.html"><code>groupBy</code></a> — conserva todos los elementos en lugar de solo un recuento ·
    <a href="indexBy.html"><code>indexBy</code></a> — conserva el último elemento en lugar de un recuento ·
    <a href="size.html"><code>size</code></a> — un recuento total, sin clave alguna
  </div>
