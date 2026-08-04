---
slug: weekly-sensor-averages
title: Medias semanales a partir de lecturas diarias — Dart vs FxDart
description: Plegar 21 lecturas diarias en 3 medias semanales — aritmética de índices y sublist en Dart nativo frente a chunk + averageBy + zipWithIndex en FxDart.
heading: Medias semanales a partir de lecturas diarias
order: 25
tier: 3
functions: chunk, map, averageBy, zipWithIndex, join
domain: sensors
verdict: fxdart
async: false
---
  <h2>Requisito</h2>
  <p>
    Un sensor de temperatura registró una lectura al día durante tres
    semanas completas (21 valores). Informa de la <strong>media por semana
    de 7 días</strong>, una línea por semana, numeradas desde 1. Los datos
    están en el código de abajo; ambas versiones deben imprimir las líneas
    que aparecen bajo <em>Salida esperada</em>.
  </p>

  {{output}}

  <h2>Lado a lado</h2>
  {{comparison}}

  <h2>Por qué difieren</h2>
  <p>
    «Divide en grupos de 7» no tiene forma de escribirse en el núcleo de
    Dart, así que la versión nativa recorre un bucle con contador y recorta
    cada semana con <code>sublist(w * 7, w * 7 + 7)</code> — aritmética de
    índices que quien lee tiene que volver a verificar, y que se rompe si
    la última semana queda incompleta. El <code>chunk(7)</code> de FxDart
    dice la agrupación en una sola palabra (y gestiona una cola corta),
    <code>averageBy</code> sustituye al baile de reducir y luego dividir, y
    <code>zipWithIndex</code> trae el número de semana al pipeline en lugar
    de tomarlo prestado del contador del bucle.
  </p>
