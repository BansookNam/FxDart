---
slug: no-spend-streak
title: La racha más larga de días sin gastar — Dart vs FxDart
description: La racha más larga de días de julio sin ninguna transacción — bucle con contadores de racha y máximo en Dart nativo frente a range + scan + max en FxDart.
heading: La racha más larga de días sin gastar
order: 28
tier: 3
functions: range, map, scan, max, join
domain: transactions
verdict: fxdart
async: false
---
  <h2>Requisito</h2>
  <p>
    A partir de un mes de transacciones del libro de cuentas, encuentra la
    <strong>racha más larga de días consecutivos de julio sin ningún
    gasto</strong> (julio de 2026 tiene 31 días). Imprime una tira de
    calendario que marque con <code>#</code> cada día sin gasto y, después,
    la longitud de la racha. Los datos están en el código de abajo; ambas
    versiones deben imprimir las líneas que aparecen bajo
    <em>Salida esperada</em>.
  </p>

  {{output}}

  <h2>Lado a lado</h2>
  {{comparison}}

  <h2>Por qué difieren</h2>
  <p>
    Una racha es un valor que se va acumulando, y ese es exactamente el
    trabajo de <code>scan</code>: todos los estados intermedios de un
    fold, conservados. El pipeline se lee como la propia definición — los
    días (<code>range</code>), transformados con <code>map</code> a
    hubo-gasto-o-no, recorridos con <code>scan</code> hasta formar una
    racha acumulada que se reinicia en los días con gasto, y
    <code>max</code> elige el pico. El bucle nativo calcula lo mismo con
    dos contadores mutables y un <code>if</code> — lo verificas
    reproduciendo mentalmente las iteraciones, y la lógica de la racha
    queda fundida con la construcción de la tira que hay al lado. En la
    versión de FxDart la tira (<code>map</code> + <code>join</code>) y la
    racha son dos pipelines independientes, legibles por separado, sobre
    el mismo <code>range</code>.
  </p>
