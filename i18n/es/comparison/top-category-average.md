---
slug: top-category-average
title: Categoría con el gasto medio más alto — Dart vs FxDart
description: Agrupar gastos y encontrar la categoría más cara por transacción — llamadas anidadas a groupBy + maxBy de collection en Dart nativo frente a una sola cadena de FxDart.
heading: Categoría con el gasto medio más alto
order: 18
tier: 2
functions: groupBy, map, maxBy
domain: transactions
verdict: fxdart
async: false
---
  <h2>Requisito</h2>
  <p>
    Dado un mes de gastos —cada uno con fecha, categoría e importe—,
    encuentra la categoría con el <strong>importe medio por transacción más
    alto</strong> e imprímela con la media formateada a dos decimales. Los
    datos están en el código de abajo; ambas versiones deben imprimir la
    línea que aparece bajo <em>Salida esperada</em>.
  </p>

  {{output}}

  <h2>Lado a lado</h2>
  {{comparison}}

  <h2>Por qué difieren</h2>
  <p>
    El núcleo de Dart no tiene ni <code>groupBy</code> ni
    <code>maxBy</code>; <code>package:collection</code> aporta ambos — pero
    como funciones de nivel superior, no como pasos de una cadena. La
    versión nativa se lee por tanto de dentro afuera:
    <code>maxBy(</code>… envolviendo un <code>map</code> sobre las
    entradas de un <code>groupBy(</code>… — tres modismos (llamada a
    función, cadena de métodos, llamada a función) para una sola idea de
    tres pasos. FxDart mantiene el orden de lectura igual al del flujo de
    datos: <code>groupBy</code> sobre las transacciones, <code>map</code>
    de cada grupo a <code>(category, average)</code>, <code>maxBy</code>
    sobre la media. El mismo algoritmo, pero la frase se lee de izquierda a
    derecha.
  </p>
