---
slug: sort
title: sort — FxDart 101
description: Tutorial de sort en FxDart: ordenación basada en comparador que siempre devuelve una lista nueva y nunca muta, con un playground en vivo.
heading: <code>sort</code>
section: 7
crumb: sort
prev: countBy.html
prevLabel: countBy
next: sortBy.html
nextLabel: sortBy
---
  <p class="hero-sub">Devuelve una lista ordenada completamente nueva a partir de un comparador — nunca muta su entrada.</p>

  {{signature}}

  <h2>Lección</h2>
  <p>
    <code>sort</code> recibe un comparador estándar de Dart — devuelve negativo si
    <code>a</code> debe ir antes que <code>b</code>, positivo si va después, cero
    si empatan — y produce un resultado ordenado. La diferencia importante con
    <code>Array.prototype.sort</code> de JavaScript (y de FxTS) es que el
    <code>sort</code> de FxDart <strong>nunca muta su entrada</strong>. Siempre
    crea una <code>List</code> nueva (<code>List.of(iterable)..sort(f)</code>),
    dejando el iterable original tal cual estaba. FxTS añadió más tarde
    <code>toSorted</code> como alternativa no mutante a su <code>sort</code>
    mutante; en FxDart, <code>toSorted</code> es simplemente un alias —
    como <code>sort</code> ya era no mutante, no quedaba nada
    que diferenciar.
  </p>
  <p>
    Hay un matiz en la forma de <strong>cadena</strong> que conviene señalar
    explícitamente: en la cadena síncrona <code>Fx</code>, <code>.sort(f)</code>
    devuelve otro <code>Fx&lt;T&gt;</code> — no una <code>List&lt;T&gt;</code> —
    porque <code>Fx</code> envuelve la lista ordenada subyacente para seguir
    siendo encadenable. Sigues necesitando un terminal como
    <code><a href="../101/index.html">.toArray()</a></code> para obtener una
    <code>List</code> concreta. La cadena <strong>asíncrona</strong> no tiene
    esa peculiaridad: <code>FxAsync.sort(f)</code> ya es un
    terminal que devuelve <code>Future&lt;List&lt;T&gt;&gt;</code> directamente,
    porque <code>FxAsync</code> no puede devolverse a sí mismo desde algo que
    necesita hacer <code>await</code> de todo el pipeline primero.
  </p>
  <p>
    Recurre a <code><a href="sortBy.html">sortBy</a></code> en su lugar cuando
    solo quieras ordenar por una clave que extraes, en vez de escribir el
    comparador tú mismo.
  </p>

  <h2>Demo 1 · Fundamentos, sin mutación, y toSorted</h2>
  {{playground:0}}

  <h2>Demo 2 · Asíncrono — ya es un terminal</h2>
  {{playground:1}}

  <h2>Pruébalo tú</h2>
  <p>Ejercicio: ordena los números en orden <strong>descendente</strong>.</p>
  {{playground:2}}

  <div class="callout">
    <strong>Relacionado:</strong>
    <a href="sortBy.html"><code>sortBy</code></a> — ordena por una clave extraída en lugar de un comparador ·
    <a href="reverse.html"><code>reverse</code></a> — invierte el orden de los elementos sin comparar ·
    <a href="partition.html"><code>partition</code></a> — divide en dos listas según un predicado
  </div>
