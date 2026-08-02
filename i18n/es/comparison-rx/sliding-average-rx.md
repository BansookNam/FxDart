---
slug: sliding-average-rx
title: Media móvil de tres lecturas — RxDart vs FxDart
description: Una media móvil sobre lecturas de sensor — bufferCount(3, 1) más un filtro de longitud para los parciales finales frente a windowed(3) diciendo exactamente lo que significa.
heading: Media móvil de tres lecturas
order: 12
tier: 2
functions: fx, windowed, average, map
domain: sensors
verdict: fxdart
async: false
---
  <h2>Requisito</h2>
  <p>
    Suaviza ocho lecturas horarias de temperatura con una
    <strong>media móvil de tres lecturas</strong>: para cada ventana de 3
    lecturas consecutivas, imprime la ventana y su media a un decimal —
    seis ventanas completas, sin parciales. Los datos están en el código;
    las dos versiones deben imprimir las líneas que aparecen bajo
    <em>Salida esperada</em>.
  </p>

  {{output}}

  <h2>Lado a lado</h2>
  {{comparison}}

  <h2>Por qué difieren</h2>
  <p>
    RxDart escribe una ventana deslizante como una parametrización del
    loteo: <code>bufferCount(3, 1)</code> — búferes de tres, con un búfer
    nuevo empezando cada evento. Funciona, pero la codificación gotea dos
    veces. Tienes que saber que el segundo argumento es
    <code>startBufferEvery</code> y que <code>1</code> significa
    «deslizante»; y al final del stream el operador vuelca sus búferes aún
    abiertos, así que un parcial de bajada como <code>[21.9, 21.4]</code>
    también sale, y un <code>where((w) =&gt; w.length == 3)</code> tiene
    que montar guardia por un caso que el requisito nunca mencionó.
  </p>
  <p>
    FxDart tiene una palabra para el concepto en sí:
    <code>windowed(3)</code> produce exactamente las ventanas completas, y
    <code>partial: true</code> es la aceptación explícita de la bajada —
    el valor por defecto coincide con lo que una media móvil significa.
    Añade <code>average</code> como función de la biblioteca (RxDart no
    tiene helpers de agregación, así que la media es un
    <code>reduce</code>-y-divide hecho a mano) y el lado pull declara el
    requisito mientras el lado push lo codifica. Ese hueco es de
    vocabulario, no de modelo — pero el vocabulario existe porque las
    ventanas sobre un iterable son una idea nativa del pull, y este se lo
    lleva FxDart.
  </p>
