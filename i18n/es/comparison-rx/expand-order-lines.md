---
slug: expand-order-lines
title: Aplana los pedidos en líneas — RxDart vs FxDart
description: Aplanar cuatro pedidos en sus diez líneas pedido/sku — Stream.expand y el flatMap de fxdart son la misma palabra para uno-a-muchos, en orden de origen.
heading: Aplana los pedidos en líneas
order: 9
tier: 1
functions: fx, flatMap, map
domain: orders
verdict: tie
async: false
---
  <h2>Requisito</h2>
  <p>
    Los cuatro pedidos de ayer contienen dos o tres líneas cada uno.
    Aplánalos en una sola lista de líneas <code>order/sku</code> — cada
    artículo bajo el id de su pedido, en orden de origen — e imprime el
    recuento de líneas. Los datos están en el código; las dos versiones
    deben imprimir las líneas que aparecen bajo <em>Salida esperada</em>.
  </p>

  {{output}}

  <h2>Lado a lado</h2>
  {{comparison}}

  <h2>Por qué difieren</h2>
  <p>
    El aplanado uno-a-muchos es roca madre en ambos modelos, y para una
    carga síncrona las dos formas son la misma palabra:
    <code>Stream.expand</code> y el <code>flatMap</code> de FxDart toman
    ambos <em>elemento a iterable</em>, empalman las piezas en orden de
    origen y entregan el resultado a un <code>map</code> de formateo. Los
    paneles son paralelos línea a línea.
  </p>
  <p>
    La divergencia interesante queda justo fuera del escenario. Cuando las
    líneas de cada pedido llegaran <em>de forma asíncrona</em>, el lado Rx
    pasaría al <code>flatMapIterable</code> o al <code>flatMap</code> de
    RxDart — streams <em>internos</em>, donde el orden de mezcla se vuelve
    una pregunta real (intercalado por terminación salvo que concatenes).
    El <code>flatMap</code> asíncrono de FxDart, sobre un pipeline del que
    se tira, se mantiene en orden de origen por construcción. Pero esa es
    una historia del tier 4; en este trabajo en memoria ambos lados
    expresan el aplanado directamente — el panel Rx ni siquiera necesita
    un operador de RxDart, el <code>Stream</code> del core lo lleva — y el
    único rastro es el main asíncrono. Empate.
  </p>
