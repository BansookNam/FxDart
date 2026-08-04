---
slug: latency-percentiles
title: Latencia p50/p95 por endpoint — Dart vs FxDart
description: Tabla de percentiles a partir de logs de peticiones en crudo — groupBy + sortBy + nth por endpoint frente a un bucle que acumula filas con ordenaciones in situ.
heading: Latencia p50/p95 por endpoint
order: 40
tier: 4
functions: filter, groupBy, map, sortBy, nth, maxBy, join
domain: logs
verdict: fxdart
async: false
---
  <h2>Requisito</h2>
  <p>
    A partir de logs de peticiones en crudo (los datos están en el código),
    descarta las peticiones fallidas y calcula la <strong>latencia p50 y
    p95 por endpoint</strong>: ordena las latencias de cada endpoint y toma
    el valor situado en el índice
    <code>round((n-1) * q / 100)</code>. Imprime una tabla ordenada por el
    peor p95 primero y luego señala el peor endpoint. Las dos versiones
    deben imprimir la tabla que aparece bajo <em>Salida esperada</em>.
  </p>

  {{output}}

  <h2>Lado a lado</h2>
  {{comparison}}

  <h2>Por qué difieren</h2>
  <p>
    Un percentil es «ordena y luego indexa»: en FxDart eso es literalmente
    <code>sortBy</code> + <code>nth</code>, aplicados dentro de un pipeline
    <code>groupBy</code> → <code>map</code> que convierte cada grupo de
    endpoint en una fila de estadísticas; ordenar la tabla y encontrar el
    peor endpoint reutilizan esas mismas filas con <code>sortBy</code> y
    <code>maxBy</code>. La versión nativa hace las mismas cuentas, pero a
    través de una lista mutable de filas rellenada en un bucle
    <code>for</code>, un <code>..sort()</code> in situ, acceso por índice en
    crudo y un comparador con <code>reduce</code> para el máximo. Ambas son
    correctas; el lado de fxdart mantiene «agrupar → resumir → ordenar»
    como tres trazos visibles en lugar de un solo bucle que hace los tres a
    la vez.
  </p>
