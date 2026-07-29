---
slug: sparse-timeseries
title: Rellenar huecos en una serie temporal dispersa — Dart vs FxDart
description: Los días sin transacciones pasan a 0.00, y luego filas semanales con totales — range + groupBy + chunk como un solo flujo frente a un bucle con contador y slices.
heading: Rellenar huecos en una serie temporal dispersa
order: 35
tier: 4
functions: groupBy, range, map, sumBy, chunk, zipWithIndex, join
domain: transactions
verdict: fxdart
async: false
---
  <h2>Requisito</h2>
  <p>
    Las transacciones del 1 al 14 de julio (los datos están en el código)
    solo existen en algunos días. Construye la serie diaria
    <strong>densa</strong> — los días sin transacciones cuentan como
    <code>0.00</code> — y luego imprímela como dos filas semanales, cada una
    con sus 7 valores diarios y un total de la semana. Ambas versiones deben
    imprimir el bloque que aparece bajo <em>Salida esperada</em>.
  </p>

  {{output}}

  <h2>Lado a lado</h2>
  {{comparison}}

  <h2>Por qué difieren</h2>
  <p>
    Rellenar huecos significa dirigir el pipeline desde el
    <em>calendario</em>, no desde los datos: <code>range(1, 15)</code>
    genera todos los días, <code>groupBy</code> responde a «qué pasó ese
    día», y <code>sumBy</code> sobre un grupo posiblemente vacío da gratis el
    0.00 de los días tranquilos. La agrupación semanal es entonces
    <code>chunk(7)</code> + <code>zipWithIndex</code> — remodelar la serie
    densa sin un solo cálculo de índice más allá de la etiqueta de la fila.
    Dart nativo obtiene la serie densa con un <code>for</code> contador y la
    agrupación con <code>slices</code>/<code>indexed</code> de
    <code>package:collection</code> — funciona, pero el paso de sumar un
    grupo es un <code>fold</code> con valor inicial las dos veces, y las dos
    fases no se componen en un único flujo visible.
  </p>
