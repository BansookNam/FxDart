---
slug: unicodeToArray
title: unicodeToArray — FxDart 101
description: Tutorial de unicodeToArray en FxDart: divide una cadena en los caracteres que percibe el usuario, tratando correctamente los pares subrogados como los emoji.
heading: <code>unicodeToArray</code>
section: 10
crumb: unicodeToArray
prev: delay.html
prevLabel: delay &amp; sleep
next: curried.html
nextLabel: curried &amp; uncurried
---
  <p class="hero-sub">Divide una cadena en los caracteres que percibe el usuario, tratando correctamente los pares subrogados.</p>

  {{signature}}

  <h2>Lección</h2>
  <p>
    En Dart, un <code>String</code> es una secuencia de <em>unidades de código</em>
    UTF-16, no de caracteres. Llamar a <code>s.split('')</code> divide por unidad
    de código — algo correcto para texto ASCII/latino sencillo, pero erróneo para
    cualquier cosa fuera del Plano Multilingüe Básico, como la mayoría de los
    emoji: estos se representan con un <strong>par subrogado</strong> (dos
    unidades de código), así que una división ingenua parte un mismo emoji en dos
    mitades rotas.
  </p>
  <p>
    <code>unicodeToArray</code> lo resuelve iterando los <code>.runes</code> de la
    cadena — los puntos de código Unicode — y convirtiendo cada uno de vuelta en
    su propio <code>String</code> de un solo carácter. El resultado es la lista de
    caracteres que una persona ve realmente al leer la cadena, igual que el
    <code>unicodeToArray</code> de FxTS, que divide por punto de código y no por
    unidad UTF-16.
  </p>

  <h2>Demo 1 · División ingenua frente a unicodeToArray</h2>
  {{playground:0}}

  <h2>Demo 2 · Invertir y contar correctamente</h2>
  <p>
    Partiendo de <code>unicodeToArray</code>: una inversión con división ingenua
    destrozaría el emoji; esta no:
  </p>
  {{playground:1}}

  <h2>Pruébalo tú</h2>
  <p>Ejercicio: cuenta cuántos caracteres percibidos por el usuario hay en esta
    cadena (contiene un emoji).</p>
  {{playground:2}}

  <div class="callout">
    <strong>Relacionado:</strong>
    <a href="split.html"><code>split</code></a> — divide con un iterable de caracteres normal ·
    <a href="reverse.html"><code>reverse</code></a> — invierte un Iterable; con cadenas hay que cuidar igual los pares subrogados ·
    <a href="countBy.html"><code>countBy</code></a> — usado arriba para contabilizar caracteres ·
    <a href="identity.html"><code>identity</code></a> — usado arriba como clave de conteo
  </div>
