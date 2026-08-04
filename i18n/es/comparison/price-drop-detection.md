---
slug: price-drop-detection
title: Bajadas de precio entre dos instantáneas — Dart vs FxDart
description: Compara dos instantáneas de una lista de precios e informa de lo que se abarató — indexBy + filter + sortBy + head + sumBy frente a un literal de Map y cadenas where/fold.
heading: Bajadas de precio entre dos instantáneas
order: 53
tier: 4
functions: indexBy, filter, map, sortBy, head, sumBy, join
domain: orders
verdict: fxdart
async: false
---
  <h2>Requisito</h2>
  <p>
    Dos instantáneas de la lista de precios de una tienda (los datos están
    en el código): junio y julio. Algunos artículos se abarataron, otros se
    encarecieron, uno se descatalogó y otro es nuevo. Informa de cada
    artículo que <strong>bajó de precio</strong> —precio anterior, precio
    nuevo y la bajada—, ordenado de mayor a menor bajada, más una mención
    destacada a la mayor bajada individual y al ahorro total. Ambas
    versiones deben imprimir el informe que aparece bajo <em>Salida
    esperada</em>.
  </p>

  {{output}}

  <h2>Lado a lado</h2>
  {{comparison}}

  <h2>Por qué difieren</h2>
  <p>
    Toda la tarea es un único flujo: indexar junio por SKU, quedarse con
    los artículos de julio que se abarataron, emparejar cada uno con su
    bajada y ordenar por bajada. FxDart tiene un paso con nombre para cada
    movimiento —<code>indexBy</code> para la tabla de búsqueda,
    <code>filter</code> → <code>map</code> → <code>sortBy</code> para el
    pipeline, y después <code>head</code> y <code>sumBy</code> reutilizan
    la misma lista de resultados para las líneas del resumen—. Dart nativo
    puede expresarlo —un literal de Map para el índice,
    <code>where</code>/<code>map</code>/<code>sortedBy</code> para la
    cadena—, pero el vocabulario está disperso: <code>fold</code> con un
    valor inicial en lugar de <code>sumBy</code>,
    <code>sortedBy&lt;num&gt;</code> con una clave negada y ningún nombre
    para «constrúyeme una tabla de búsqueda por clave».
  </p>
