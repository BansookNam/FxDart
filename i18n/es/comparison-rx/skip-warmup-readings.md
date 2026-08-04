---
slug: skip-warmup-readings
title: Salta las lecturas de calentamiento — RxDart vs FxDart
description: Descartar las lecturas bajas iniciales de una sonda y conservar todo lo demás — skipWhile y dropWhile son la misma compuerta de un solo sentido; hasta los operadores son del core.
heading: Salta las lecturas de calentamiento
order: 9
tier: 1
functions: fx, dropWhile, map
domain: sensors
verdict: tie
async: false
---
  <h2>Requisito</h2>
  <p>
    Una sonda de temperatura lee bajo mientras se calienta. Descarta las
    lecturas <strong>iniciales</strong> por debajo de 20.0&nbsp;°C,
    formatea todo lo que viene después de la primera lectura real —
    incluidas caídas posteriores, que son datos de verdad — e imprime
    cuántas lecturas sobrevivieron. Los datos están en el código; las dos
    versiones deben imprimir las líneas que aparecen bajo
    <em>Salida esperada</em>.
  </p>

  {{output}}

  <h2>Lado a lado</h2>
  {{comparison}}

  <h2>Por qué difieren</h2>
  <p>
    No difieren, y ese es el hallazgo. <code>skipWhile</code> y
    <code>dropWhile</code> son la misma compuerta de un solo sentido:
    descarta mientras el predicado se cumple, se abre de forma permanente
    en el primer fallo y no vuelve a cerrarse — por eso la caída de
    18.7&nbsp;°C posterior al calentamiento sobrevive en ambos lados. Es
    una compuerta sobre la <em>posición en la secuencia</em>, no sobre el
    valor, y ambos modelos tienen un nombre para ella.
  </p>
  <p>
    Merece la pena notarlo: el panel RxDart es puro <code>dart:async</code>
    en este trabajo — <code>skipWhile</code>, <code>map</code> y
    <code>toList</code> vienen todos en el <code>Stream</code> del core,
    así que el import de RxDart no gana nada aquí. Así se ve el solape del
    tier 1 desde la otra dirección: a veces el vocabulario compartido vive
    en la propia plataforma. El único resto es el modelo de entrega — un
    main <code>async</code> y un <code>await</code> para recolectar lo que
    una cadena pull devuelve como un valor corriente, sin event loop de
    por medio. Empate.
  </p>
