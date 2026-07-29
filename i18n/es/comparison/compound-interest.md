---
slug: compound-interest
title: Tabla de interés compuesto — Dart vs FxDart
description: Una tabla de saldos año a año al 5% — un bucle con acumulador mutable en Dart nativo frente a range + scan + map en FxDart.
heading: Tabla de interés compuesto
order: 16
tier: 2
functions: range, scan, map
domain: general
verdict: fxdart
async: false
---
  <h2>Requisito</h2>
  <p>
    Imprime una tabla de saldos año a año para <strong>$1000 al 5%</strong>
    de interés compuesto durante seis años —una línea por año, empezando por
    el saldo inicial del año 0, con cada importe formateado a dos decimales.
    Las constantes están en el código de abajo; ambas versiones deben
    imprimir las líneas que aparecen bajo <em>Salida esperada</em>.
  </p>

  {{output}}

  <h2>Lado a lado</h2>
  {{comparison}}

  <h2>Por qué difieren</h2>
  <p>
    Un saldo acumulado es un <em>fold acumulado</em>, y Dart nativo no
    tiene una palabra para eso: <code>fold</code> solo da el valor final,
    así que la versión nativa recurre a un bucle que inicializa una lista
    con la línea del año 0, muta <code>balance</code> y va añadiendo —la
    regla de capitalización, la iteración y el formato comparten un mismo
    cuerpo. El <code>scan</code> de FxDart convierte cada saldo intermedio en
    un valor del pipeline: el valor inicial es la fila del año 0, la regla
    de capitalización es una única función pura y el formato es un paso
    <code>map</code> aparte. ¿Quieres el año en que el saldo supera por
    primera vez los $1200? Encadena un filtro —la versión con bucle tiene
    que añadir otro flag en su lugar.
  </p>
