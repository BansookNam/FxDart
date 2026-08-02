---
slug: fxEvents
title: fxEvents — FxDart 101
description: Tutorial de fxEvents en FxDart: la capa de eventos — un wrapper encadenable sobre Stream de Dart, con map, where, merge, startWith y el puente pull() — con playground en vivo.
heading: <code>fxEvents</code>
section: 14
crumb: fxEvents
next: sampleOn.html
nextLabel: sampleOn
---
  <p class="hero-sub">Envuelve un <code>Stream</code> normal de Dart en un <code>FxEvents</code> encadenable: la puerta de entrada al lado push de FxDart.</p>

  {{signature}}

  <h2>Lección</h2>
  <p>
    Todo lo anterior a esta sección es <em>pull</em>: un pipeline se queda
    quieto hasta que un operador terminal exige el siguiente elemento. Pero
    algunos problemas son genuinamente <em>push</em> — las pulsaciones de
    teclado, las lecturas de sensores, los mensajes de socket llegan cuando
    llegan, los pida alguien o no. Eso es lo que modela el
    <code>Stream</code> de Dart, y <code>fxEvents(stream)</code> le da a ese
    mundo el mismo tratamiento encadenable: <code>map</code>,
    <code>where</code>, <code>asyncMap</code>, <code>startWith</code>,
    <code>FxEvents.merge</code> — más los operadores de tiempo y de
    combinación que cubre el resto de esta sección.
  </p>
  <p>
    Decisiones de diseño que conviene conocer. <code>FxEvents</code> es un
    <strong>wrapper</strong> fino, deliberadamente no un conjunto de
    extensiones sobre <code>Stream</code> — así nunca puede chocar con
    rxdart ni con ninguna otra librería de streams en el mismo archivo. La
    cadena se mantiene <strong>fría</strong>: envolver no escucha nada; solo
    un terminal (<code>toList</code>, <code>listen</code>) pone los eventos
    a fluir. Y es una extensión de fxdart inspirada en Rx, no parte de
    FxTS — los nombres de los operadores siguen la tradición Rx porque de
    ahí vienen estas ideas.
  </p>
  <p>
    Dos vías de escape te mantienen sin ataduras. <code>.stream</code>
    desenvuelve de vuelta a un <code>Stream</code> normal para cualquier
    API basada en Stream, en cualquier punto de la cadena. Y
    <code>.pull()</code> cruza al mundo pull tipado: los eventos se
    convierten en una cadena <code><a href="toAsync.html">FxAsync</a></code>,
    consumida bajo demanda a partir de ahí — push en el borde donde nacen
    los eventos, pull en el núcleo donde tú controlas la demanda.
  </p>

  <h2>Demo 1 · Una cadena fría sobre un Stream</h2>
  {{playground:0}}

  <h2>Demo 2 · merge, y el cruce al mundo pull</h2>
  {{playground:1}}

  <h2>Pruébalo tú</h2>
  <p>Ejercicio: limpia un feed de sensor con fallos.</p>
  {{playground:2}}

  <div class="callout">
    <strong>Relacionado:</strong>
    <a href="streams.html">Puentes de Stream</a> — <code>fromStream</code> / <code>toStream()</code>, el lado pull de la frontera ·
    <a href="debounce.html"><code>debounce</code></a> &amp; <a href="throttle.html"><code>throttle</code></a> — ambos tienen forma <code>FxEvents</code> ·
    <a href="liveValue.html"><code>LiveValue</code></a> — el compañero de valor actual de esta cadena
  </div>
