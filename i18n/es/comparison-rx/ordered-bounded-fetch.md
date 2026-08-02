---
slug: ordered-bounded-fetch
title: Obtener de 4 en 4, resultados en orden — RxDart vs FxDart
description: Ocho fetches, cuatro en vuelo, impresos en orden de origen — mapConcurrent es ordenado por construcción; flatMap(maxConcurrent) debe etiquetar y reordenar.
heading: Obtener de 4 en 4, resultados en orden
order: 35
tier: 4
functions: fx, toAsync, mapConcurrent
domain: users
verdict: fxdart
async: true
---
  <h2>Requisito</h2>
  <p>
    Obtén ocho perfiles de usuario cuyos tiempos de respuesta difieren,
    manteniendo como mucho <strong>4</strong> peticiones en vuelo a la
    vez — e imprime los resultados en <strong>orden de origen</strong>
    (el usuario 1 primero), más el máximo de peticiones en vuelo
    observado como prueba del límite. Los retardos están en el código;
    las dos versiones deben imprimir las líneas que aparecen bajo
    <em>Salida esperada</em>.
  </p>

  {{output}}

  <h2>Lado a lado</h2>
  {{comparison}}

  <h2>Por qué difieren</h2>
  <p>
    Ambos lados acotan la concurrencia en un operador, y el contador
    compartido muestra que ambos alcanzan de verdad 4 en vuelo. La
    división es por el <em>orden</em>.
    <code>flatMap(maxConcurrent: 4)</code> es una fusión: emite cada
    resultado interno en el momento en que se completa, así que con estos
    retardos el usuario 7 (10&nbsp;ms) se imprimiría antes que el usuario
    1 (80&nbsp;ms). Para cumplir el requisito el lado RxDart etiqueta
    cada resultado con su id, lo recoge todo y ordena al final — el orden
    que tenía la fuente lo destruye la fusión y hay que reconstruirlo a
    mano al terminar.
  </p>
  <p>
    <code>mapConcurrent(4, fetch)</code> nunca pierde el orden en primer
    lugar. En un pipeline pull, la concurrencia es una propiedad de la
    <em>demanda</em>, no de la entrega: el operador lanza cuatro pulls
    solapados pero entrega los resultados aguas abajo en el orden en que
    se pidieron, reteniendo una llegada rápida y tardía hasta que sus
    predecesoras más lentas hayan salido. Acotado-y-ordenado es la forma
    que la mayoría del trabajo por lotes realmente quiere — resultados
    alineados con las entradas, límites de tasa respetados — y aquí es el
    comportamiento por defecto en lugar de una reconstrucción. Cuando el
    orden de terminación es lo que de verdad quieres, eso también existe
    — <code>concurrentPool</code>, el siguiente ejemplo — pero es la
    variante que eliges, no el comportamiento que deshaces.
  </p>
