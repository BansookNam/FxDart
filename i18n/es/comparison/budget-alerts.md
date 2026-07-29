---
slug: budget-alerts
title: Categorías que superan su presupuesto mensual — Dart vs FxDart
description: Gasto total por categoría, quedarse con las que se pasan del presupuesto y ordenarlas por exceso — contabilidad con mapas mutables en Dart nativo frente a groupBy + filter + sortBy en FxDart.
heading: Categorías que superan su presupuesto mensual
order: 25
tier: 3
functions: groupBy, map, filter, sortBy, join
domain: transactions
verdict: fxdart
async: false
---
  <h2>Requisito</h2>
  <p>
    Cada categoría de gasto tiene un presupuesto mensual. A partir de las
    transacciones de julio, suma el total de cada categoría, quédate solo
    con las categorías que <strong>se pasaron de su presupuesto</strong> e
    imprímelas empezando por la peor —con el gasto, el presupuesto y el
    exceso en cada línea. Los datos están en el código de abajo; ambas
    versiones deben imprimir las líneas que aparecen bajo
    <em>Salida esperada</em>.
  </p>

  {{output}}

  <h2>Lado a lado</h2>
  {{comparison}}

  <h2>Por qué difieren</h2>
  <p>
    La línea de formato es idéntica en ambas versiones —la diferencia está
    en todo lo que viene antes. Dart nativo hace la agrupación a mano en un
    mapa mutable y luego cambia de modismo dos veces: un bucle
    <code>for</code> para sumar, un <code>where</code> para filtrar, un
    <code>sort</code> en cascada con un comparador hecho a mano para
    ordenar. La versión de FxDart es un solo vocabulario de principio a fin:
    <code>groupBy</code>, <code>map</code> a los totales,
    <code>filter</code> contra el presupuesto, <code>sortBy</code> por el
    exceso, <code>join</code>. Cada regla de negocio —pasarse del
    presupuesto, la peor primero— es un paso con nombre que puedes señalar
    en una revisión de código.
  </p>
