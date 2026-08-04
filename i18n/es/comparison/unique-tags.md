---
slug: unique-tags
title: Todas las etiquetas de las entradas, ordenadas — Dart vs FxDart
description: Aplanar las etiquetas de las entradas en una sola lista ordenada y sin repetidos — expand + toSet + sort en Dart nativo frente a flatMap + uniq + sort en FxDart. Un empate honesto.
heading: Todas las etiquetas de las entradas, ordenadas
order: 12
tier: 2
functions: flatMap, uniq, sort
domain: general
verdict: tie
async: false
---
  <h2>Requisito</h2>
  <p>
    Cada entrada del blog lleva una lista de etiquetas. Construye el índice
    de etiquetas del sitio: aplana las etiquetas de todas las entradas en una
    sola secuencia, elimina los duplicados, ordénalas alfabéticamente e
    imprímelas en una única línea separada por comas. Los datos están en el
    código de abajo; ambas versiones deben imprimir la línea que aparece bajo
    <em>Salida esperada</em>.
  </p>

  {{output}}

  <h2>Lado a lado</h2>
  {{comparison}}

  <h2>Por qué difieren</h2>
  <p>
    Apenas difieren. <code>expand</code> es el <code>flatMap</code> de Dart,
    <code>toSet()</code> elimina duplicados y una cascada
    <code>..sort()</code> remata el trabajo — esa única línea es Dart honesto
    e idiomático, y no tiene nada de malo. FxDart deletrea esos mismos tres
    pasos como eslabones con nombre de una cadena (<code>flatMap → uniq →
    sort</code>), lo que se lee un poco más como el requisito y deja
    explícito que <code>uniq</code> preserva el orden, en lugar de que sea un
    efecto secundario de haber elegido un <code>Set</code>. Elige el que ya
    hable tu base de código — esto es un empate.
  </p>
