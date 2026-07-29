---
slug: head
title: firstOrNull — FxDart 101
description: Tutorial de firstOrNull en FxDart: obtén el primer elemento de un iterable de forma segura, devolviendo null en lugar de lanzar una excepción, con playground en vivo.
heading: <code>firstOrNull</code>
section: 8
crumb: firstOrNull
prev: partition.html
prevLabel: partition
next: last.html
nextLabel: last
---
  <p class="hero-sub">Devuelve el primer elemento de un iterable, o <code>null</code> si está vacío.</p>

  {{signature}}

  <h2>Lección</h2>
  <p>
    <code>firstOrNull</code> toma exactamente un elemento del principio de un
    iterable y te lo devuelve — o <code>null</code> si no hay ninguno.
    <code>firstOrNull</code> es el nombre idiomático en Dart (refleja
    <code>Iterable.firstOrNull</code>); fxdart también acepta la grafía de FxTS
    <code>head</code> — son el mismo operador. El <code>head</code> de FxTS
    devuelve <code>undefined</code> con un array vacío; Dart no tiene
    <code>undefined</code>, así que en esta parte de la API todo resultado del
    tipo «puede que no exista» se reduce a <code>null</code>. Por eso la forma
    natural de consumirlo es <code>firstOrNull(list) ?? fallback</code>.
  </p>
  <p>
    Como <code>firstOrNull</code> solo llama a <code>moveNext()</code> una vez,
    invocarlo sobre un pipeline perezoso enorme — incluso infinito — no cuesta
    nada: aguas arriba no se ejecuta nada más allá del único elemento que necesita.
  </p>
  <p>
    Viene en forma data-first (<code>firstOrNull(iterable)</code>) y en forma
    asíncrona para <code>FxAsyncIterable</code>. En la cadena síncrona,
    <code>fx(iterable).firstOrNull</code> es el getter heredado de
    <code>Iterable</code> — sin paréntesis; en la cadena asíncrona es un
    método, <code>.firstOrNull()</code>.
  </p>

  <h2>Demo 1 · Fundamentos</h2>
  <p>Entra vacío, sale <code>null</code>: sin excepciones y sin necesidad de una retrollamada <code>orElse</code>:</p>
  {{playground:0}}

  <h2>Demo 2 · Pereza y cortocircuito asíncrono</h2>
  <p>
    Del rango de un millón de elementos de abajo solo se extrae uno.
    En el ejemplo asíncrono, la cadena espera el <em>primer</em>
    <code>delay(...)</code> y ni siquiera llega a molestarse con el segundo:
  </p>
  {{playground:1}}

  <h2>Pruébalo tú</h2>
  <p>Ejercicio: usa <code>firstOrNull</code> para que esto imprima la primera puntuación, o
    <code>0</code> cuando la lista esté vacía.</p>
  {{playground:2}}

  <div class="callout">
    <strong>Relacionado:</strong>
    <a href="last.html"><code>last</code></a> — la misma idea desde el otro extremo ·
    <a href="nth.html"><code>nth</code></a> — extrae cualquier índice ·
    <a href="find.html"><code>find</code></a> — la primera coincidencia con un predicado ·
    <a href="isEmpty.html"><code>isEmpty</code></a> — comprobación de vacío basada en el valor
  </div>
