---
slug: stock-after-moves
title: Nivel de stock tras cada movimiento — RxDart vs FxDart
description: Plegar recepciones y envíos de almacén en un nivel de stock acumulado y marcar los backorders — scan en ambos lados, semillas reproducidas de forma distinta.
heading: Nivel de stock tras cada movimiento
order: 21
tier: 2
functions: fx, scan, map
domain: orders
verdict: tie
async: false
---
  <h2>Requisito</h2>
  <p>
    El libro de almacén de un SKU lista movimientos con signo —
    recepciones en positivo, envíos en negativo — partiendo de un stock
    inicial de 20. Imprime el nivel inicial y luego cada movimiento con el
    nivel resultante, marcando cualquier nivel negativo como backorder.
    Los movimientos están en el código; las dos versiones deben imprimir
    las líneas que aparecen bajo <em>Salida esperada</em>.
  </p>

  {{output}}

  <h2>Lado a lado</h2>
  {{comparison}}

  <h2>Por qué difieren</h2>
  <p>
    El estado acumulado es <code>scan</code> en ambos dialectos — el de
    FxDart es el port de FxTS de la misma idea Rx, así que el fold en sí
    es idéntico: un record acumulador que lleva la etiqueta del movimiento
    y el nivel posterior. La única costura visible es la semilla. El
    <code>scan</code> de FxDart emite la semilla como su primer valor, así
    que la línea inicial <code>start: 20</code> cae de la cadena gratis.
    El <code>scan</code> de RxDart empieza a emitir en el primer pliegue,
    así que el nivel inicial hay que reproducirlo con
    <code>startWith</code> — un operador extra, no una penuria.
  </p>
  <p>
    Pasada la semilla, los dos pipelines son las mismas tres palabras, y
    el <code>map</code> que marca se lee igual de bien en cualquiera de
    los dos lados — la versión pull simplemente se mantiene síncrona
    porque el libro ya está en memoria, mientras que la versión stream
    espera su propia entrega. El estado acumulado sobre una secuencia
    ordenada es terreno propio de ambos modelos: empate, con la diferencia
    de emisión de la semilla como la única curiosidad que conviene
    recordar al portar entre ellos.
  </p>
