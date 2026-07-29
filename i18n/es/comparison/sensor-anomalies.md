---
slug: sensor-anomalies
title: Emparejar sensores con lecturas y quedarse con las anomalías — Dart vs FxDart
description: Une dos listas paralelas y señala las lecturas altas — un bucle con índice en Dart nativo (el núcleo no tiene zip) frente a zip + filter + map en FxDart.
heading: Emparejar sensores con lecturas y quedarse con las anomalías
order: 17
tier: 2
functions: zip, filter, map
domain: sensors
verdict: fxdart
async: false
---
  <h2>Requisito</h2>
  <p>
    Una API de telemetría devuelve dos <strong>listas paralelas</strong>:
    los nombres de los sensores y sus últimas lecturas de temperatura,
    emparejados por posición. Emparéjalos, quédate con las lecturas por
    encima de <strong>90.0 °C</strong> e imprime una línea de alerta por
    anomalía, en el orden de la lista. Los datos están en el código de
    abajo; ambas versiones deben imprimir las líneas que aparecen bajo
    <em>Salida esperada</em>.
  </p>

  {{output}}

  <h2>Lado a lado</h2>
  {{comparison}}

  <h2>Por qué difieren</h2>
  <p>
    El núcleo de Dart no tiene <code>zip</code>.
    <code>package:collection</code> ofrece <code>IterableZip</code>, pero
    empareja iterables del mismo tipo —juntar un
    <code>List&lt;String&gt;</code> con un <code>List&lt;double&gt;</code>
    degrada ambos a <code>Object</code> y mete casts en tu predicado—, así
    que en la práctica los desarrolladores de Dart escriben el bucle con
    índice que ves aquí. El bucle es correcto, pero el emparejamiento vive
    en la contabilidad posicional (<code>sensors[i]</code>,
    <code>readings[i]</code>) y no produce nada que puedas pasar más
    adelante ni seguir filtrando. El <code>zip</code> de FxDart emite pares
    de records tipados <code>(String, double)</code>, así que la
    comprobación de anomalías y el formateo se quedan en pasos corrientes
    de la cadena sobre valores reales.
  </p>
