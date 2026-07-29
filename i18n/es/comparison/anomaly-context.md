---
slug: anomaly-context
title: Anomalías con su contexto alrededor — Dart vs FxDart
description: Muestra las lecturas de sensor por encima del límite más una línea antes y otra después — zipWithIndex + flatMap + uniq como un solo pipeline frente a un conjunto de índices construido en bucles anidados.
heading: Anomalías con su contexto alrededor
order: 34
tier: 4
functions: zipWithIndex, filter, flatMap, uniq, map, maxBy, join
domain: sensors
verdict: fxdart
async: false
---
  <h2>Requisito</h2>
  <p>
    Un sensor de temperatura registró diez lecturas (los datos están en el
    código). Imprime todas las lecturas <strong>por encima de
    80.0&nbsp;C</strong> —marcadas con <code>!</code>— junto con la lectura
    <em>inmediatamente anterior y posterior</em>, tal como
    <code>grep -C1</code> muestra las líneas de contexto. Donde las ventanas
    de contexto se solapan, cada lectura aparece una sola vez. Termina con la
    lectura máxima. Ambas versiones deben imprimir el bloque que aparece bajo
    <em>Salida esperada</em>.
  </p>

  {{output}}

  <h2>Lado a lado</h2>
  {{comparison}}

  <h2>Por qué difieren</h2>
  <p>
    «Cada coincidencia se expande a una ventana y luego las ventanas que se
    solapan se fusionan» es un problema de aplanar y deduplicar, y FxDart lo
    escribe exactamente así: <code>zipWithIndex</code> conserva las
    posiciones, <code>filter</code> encuentra las anomalías,
    <code>flatMap</code> expande cada una a <code>[i-1, i, i+1]</code> y
    <code>uniq</code> fusiona los solapamientos —una única expresión
    ininterrumpida que va de las lecturas a las líneas impresas. Dart nativo
    no tiene un modismo de <code>flatMap</code>-hacia-<code>uniq</code> para
    esto, así que la versión natural construye un
    <code>Set&lt;int&gt;</code> de índices en bucles <code>for</code>
    anidados, lo ordena y da formato en un segundo bucle —el mismo
    algoritmo, pero partido en tres fases mutables.
  </p>
