---
slug: price-or-fallback
title: Un precio, o el precio de lista — RxDart vs FxDart
description: Un precio promocional donde exista, el precio de lista donde no — recuperación por elemento como streams internos frente a un try/catch justo al lado de la llamada.
heading: Un precio, o el precio de lista
order: 25
tier: 3
functions: fx, toAsync, map, ifEmpty
domain: orders
verdict: fxdart
async: true
---
  <h2>Requisito</h2>
  <p>
    Cotiza dos órdenes de compra contra el libro de precios promocionales
    de agosto. La búsqueda asíncrona <strong>lanza</strong> para los SKU
    sin precio promocional — esas líneas deben caer a su precio de lista,
    y cada línea debe aparecer en la cotización. Una orden sin líneas se
    cotiza como la única línea <code>(no lines to quote)</code>. Los datos
    están en el código; las dos versiones deben imprimir las líneas que
    aparecen bajo <em>Salida esperada</em>.
  </p>

  {{output}}

  <h2>Lado a lado</h2>
  {{comparison}}

  <h2>Por qué difieren</h2>
  <p>
    Un stream lleva sus valores y sus errores por <em>canales
    separados</em>, y el canal de errores pertenece al pipeline entero.
    Para cuando un <code>onErrorReturnWith</code> colocado tras un
    <code>asyncMap</code> viera el fallo, la línea que lo causó ya habría
    desaparecido — un evento de error lleva el error, no el elemento. La
    recuperación idiomática en RxDart es darle a cada búsqueda su propio
    stream <em>interno</em> — <code>flatMap</code> hacia
    <code>Rx.fromCallable</code> — de modo que cada fallo sea terminal
    solo para su propio stream de un elemento, donde la línea sigue a mano
    para el fallback.
  </p>
  <p>
    En el modelo pull no hay un segundo canal por el que caer. La búsqueda
    es un <code>await</code> dentro del callback de <code>map</code>, así
    que la recuperación es control de flujo ordinario de Dart: atrapa el
    <code>StateError</code> tipado justo al lado de la llamada y devuelve
    el precio de lista — el elemento, su fallback y el manejo del error
    viven todos en las mismas cuatro líneas. Sin envolver, sin volver a
    mezclar, y el fallo no llega a tocar el pipeline en ningún momento.
  </p>
  <p>
    La segunda orden, vacía, aterriza igual en ambos lados —
    <code>defaultIfEmpty</code>, un operador que FxDart tomó de Rx. El
    veredicto se lo lleva FxDart por el plato principal: la recuperación
    de errores por elemento es una frase en el modelo pull y una
    construcción en el modelo push.
  </p>
