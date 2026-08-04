---
slug: running-balance
title: Saldo acumulado de una cuenta — Dart vs FxDart
description: El saldo después de cada transacción — un bucle con acumulador mutable en Dart nativo frente a scan + map en FxDart.
heading: Saldo acumulado de una cuenta
order: 7
tier: 1
functions: scan, map
domain: transactions
verdict: fxdart
async: false
---
  <h2>Requisito</h2>
  <p>
    Una cuenta abre julio con un saldo de <strong>$250.00</strong> y
    registra seis transacciones con signo: la nómina que entra, el alquiler
    y la compra que salen. Imprime una línea en formato de moneda por cada
    paso: primero el saldo de apertura y después el saldo <strong>tras cada
    transacción</strong>. Los datos están en el código de abajo; ambas
    versiones deben imprimir las líneas que aparecen bajo <em>Salida
    esperada</em>.
  </p>

  {{output}}

  <h2>Lado a lado</h2>
  {{comparison}}

  <h2>Por qué difieren</h2>
  <p>
    El núcleo de Dart tiene <code>fold</code>, que colapsa la lista hasta
    el saldo <em>final</em>, pero esta tarea necesita todos los
    intermedios, y no hay <code>scan</code>. Así que la versión nativa
    recurre a una variable mutable <code>balance</code> hilada a través de
    un bucle, y el formateo queda entremezclado con la acumulación. El
    <code>scan</code> de FxDart emite cada estado acumulado como un valor
    (primero el valor inicial, lo que regala la línea del saldo de
    apertura) y <code>map</code> formatea después, como un paso aparte e
    intercambiable. El estado acumulado como etapa de un pipeline en lugar
    de como una mutación es justo el vocabulario que le falta aquí a Dart.
  </p>
