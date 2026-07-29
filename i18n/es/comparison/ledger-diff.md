---
slug: ledger-diff
title: Diff de dos snapshots de un libro de cuentas — Dart vs FxDart
description: Entradas añadidas, eliminadas y sin cambios entre dos snapshots — differenceBy e intersectionBy por id frente a conjuntos de id construidos a mano y filtros where.
heading: Diff de dos snapshots de un libro de cuentas
order: 40
tier: 4
functions: differenceBy, intersectionBy, sortBy, map, concat, size, sumBy, join
domain: transactions
verdict: fxdart
async: false
---
  <h2>Requisito</h2>
  <p>
    Dos snapshots del mismo libro de cuentas (los datos están en el
    código): entre uno y otro hubo una sincronización, y se añadieron y
    eliminaron entradas. Imprime un diff basado en el id de cada
    entrada —líneas <code>+</code> para las entradas añadidas y
    <code>-</code> para las eliminadas (cada sección ordenada por id), el
    número de entradas sin cambios y la variación neta del importe total.
    Ambas versiones deben imprimir el diff que aparece bajo <em>Salida
    esperada</em>.
  </p>

  {{output}}

  <h2>Lado a lado</h2>
  {{comparison}}

  <h2>Por qué difieren</h2>
  <p>
    Hacer un diff es álgebra de conjuntos sobre una clave, y FxDart trae
    ese vocabulario de serie: llamar a <code>differenceBy</code> en los
    dos sentidos da lo añadido y lo eliminado, e
    <code>intersectionBy</code> da las entradas sin cambios —tres
    declaraciones que se leen como la definición misma de un diff. El
    pipeline <code>sortBy</code> → <code>map</code> → <code>concat</code>
    renderiza después las dos secciones en una sola expresión. Dart nativo
    solo tiene operaciones de conjuntos para el propio <code>Set</code>,
    no para «por esta clave de estos objetos», así que la versión honesta
    proyecta a mano los conjuntos de id y escribe un filtro
    <code>contains</code> negado por cada sentido —fácil de invertir sin
    querer, y la intención («¿qué hay en B que no esté en A?») acaba
    viviendo en la polaridad del predicado en lugar de en el nombre de una
    función.
  </p>
