---
slug: atLeast
title: atLeast — FxDart 101
description: Tutorial de atLeast y atMost en FxDart: cuenta coincidencias solo hasta donde la respuesta lo exige, parando en el elemento decisivo, síncrono y asíncrono.
heading: <code>atLeast</code> · <code>atMost</code>
section: 8
crumb: atLeast
prev: some.html
prevLabel: any
next: none.html
nextLabel: none
---
  <p class="hero-sub">«¿Hay al menos n?» — se responde parando en la n-ésima coincidencia en lugar de contarlo todo.</p>

  {{signature}}

  <h2>Lección</h2>
  <p>
    <code>countWhere(f) &gt;= 2</code> se lee bien y recorre la entrada
    entera, incluso cuando la segunda coincidencia es el segundo elemento.
    <code>atLeast(n, f)</code> hace la misma pregunta y se detiene en la
    <code>n</code>-ésima coincidencia; <code>atMost(n, f)</code> se detiene en
    la <code>n + 1</code>-ésima, que es el momento en que su respuesta pasa a
    ser <code>false</code>. Sobre una entrada larga o perezosa — un rango, un
    pipeline mapeado, un stream de filas — el resto nunca se extrae.
  </p>
  <p>
    Amplían los cuantificadores que ya tienes.
    <code>atLeast(1, f)</code> es <code><a href="some.html">any</a></code>
    y <code>atMost(0, f)</code> es <code>none</code>; los casos límite están
    definidos para que eso se cumpla — <code>atLeast</code> con
    <code>n &lt;= 0</code> es <code>true</code> y <code>atMost</code> con un
    <code>n</code> negativo es <code>false</code>, ambos sin leer nada. Las
    formas asíncronas cancelan el upstream en la coincidencia decisiva, igual
    que <code>any</code>. Extensión de fxdart (sin contraparte en FxTS).
  </p>

  <h2>Demo 1 · Parar en la n-ésima coincidencia</h2>
  {{playground:0}}

  <h2>Demo 2 · atMost, los casos límite, asíncrono</h2>
  {{playground:1}}

  <h2>Pruébalo tú</h2>
  <p>Ejercicio: decide la votación sin contar todas las papeletas.</p>
  {{playground:2}}

  <div class="callout">
    <strong>Relacionado:</strong>
    <a href="some.html"><code>any</code></a> — <code>atLeast(1, f)</code> ·
    <a href="every.html"><code>every</code></a> — el cuantificador universal ·
    <a href="countWhere.html"><code>countWhere</code></a> — cuando necesitas el recuento exacto
  </div>
