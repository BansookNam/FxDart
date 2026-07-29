---
slug: top-log-level
title: Nivel de log más frecuente — Dart vs FxDart
description: Contar entradas de log por nivel y quedarse con el mayor — groupListsBy + reduce en Dart nativo frente a countBy + maxBy en FxDart.
heading: Nivel de log más frecuente
order: 7
tier: 1
functions: countBy, maxBy
domain: logs
verdict: fxdart
async: false
---
  <h2>Requisito</h2>
  <p>
    Dado un fragmento de los logs de una aplicación, cuenta cuántas entradas
    tiene cada <strong>nivel</strong> (INFO / WARN / ERROR) e imprime el más
    frecuente junto con su recuento. Los datos están en el código de abajo;
    ambas versiones deben imprimir la línea que aparece bajo <em>Salida
    esperada</em>.
  </p>

  {{output}}

  <h2>Lado a lado</h2>
  {{comparison}}

  <h2>Por qué difieren</h2>
  <p>
    Dart nativo no tiene <code>countBy</code>: lo más parecido es el
    <code>groupListsBy</code> de <code>package:collection</code>, que
    construye una lista con <em>todas las entradas</em> de cada nivel solo
    para que puedas quedarte con sus longitudes — o un bucle con
    <code>Map.update</code> escrito a mano. Elegir después al ganador
    requiere un <code>reduce</code> con una comparación explícita. FxDart
    pone nombre a ambos pasos: <code>countBy</code> va directo a los
    recuentos (es terminal — devuelve un <code>Map</code> corriente), y
    <code>fx(counts.entries).maxBy(...)</code> vuelve a entrar en la cadena
    para elegir la entrada más grande. Dos ideas con nombre en lugar de dos
    construidas a mano.
  </p>
