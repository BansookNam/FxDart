---
slug: stream-windowed-alerts
title: Alertas por ventanas sobre un stream de sensores — Dart vs FxDart
description: Trocear un Stream real de Dart en ventanas fijas y lanzar alertas — fromStream + chunk + averageBy frente a llevar el búfer a mano dentro de un await-for.
heading: Alertas por ventanas sobre un stream de sensores
order: 44
tier: 4
functions: streams, chunk, map, averageBy, maxBy, filter
domain: sensors
verdict: fxdart
async: true
---
  <h2>Requisito</h2>
  <p>
    Un sensor de temperatura de caldera entrega lecturas como un
    <code>Stream</code> real de Dart — una cada 10&nbsp;ms, doce en total
    (datos fijos, en el código de abajo). Agrupa el stream en
    <strong>ventanas de cuatro lecturas</strong>, informa de la media y el
    pico de cada ventana, y emite una línea <code>ALERT</code> para toda
    ventana cuya media sea igual o superior a 75.00.
  </p>
  <p>
    La respuesta de FxDart es su puente con los streams:
    <code>fxStream</code> eleva el <code>Stream</code> al pipeline basado en
    pull, y a partir de ahí las ventanas son simplemente
    <code>chunk(4)</code> — el mismo operador que usan los ejemplos
    síncronos — seguido de un <code>map</code> que resume cada ventana con
    <code>averageBy</code> y <code>maxBy</code>.
  </p>

  {{output}}

  <h2>Lado a lado</h2>
  {{comparison}}

  <h2>Por qué difieren</h2>
  <p>
    La API de <code>Stream</code> de Dart no tiene ningún operador de
    ventanas. Las opciones idiomáticas son un bucle <code>await for</code>
    con un búfer mutable — acumular cuatro, volcar, reiniciar, como se
    muestra — o empaquetar esa misma contabilidad en un
    <code>StreamTransformer</code> propio, que es más código, no menos. En
    cualquier caso el búfer, la condición de volcado y el reinicio son cosa
    tuya, y el caso límite de la ventana incompleta también te toca razonarlo
    a ti. En FxDart, <code>chunk(4)</code> es una sola palabra sobre un
    stream exactamente igual que sobre una lista — cruzar de
    <code>Stream</code> al pipeline cuesta una llamada a
    <code>fxStream</code>, y con ella viene todo el vocabulario de
    operadores.
  </p>
