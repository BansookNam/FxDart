---
slug: multi-currency-report
title: Informe de gastos multidivisa — Dart vs FxDart
description: Normaliza a USD el libro de cuentas de un viaje con tipos fijos y luego agrupa, ordena y resume — un pipeline por línea de informe frente al boilerplate de fold/reduce.
heading: Informe de gastos multidivisa
order: 36
tier: 4
functions: map, groupBy, sumBy, sortBy, uniq, maxBy, join
domain: transactions
verdict: fxdart
async: false
---
  <h2>Requisito</h2>
  <p>
    El libro de cuentas de un viaje (los datos están en el código) mezcla
    importes en EUR, GBP, JPY y USD. Convierte todo a USD con los tipos
    fijos del código y después informa de: los totales por categoría
    ordenados por gasto, las divisas que aparecen, el mayor gasto
    individual (con su importe original) y el total general. Ambas
    versiones deben imprimir el informe que aparece bajo <em>Salida
    esperada</em>.
  </p>

  {{output}}

  <h2>Lado a lado</h2>
  {{comparison}}

  <h2>Por qué difieren</h2>
  <p>
    Normalizar primero —<code>map</code> de cada transacción a un par
    <code>(tx, usd)</code>— permite que todas las preguntas posteriores
    se resuelvan sobre una sola lista: <code>groupBy</code> +
    <code>sumBy</code> + <code>sortBy</code> para el desglose,
    <code>uniq</code> para la lista de divisas, <code>maxBy</code> y
    <code>sumBy</code> para las líneas de resumen. Cada línea del informe
    es un pipeline corto que da nombre a su agregación. La versión nativa
    hace exactamente los mismos movimientos, pero sin el vocabulario: cada
    suma es un <code>fold</code> con valor inicial, el máximo es un
    comparador de <code>reduce</code> escrito a mano y la lista de divisas
    necesita el baile de <code>toSet().toList()..sort()</code>. Nada de
    esto es difícil —simplemente hay más de todo, y menos de todo dice lo
    que significa.
  </p>
