---
slug: per-row-retry
title: Reintentar cada fila inestable por separado — RxDart vs FxDart
description: Seis filas de importación inestables, dos intentos cada una, tres en vuelo — flatMap emite en orden de terminación, mapRetry bajo concurrent conserva el orden de origen.
heading: Reintentar cada fila inestable por separado
order: 31
tier: 3
functions: fx, toAsync, retry, concurrent
domain: orders
verdict: fxdart
async: true
---
  <h2>Requisito</h2>
  <p>
    Importa seis filas a través de un endpoint inestable: las filas pares
    fallan exactamente una vez antes de tener éxito. Da a <strong>cada
    fila su propio presupuesto de reintentos</strong> de dos intentos,
    ejecuta hasta tres filas a la vez, e imprime los resultados
    <strong>en orden de origen</strong> con el número del intento que tuvo
    éxito. La inyección de fallos y los retardos por fila son
    deterministas y están en el código; las dos versiones deben imprimir
    las líneas que aparecen bajo <em>Salida esperada</em>.
  </p>

  {{output}}

  <h2>Lado a lado</h2>
  {{comparison}}

  <h2>Por qué difieren</h2>
  <p>
    Ambos lados expresan la mitad de resiliencia igual: un envoltorio de
    retry por fila, de modo que una fila inestable se re-ejecuta mientras
    sus vecinas pasan sin tropiezos. RxDart lo escribe
    <code>flatMap</code> hacia un stream interno con reintentos por fila
    con <code>maxConcurrent:&nbsp;3</code>; FxDart lo escribe
    <code>mapRetry(2,&nbsp;…)</code> bajo <code>concurrent(3)</code>,
    donde cada elemento en vuelo lleva su propio presupuesto
    independiente.
  </p>
  <p>
    La diferencia es lo que sale por el otro extremo.
    <code>flatMap</code> fusiona los streams internos en orden de
    <em>terminación</em> — ese es su contrato — así que con tres filas en
    vuelo y retardos desiguales, los resultados llegan barajados.
    Recuperar el orden de origen significa etiquetar cada resultado con
    su id de fila y ordenar después de <code>toList</code>. El operador de
    RxDart que sí conservaría el orden, <code>concatMap</code>, lo hace
    renunciando a la concurrencia — una fila a la vez. En el modelo pull,
    la concurrencia ordenada es el modo nativo: <code>concurrent(3)</code>
    evalúa tres pulls a la vez pero los entrega en orden de origen por
    construcción, así que no hay nada que etiquetar ni nada que ordenar.
  </p>
  <p>
    Veredicto FxDart — el orden es la historia. «N a la vez, reintentadas
    por separado, en orden» es una sola cadena en el modelo pull y un
    rodeo de fusionar-y-reordenar en el modelo push.
  </p>
