---
slug: food-spending
title: Gasto en comida este mes — Dart vs FxDart
description: Suma una sola categoría de un libro de cuentas — una cadena where/fold en Dart nativo frente a filter + sumBy en FxDart.
heading: Gasto en comida este mes
order: 1
tier: 1
functions: filter, sumBy
domain: transactions
verdict: fxdart
async: false
---
  <h2>Requisito</h2>
  <p>
    Dado un mes de transacciones del libro de cuentas —cada una con
    fecha, categoría, comercio e importe—, suma lo que se gastó en la
    categoría <strong>Food</strong> e imprímelo como un importe
    monetario. Los datos están en el código de abajo; las dos versiones
    deben imprimir la línea que aparece bajo <em>Salida esperada</em>.
  </p>

  {{output}}

  <h2>Lado a lado</h2>
  {{comparison}}

  <h2>Por qué difieren</h2>
  <p>
    Dart nativo no tiene una «suma de un campo»: o mutas un acumulador
    dentro de un bucle <code>for</code>, o recurres a <code>fold</code> con
    un valor inicial y un paso de combinación explícitos. El
    <code>sumBy</code> de FxDart dice la intención en una sola palabra, y la
    cadena <code>filter → sumBy</code> se lee en el mismo orden en que
    fluyen los datos. La distancia es pequeña en una tarea de dos
    pasos —se ensancha conforme se añaden pasos.
  </p>
