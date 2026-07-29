---
slug: rank-labels
title: Etiquetas de puesto para una tabla de clasificación — Dart vs FxDart
description: Numera de 1 a n una tabla de clasificación ya ordenada — los records de indexed de Dart 3 frente a zipWithIndex + map en FxDart.
heading: Etiquetas de puesto para una tabla de clasificación
order: 9
tier: 1
functions: zipWithIndex, map
alsoLink: fx
domain: users
verdict: tie
async: false
---
  <h2>Requisito</h2>
  <p>
    Una tabla de clasificación ya viene ordenada por puntuación, de mayor a
    menor. Imprime una etiqueta de puesto por jugador —<strong>posición
    empezando en 1, nombre y puntuación</strong>—. Los datos están en el
    código de abajo; ambas versiones deben imprimir las líneas que aparecen
    bajo <em>Salida esperada</em>.
  </p>

  {{output}}

  <h2>Lado a lado</h2>
  {{comparison}}

  <h2>Por qué difieren</h2>
  <p>
    Solo en el nombre. El <code>indexed</code> de Dart 3 produce
    exactamente los mismos records <code>(index, element)</code> que
    produce <code>zipWithIndex</code> en FxDart, así que los dos callbacks
    de <code>map</code> son idénticos carácter por carácter: un empate
    limpio y un buen ejemplo de la librería básica de Dart poniéndose al
    día (antes de los records y de <code>indexed</code>, el lado nativo era
    un contador manual). Usa <code>zipWithIndex</code> cuando ya estés
    dentro de una cadena <code>fx</code> —también existe en las cadenas
    asíncronas— e <code>indexed</code> en todo lo demás.
  </p>
