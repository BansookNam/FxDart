---
slug: duplicate-transactions
title: Detectar transacciones duplicadas — Dart vs FxDart
description: Marca los cargos con el mismo comercio, importe y día — putIfAbsent más bucles anidados en Dart nativo frente a groupBy + filter + flatMap en FxDart.
heading: Detectar transacciones duplicadas
order: 21
tier: 3
functions: groupBy, filter, flatMap, map, join
domain: transactions
verdict: fxdart
async: false
---
  <h2>Requisito</h2>
  <p>
    Un cargo que aparece dos veces con el mismo <strong>comercio, importe
    y día</strong> es, probablemente, un doble pago. Encuentra cada grupo
    así en las transacciones de julio y lista <em>cada transacción
    implicada</em> para que el usuario pueda revisarlas, pero no marques el
    mismo comercio e importe en días <em>distintos</em> (un café que se
    repite no es un duplicado). Los datos están en el código de abajo; las
    dos versiones deben imprimir las líneas que aparecen bajo
    <em>Salida esperada</em>.
  </p>

  {{output}}

  <h2>Lado a lado</h2>
  {{comparison}}

  <h2>Por qué difieren</h2>
  <p>
    El algoritmo es agrupar–conservar–aplanar, y FxDart lo escribe
    exactamente con esas tres palabras: <code>groupBy</code> por la clave
    comercio|importe|día, <code>filter</code> de los grupos con más de un
    miembro, <code>flatMap</code> de los supervivientes de vuelta a
    transacciones individuales (<code>map</code> + <code>join</code> les dan
    formato). Dart nativo no tiene ninguna de las tres como vocabulario:
    agrupar se convierte en un bucle con <code>putIfAbsent</code>, y
    conservar-y-aplanar, en bucles <code>for</code> anidados con un
    <code>if</code> entre medias. Ambas son correctas; solo una sigue
    pareciéndose a la frase que la especificaba.
  </p>
