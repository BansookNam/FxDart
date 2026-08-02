---
slug: stream-into-pipeline
title: Un stream alimenta un pipeline tipado — RxDart vs FxDart
description: Un stream de logs en vivo fluye hacia un pipeline pull tipado a través de fxStream — conservar los warnings, ponerlos en mayúsculas y contar, a ambos lados del puente.
heading: Un stream alimenta un pipeline tipado
order: 49
tier: 4
functions: fx, streams, filter, map, toList
domain: logs
verdict: tie
async: true
---
  <h2>Requisito</h2>
  <p>
    Un feed de logs en vivo emite siete líneas con un calendario fijo y
    se cierra. Conserva solo los warnings, ponlos en mayúsculas para el
    canal de incidentes, e imprímelos con un conteo final. El feed está
    simulado en el código (de forma idéntica en ambos lados); las dos
    versiones deben imprimir las líneas que aparecen bajo
    <em>Salida esperada</em>.
  </p>

  {{output}}

  <h2>Lado a lado</h2>
  {{comparison}}

  <h2>Por qué difieren</h2>
  <p>
    Apenas difieren — y ese es el sentido de este par. La fuente es una
    cosa nativa del push, un <code>Stream</code> que emite cuando le
    place, y RxDart se queda en ese modelo: <code>mapNotNull</code>
    filtra y formatea en un operador, <code>toList</code> recoge al
    cierre. Limpio, idiomático, listo.
  </p>
  <p>
    El lado FxDart no pelea contra el stream ni re-modela la fuente — le
    <em>tiende un puente</em>. <code>fxStream</code> envuelve cualquier
    <code>Stream</code> como un iterable async basado en pull, y a partir
    de ahí el código es la misma cadena tipada que escribirías sobre una
    lista: <code>filter</code>, <code>map</code>, <code>toList</code>. El
    puente guarda en buffer los eventos empujados hasta que el pipeline
    los demanda, así que nada se pierde y el orden se conserva. Este es
    un ejemplo de cooperación, no de contienda: deja que el stream sea un
    stream en el borde donde nacen los eventos, y cruza a un pipeline
    pull en el momento en que quieras procesamiento tipado y dirigido por
    demanda — los dos modelos se componen en una línea. Empate, y
    deliberadamente.
  </p>
