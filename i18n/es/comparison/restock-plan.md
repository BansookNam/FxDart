---
slug: restock-plan
title: Plan de reposición de inventario — Dart vs FxDart
description: Prioriza los artículos por debajo del umbral y corta la lista de pedidos al llegar al presupuesto — scan + zip + takeWhile como flujo de datos frente a un total acumulado mutable y un break.
heading: Plan de reposición de inventario
order: 37
tier: 4
functions: filter, sortBy, scan, drop, zip, takeWhile, map, sumBy, join
domain: orders
verdict: fxdart
async: false
---
  <h2>Requisito</h2>
  <p>
    A partir de una lista de existencias (los datos están en el código),
    encuentra los artículos <strong>por debajo de su stock mínimo</strong>,
    priorízalos por mayor déficit y pídelos en ese orden de prioridad, pero
    detente antes de que el <strong>coste acumulado supere el presupuesto
    de $500</strong>. Imprime cada pedido planificado con su total
    acumulado y luego un resumen de lo que se pidió y de lo que queda.
    Ambas versiones deben imprimir el plan que aparece bajo <em>Salida
    esperada</em>.
  </p>

  {{output}}

  <h2>Lado a lado</h2>
  {{comparison}}

  <h2>Por qué difieren</h2>
  <p>
    El corte por presupuesto es la parte interesante. FxDart convierte el
    total acumulado en <em>datos</em>: <code>scan</code> produce el flujo
    de costes acumulados, <code>zip</code> empareja cada artículo con su
    total acumulado y <code>takeWhile</code> corta el plan en el
    presupuesto —la regla de corte es un predicado en una sola línea, y los
    totales acumulados ya están ahí para imprimirlos—. Dart nativo lo
    entrelaza todo en un único bucle: una variable mutable
    <code>running</code>, un <code>break</code> anticipado y el formateo
    comparten el cuerpo del bucle, de modo que la política («para cuando te
    pases del presupuesto») vive dentro del flujo de control en lugar de
    ser una etapa visible del pipeline que podrías mover o probar por
    separado.
  </p>
