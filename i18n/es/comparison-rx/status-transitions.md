---
slug: status-transitions
title: Informa solo de los cambios de estado — RxDart vs FxDart
description: Colapsar un feed de salud repetitivo a una línea por racha — Stream.distinct frente a uniqAdjacent, con distinctUnique y uniq como los primos globales.
heading: Informa solo de los cambios de estado
order: 15
tier: 2
functions: fx, uniqAdjacent, uniq, map
domain: logs
verdict: tie
async: false
---
  <h2>Requisito</h2>
  <p>
    Un feed de health checks informa <code>ok, ok, warn, warn, ok, ok, ok</code>
    — repetición sobre todo. Imprime una línea <em>status now</em> por
    <strong>racha</strong> (tres líneas), y luego una única línea
    <code>statuses seen:</code> que liste cada estado distinto en orden de
    primera aparición. Los datos están en el código; las dos versiones
    deben imprimir las líneas que aparecen bajo <em>Salida esperada</em>.
  </p>

  {{output}}

  <h2>Lado a lado</h2>
  {{comparison}}

  <h2>Por qué difieren</h2>
  <p>
    La deduplicación adyacente — «avísame cuando el valor
    <em>cambie</em>» — es un valor de estado recordado en cualquiera de
    los dos modelos, y los dos lados son gemelos línea a línea. La única
    trampa es el nombrado, y corta en direcciones opuestas. En el lado
    stream, el <code>Stream.distinct</code> corriente es <em>ya</em> solo
    adyacente — RxDart añade <code>distinctUnique</code> para la versión
    global que mucha gente espera que sea <code>distinct</code>. FxDart lo
    nombra al revés: <code>uniq</code> es global, como el
    <code>uniq</code> de cualquier biblioteca de colecciones, y
    <code>uniqAdjacent</code> dice la adyacencia en voz alta.
  </p>
  <p>
    Las dos parejas se muestran arriba a propósito: el colapso de rachas
    con <code>distinct</code>&nbsp;/&nbsp;<code>uniqAdjacent</code>, el
    resumen de vistos-en-cualquier-parte con
    <code>distinctUnique</code>&nbsp;/&nbsp;<code>uniq</code>. Fíjate en
    lo que cuestan las versiones globales en cada modelo — un conjunto de
    «vistos» que crece en ambos casos, pero el del stream debe mantenerlo
    durante la vida (potencialmente ilimitada) de una suscripción, y por
    eso RxDart hace de la forma global la opción explícita. En un feed
    finito como este los modelos no se separan en absoluto: empate.
  </p>
