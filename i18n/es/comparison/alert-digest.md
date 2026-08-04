---
slug: alert-digest
title: Resumen de alertas de log por servicio y severidad — Dart vs FxDart
description: Logs WARN y ERROR presentados como un resumen con sangría — agrupación anidada con groupBy + flatMap + uniq frente a tres bucles anidados y un conjunto seen.
heading: Resumen de alertas de log por servicio y severidad
order: 39
tier: 4
functions: filter, countBy, groupBy, sortBy, flatMap, map, uniq, join
domain: logs
verdict: fxdart
async: false
---
  <h2>Requisito</h2>
  <p>
    A partir de un flujo de logs de servicio (los datos están en el código),
    quédate solo con las líneas <code>WARN</code> y <code>ERROR</code> y
    genera un resumen con sangría: los servicios ordenados por número de
    alertas, bajo cada servicio la severidad con su recuento y, bajo cada
    severidad, los mensajes <em>distintos</em>. La línea de cabecera lleva
    los totales generales de ERROR/WARN. Ambas versiones deben imprimir el
    resumen que aparece bajo <em>Salida esperada</em>.
  </p>

  {{output}}

  <h2>Lado a lado</h2>
  {{comparison}}

  <h2>Por qué difieren</h2>
  <p>
    Un resumen con sangría es un árbol aplanado en líneas, y
    <code>flatMap</code> es exactamente ese aplanado: el
    <code>groupBy</code> + <code>sortBy</code> + <code>flatMap</code> exterior
    emite una cabecera más sus hijos por cada servicio, el
    <code>flatMap</code> interior hace lo mismo por cada severidad, y
    <code>uniq</code> se encarga de los mensajes repetidos allí donde
    aparecen. <code>countBy</code> da los totales de la cabecera en una sola
    palabra. La versión nativa son tres bucles <code>for</code> anidados que
    escriben en una misma lista <code>body</code> compartida, más un mapa de
    conteo hecho a mano y un conjunto <code>seen</code> para deduplicar —la
    forma de árbol es real en ambas versiones, pero solo una de ellas te deja
    leerla en la propia sangría del código.
  </p>
