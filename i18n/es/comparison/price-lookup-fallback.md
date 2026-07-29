---
slug: price-lookup-fallback
title: Consulta concurrente de precios con fallback — Dart vs FxDart
description: Consulta precios en vivo de tres en tres y recurre a los precios de catálogo para los SKU que faltan — concurrent + un map con ?? frente a un pool de workers.
heading: Consulta concurrente de precios con fallback
order: 43
tier: 4
functions: toAsync, map, concurrent, filter, size, sumBy
domain: orders
verdict: fxdart
async: true
---
  <h2>Requisito</h2>
  <p>
    Calcula el precio de un pedido de seis líneas. Cada SKU se consulta en
    el servicio de precios en vivo —con un máximo de <strong>tres
    consultas en vuelo</strong>—, pero al servicio le faltan algunos SKU y
    devuelve <code>null</code> para ellos; esas líneas recurren al precio
    de catálogo que lleva el propio artículo. Imprime cada línea con su
    precio en orden (señalando los fallbacks), el número de fallbacks, el
    total del pedido y la concurrencia máxima observada. Todos los datos
    están en el código de abajo.
  </p>
  <p>
    La cadena de FxDart hace la consulta bajo <code>concurrent(3)</code> y
    después un segundo <code>map</code> aplica el fallback con un simple
    <code>??</code>: la política de recuperación no es más que otro paso
    del pipeline, aguas abajo de la petición acotada.
  </p>

  {{output}}

  <h2>Lado a lado</h2>
  {{comparison}}

  <h2>Por qué difieren</h2>
  <p>
    El fallback en sí es fácil en ambas versiones —<code>??</code> es
    Dart—. Lo que le falta a Dart nativo es el paso previo: hacer las
    consultas de tres en tres con los resultados en el orden de entrada
    obliga a recurrir al modismo del pool de workers (cursor compartido,
    huecos predimensionados, <code>Future.wait</code>), y la lógica del
    fallback acaba enterrada dentro del cuerpo del worker, donde es más
    difícil de ver y de probar. En la versión con FxDart, la consulta y la
    recuperación son dos etapas separadas y visibles de una misma cadena
    —<code>concurrent(3)</code> es dueño del límite, el <code>map</code>
    siguiente es dueño de la política— y las líneas del resumen
    (<code>filter</code> + <code>size</code> para los fallbacks,
    <code>sumBy</code> para el total) reutilizan el mismo vocabulario que
    enseña el resto del sitio.
  </p>
