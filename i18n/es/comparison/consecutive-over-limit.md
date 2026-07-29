---
slug: consecutive-over-limit
title: Tres lecturas consecutivas por encima del límite — Dart vs FxDart
description: Encuentra cada ventana de 3 horas de lecturas de CO2 todas por encima de 1000 ppm — un bucle con índices en Dart nativo frente a una ventana deslizante construida con zip + drop en FxDart.
heading: Tres lecturas consecutivas por encima del límite
order: 24
tier: 3
functions: zip, drop, filter, map, join
domain: sensors
verdict: fxdart
async: false
---
  <h2>Requisito</h2>
  <p>
    Lecturas horarias de CO2 de un día. Marca cada ventana de <strong>tres
    lecturas consecutivas todas por encima de 1000 ppm</strong> —eso
    significa que la ventilación no pudo recuperarse durante tres horas
    seguidas— e imprime cada ventana como un rango de horas inicio–fin bajo
    una línea de cabecera. Los datos están en el código de abajo; ambas
    versiones deben imprimir las líneas que aparecen bajo
    <em>Salida esperada</em>.
  </p>

  {{output}}

  <h2>Lado a lado</h2>
  {{comparison}}

  <h2>Por qué difieren</h2>
  <p>
    Dart nativo no tiene ventana deslizante, así que la versión nativa es
    un bucle con índices, con una cota <code>i + 2 &lt; length</code> y tres
    accesos manuales —correcto, pero cada pieza es contabilidad que quien lo
    lea tiene que verificar. La versión de FxDart construye la ventana como
    <em>datos</em>: aplica <code>zip</code> a la lista consigo misma
    desplazada uno y dos lugares (<code>drop(1)</code>,
    <code>drop(2)</code>), y cada elemento pasa a ser una terna (lectura,
    siguiente, la siguiente de esa). Sin índices por ningún lado. Que
    <code>zip</code> se detenga en la entrada más corta es exactamente la
    regla de «la ventana cabe entera» que el bucle codifica en su cota.
    Ampliar la ventana a 4 horas es una línea más de <code>zip</code>, no
    una reauditoría de la aritmética.
  </p>
