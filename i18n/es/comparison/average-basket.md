---
slug: average-basket
title: Valor medio de los pedidos de más de $100 — Dart vs FxDart
description: Total medio de los pedidos grandes — where/map/average con package:collection frente a filter + averageBy en FxDart.
heading: Valor medio de los pedidos de más de $100
order: 5
tier: 1
functions: filter, averageBy
domain: orders
verdict: tie
async: false
---
  <h2>Requisito</h2>
  <p>
    De un lote de pedidos de una tienda, quédate solo con los que suman
    <strong>más de $100</strong> e imprime su <strong>valor medio</strong>
    como importe monetario. Los datos están en el código de abajo; ambas
    versiones deben imprimir la línea que aparece bajo
    <em>Salida esperada</em>.
  </p>

  {{output}}

  <h2>Lado a lado</h2>
  {{comparison}}

  <h2>Por qué difieren</h2>
  <p>
    Siendo sinceros: no mucho —es un empate. Dart nativo necesitaría un
    fold con contador (o una suma dividida por una longitud, recorriendo los
    datos dos veces), pero el <code>.average</code> de
    <code>package:collection</code> cierra esa brecha y deja
    <code>where → map → average</code> frente a
    <code>filter → averageBy</code>. FxDart se ahorra el <code>map</code>
    intermedio al aceptar directamente la función de clave, y
    <code>averageBy</code> es una palabra en vez de una propiedad de
    extensión sobre un iterable proyectado —vocabulario, no victoria. Ambas
    se leen bien.
  </p>
