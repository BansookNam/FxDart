---
slug: pipeline-into-stream
title: Un pipeline alimenta a un consumidor de streams — RxDart vs FxDart
description: Un fetch ordenado con mapConcurrent entrega sus resultados a un consumidor de streams vía toStream — el puente cruzado en la otra dirección.
heading: Un pipeline alimenta a un consumidor de streams
order: 47
tier: 4
functions: fx, toAsync, mapConcurrent, chunk, streams
domain: orders
verdict: tie
async: true
---
  <h2>Requisito</h2>
  <p>
    Obtén cinco estados de pedido, como mucho dos peticiones en vuelo,
    resultados en orden de origen — y luego entrégalos a un consumidor
    aguas abajo que los agrupa en pares e imprime cada lote. Los retardos
    de consulta están fijados en el código; las dos versiones deben
    imprimir las líneas que aparecen bajo <em>Salida esperada</em>.
  </p>

  {{output}}

  <h2>Lado a lado</h2>
  {{comparison}}

  <h2>Por qué difieren</h2>
  <p>
    RxDart corre streams de punta a punta: <code>flatMap</code> con
    <code>maxConcurrent: 2</code> acota los fetches y
    <code>bufferCount(2)</code> empareja los resultados. Una salvedad
    vive en el medio: el <code>flatMap</code> concurrente emite en orden
    de <em>terminación</em>, así que este panel solo imprime en orden de
    origen porque los retardos dan la casualidad de completarse así — el
    reordenamiento bajo concurrencia es el comportamiento por defecto del
    modelo push, y conservar el orden de origen en general significa
    recoger y ordenar.
  </p>
  <p>
    El panel FxDart es el puente del ejemplo anterior cruzado en la otra
    dirección. La mitad de los fetches es un pipeline pull —
    <code>mapConcurrent(2, …)</code> es ordenado por construcción, hagan
    lo que hagan los retardos — <code>chunk(2)</code> (el
    <code>bufferCount</code> de FxDart) empareja los resultados, y
    <code>toStream()</code> entrega los lotes a cualquier consumidor de
    streams. Aquí ese consumidor solo imprime, y en una app RxDart podría
    seguir con operadores Rx sobre el stream puenteado: al productor no
    le importa quién consume. Esa división del trabajo es el veredicto:
    haz el trabajo acotado, ordenado y tipado en el pipeline pull,
    exponlo como un <code>Stream</code>, y deja que el mundo push tome el
    relevo donde el vocabulario push (buffering, debouncing, enlace de
    UI) encaja mejor. Empate — el puente es el punto.
  </p>
