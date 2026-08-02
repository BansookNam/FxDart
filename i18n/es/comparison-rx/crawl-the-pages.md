---
slug: crawl-the-pages
title: Rastrear páginas hasta agotarlas — RxDart vs FxDart
description: Pedir la página siguiente solo al estar listo — un cursor perezoso sin fin tirado bajo demanda vs un Rx.range suficientemente grande cancelado en la primera página vacía.
heading: Rastrear páginas hasta agotarlas
order: 38
tier: 4
functions: fx, toAsync, flatMap, takeWhile, map
domain: orders
verdict: fxdart
async: true
---
  <h2>Requisito</h2>
  <p>
    Una API de pedidos paginada devuelve tres pedidos por página y una
    lista vacía cuando los datos se acaban (página 4). Rastrea página a
    página hasta la página vacía, aplana los pedidos en una sola lista, e
    imprímelos junto a cuántas páginas se obtuvieron realmente —
    exactamente cuatro; el rastreo no debe pedir jamás la página 5. La
    API falsa está en el código; las dos versiones deben imprimir las
    líneas que aparecen bajo <em>Salida esperada</em>.
  </p>

  {{output}}

  <h2>Lado a lado</h2>
  {{comparison}}

  <h2>Por qué difieren</h2>
  <p>
    La paginación <em>es</em> el modelo pull: obtén una página, mírala,
    decide si pedir otra. El lado FxDart escribe eso tal cual — un cursor
    <code>sync*</code> sin fin de números de página que solo avanza
    cuando el pipeline demanda el siguiente,
    <code>map(fetchPage)</code>, <code>takeWhile(isNotEmpty)</code>,
    aplanar. Nada acota el cursor porque la demanda es la cota: cuando
    <code>takeWhile</code> ve la página vacía simplemente deja de tirar,
    y la página 5 ni siquiera llega a generarse.
  </p>
  <p>
    El lado de streams llega al mismo sitio, pero solo tomando prestada
    mecánica pull: un cursor <code>async*</code> sin fin — Dart llano en
    lugar de un operador Rx — <em>pausado</em> hacia un comportamiento
    dirigido por demanda por el backpressure de <code>asyncMap</code>, y
    un <code>takeWhile</code> cuya cancelación detiene el rastreo en la
    página vacía. Funciona, e imprime el mismo
    <code>pages fetched: 4</code> — porque pausar, reanudar y cancelar
    son exactamente el canal de retorno del modelo de streams para
    simular «pregunta otra vez cuando estés listo». El lado pull no
    necesitó la simulación: la demanda es su modo normal. Los trabajos
    donde el estado del consumidor decide si debe existir más entrada
    tienen forma de pull, y este es su caso más limpio.
  </p>
