---
slug: top-expenses
title: Los 3 gastos más grandes — Dart vs FxDart
description: Las tres transacciones más grandes del mes — sortedBy + take de package:collection frente a sortBy + take en FxDart.
heading: Los 3 gastos más grandes
order: 1
tier: 1
functions: sortBy, take
alsoLink: chunk, scan
domain: transactions
verdict: tie
async: false
---
  <h2>Requisito</h2>
  <p>
    De un mes de gastos, imprime los <strong>tres más grandes</strong> —
    comercio e importe, de mayor a menor. Los datos están en el código de
    abajo; ambas versiones deben imprimir las líneas que aparecen bajo
    <em>Salida esperada</em>.
  </p>

  {{output}}

  <h2>Lado a lado</h2>
  {{comparison}}

  <h2>Por qué difieren</h2>
  <p>
    Apenas difieren — esto es un empate. Ambos lados ordenan por una clave
    negada para conseguir orden descendente y toman los tres primeros; el
    <code>sortedBy</code> de <code>package:collection</code> es igual de
    directo que el <code>sortBy</code> de FxDart (el <code>List.sort</code>
    del núcleo, por sí solo, mutaría en el sitio y necesitaría un
    comparador explícito, pero <code>collection</code> es una dependencia
    estándar). La única diferencia real está en dónde vive el vocabulario:
    un método de extensión de un paquete frente a un paso de una cadena
    que además ofrece <code>scan</code>, <code>chunk</code> y variantes
    asíncronas. Elige cualquiera de los dos con la conciencia tranquila.
  </p>
