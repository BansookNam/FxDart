---
slug: running-balance-feed
title: Saldo acumulado de un feed de depósitos — RxDart vs FxDart
description: Plegar un feed de depósitos y retiradas en un saldo acumulado — el scan de Rx frente al scan de fxdart, una acumulación por movimiento en ambos lados.
heading: Saldo acumulado de un feed de depósitos
order: 2
tier: 1
functions: scan
domain: transactions
verdict: tie
async: false
---
  <h2>Requisito</h2>
  <p>
    Una cuenta abre a cero y recibe siete movimientos — depósitos en
    positivo, retiradas en negativo. Imprime el saldo tras cada
    movimiento, una línea por paso. Los datos están en el código; las dos
    versiones deben imprimir las líneas que aparecen bajo
    <em>Salida esperada</em>.
  </p>

  {{output}}

  <h2>Lado a lado</h2>
  {{comparison}}

  <h2>Por qué difieren</h2>
  <p>
    Apenas difieren. El estado acumulado es un fold con sus pasos
    intermedios expuestos, y ambas bibliotecas llaman a ese fold
    <code>scan</code> — RxDart como transformador de stream, FxDart como
    operador perezoso portado del mismo linaje Rx. Una acumulación por
    movimiento, en orden, en ambos lados.
  </p>
  <p>
    Las diferencias visibles son detalles de cadencia, no de modelo. El
    <code>scan</code> de RxDart toma una semilla y emite un valor por
    evento (su acumulador recibe además un índice); el <code>scan</code>
    con semilla de FxDart sigue a FxTS y produce primero la semilla misma,
    así que el panel usa el <code>scan1</code> sin semilla — para un saldo
    que abre a cero, cada suma parcial <em>es</em> el saldo, y las dos
    cadencias encajan exactamente. Más allá de eso, el único residuo es la
    entrega: la versión stream recolecta a través de un main
    <code>async</code>, la versión pull es una sola cadena síncrona. Un
    empate justo — ambos lados dicen el requisito con un único operador.
  </p>
