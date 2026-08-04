---
slug: last-three-errors
title: Los últimos tres errores — RxDart vs FxDart
description: Conservar las líneas ERROR e imprimir las tres últimas — takeLast espera el evento done, takeRight drena el iterable; ambos almacenan exactamente tres.
heading: Los últimos tres errores
order: 6
tier: 1
functions: fx, filter, takeRight
domain: logs
verdict: tie
async: false
---
  <h2>Requisito</h2>
  <p>
    Del log del servicio de esta mañana, quédate solo con las líneas
    <code>ERROR</code> e imprime las <strong>tres últimas</strong>, la más
    antigua primero. Los datos están en el código; las dos versiones deben
    imprimir las líneas que aparecen bajo <em>Salida esperada</em>.
  </p>

  {{output}}

  <h2>Lado a lado</h2>
  {{comparison}}

  <h2>Por qué difieren</h2>
  <p>
    «Las tres últimas» tiene un coste estructural que ningún operador
    puede esquivar: no puedes saber que un elemento está entre los tres
    últimos hasta haber visto el final. Por eso ambos lados
    <strong>almacenan</strong> — una ventana de tres huecos en la que cada
    nuevo error entra empujando y de la que el más antiguo cae — y ambos
    la vuelcan solo cuando la fuente termina. El <code>takeLast</code> de
    RxDart no emite nada hasta que llega el <em>evento done</em>; el
    <code>takeRight</code> de FxDart mantiene la misma ventana mientras
    drena el iterable hasta el <em>agotamiento</em>. El mismo algoritmo,
    ajustado a la palabra de cada modelo para «no hay más elementos».
  </p>
  <p>
    Aguas arriba de eso, <code>where</code> y <code>filter</code> son
    intercambiables. La única nota de modelo que merece hacerse: en un
    stream sin límite <code>takeLast</code> no emite jamás — «las tres
    últimas» solo tiene sentido para fuentes que terminan, territorio
    nativo para un iterable finito y un caso especial para un stream. En
    este log acotado ambos expresan el trabajo directamente, así que el
    veredicto es un empate.
  </p>
