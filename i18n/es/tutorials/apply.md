---
slug: apply
title: apply — FxDart 101
description: Tutorial de apply en FxDart: invoca una función con los argumentos recogidos en una List, con un playground en vivo.
heading: <code>apply</code>
section: 10
crumb: apply
prev: tap.html
prevLabel: tap
next: juxt.html
nextLabel: juxt
---
  <p class="hero-sub">Llama a una función pasándole una List de argumentos como parámetros posicionales.</p>

  {{signature}}

  <h2>Lección</h2>
  <p>
    <code>apply</code> existe para esos momentos en los que los argumentos de una
    llamada no están en variables sueltas — ya vienen recogidos en una
    <code>List</code> (parseada de una entrada, sacada de una configuración, producida por
    <a href="juxt.html"><code>juxt</code></a>) y necesitas invocar con ellos una
    función arbitraria. Por dentro es una envoltura mínima sobre el propio
    <code>Function.apply</code> de Dart, con el resultado convertido a <code>R</code>.
  </p>
  <p>
    Como <code>f</code> está tipada simplemente como <code>Function</code>,
    <code>apply</code> es dinámico por naturaleza: Dart no puede comprobar el número
    ni los tipos de los argumentos contra la firma de <code>f</code> en tiempo de
    compilación, solo en tiempo de ejecución. Recurre a él únicamente cuando de verdad
    tengas una lista dinámica de argumentos; para todo lo demás, llama a la función directamente.
  </p>
  <p>
    Un asunto relacionado pero distinto es la <em>currificación</em> — rellenar de
    antemano algunos argumentos de una función. FxTS tiene un
    <code>curry</code> totalmente genérico; el sistema de tipos de Dart no tiene equivalente
    para aridades arbitrarias, así que FxDart solo incluye un stub
    <code>@Deprecated</code> de <code>curry</code> para dos argumentos como
    ayuda a la migración. Es preferible que escribas tú el closure:
    <code>(b) => f(a, b)</code>.
  </p>

  <h2>Demo 1 · Fundamentos</h2>
  {{playground:0}}

  <h2>Demo 2 · Despachar llamadas dinámicas</h2>
  <p>
    Un pequeño despachador de comandos, donde cada manejador tiene una aridad distinta y
    los argumentos llegan como una <code>List</code> en tiempo de ejecución:
  </p>
  {{playground:1}}

  <h2>Pruébalo tú</h2>
  <p>Ejercicio: llama a <code>greet</code> más abajo usando <code>apply</code> con la
    lista de argumentos <code>['Kim', 'Hello']</code>.</p>
  {{playground:2}}

  <div class="callout">
    <strong>Relacionado:</strong>
    <a href="juxt.html"><code>juxt</code></a> — a menudo el origen de una lista dinámica de argumentos ·
    <a href="tap.html"><code>tap</code></a> — ejecuta un efecto secundario sin cambiar el valor ·
    <a href="cases.html"><code>cases</code></a> — despacha por predicados en lugar de por nombre ·
    <a href="pipe.html"><code>pipe</code></a> — composición dinámica, con el mismo compromiso que apply
  </div>
