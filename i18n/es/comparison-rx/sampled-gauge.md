---
slug: sampled-gauge
title: Muestrear el medidor en cada tick de sondeo — RxDart vs FxDart
description: Leer el valor más reciente del medidor en cada tick de sondeo — un stream disparador de sample explícito en RxDart vs sampleOn en la capa de eventos de fxdart 0.7.3.
heading: Muestrear el medidor en cada tick de sondeo
order: 45
tier: 4
functions: fxEvents, sampleOn
domain: sensors
verdict: tie
async: true
---
  <h2>Requisito</h2>
  <p>
    Un medidor de presión emite lecturas 1..8, una cada 50&nbsp;ms. Un
    panel sondea tres veces — a los 125, 275 y 425&nbsp;ms — y cada
    sondeo debe mostrar la lectura <strong>más reciente</strong> en ese
    instante: 2, 5 y luego 8. Imprime las tres lecturas sondeadas después
    de que los streams se cierren. Ambos calendarios están simulados en
    el código; las dos versiones deben imprimir las líneas que aparecen
    bajo <em>Salida esperada</em>.
  </p>

  {{output}}

  <h2>Lado a lado</h2>
  {{comparison}}

  <h2>Por qué difieren</h2>
  <p>
    Ya no difieren. «El valor más reciente en este instante» solo existe
    en el modelo push — presupone que las cosas llegan por su cuenta — y
    ambos paneles lo expresan ahora como la misma frase de un solo
    operador: el stream del medidor, muestreado por el stream de sondeo.
    RxDart escribe <code>gauge().sample(polls())</code>; fxdart escribe
    <code>fxEvents(gauge()).sampleOn(polls())</code>. En ambos, el
    estado de «¿qué es lo actual?» vive dentro del operador, cada
    disparo emite la lectura más nueva desde el anterior, y las lecturas
    no muestreadas simplemente se descartan.
  </p>
  <p>
    Los pipelines pull siguen sin tener reloj ni «valor actual» — esa
    negativa se mantiene. En su lugar, fxdart&nbsp;0.7.3 absorbió el
    enfoque Rx en una capa de eventos dedicada: <code>fxEvents</code> es
    una cadena envoltorio fina sobre <code>Stream</code>s llanos (nunca
    una extensión, así que no colisiona con nada) que posee los verbos
    nativos del push que el lado pull no quiso tener. El catálogo de
    operadores de RxDart sigue siendo mucho más amplio; este verbo,
    fxdart ya lo habla de forma nativa. Y si cada lectura muestreada
    fuera el inicio de trabajo real aguas abajo, <code>.pull()</code>
    entrega las muestras al pipeline <code>FxAsync</code> tipado,
    tiradas bajo demanda.
  </p>
