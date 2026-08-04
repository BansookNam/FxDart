---
slug: latency-extremes
title: La petición más rápida y la más lenta — RxDart vs FxDart
description: Sondear ocho endpoints de forma asíncrona e imprimir la latencia mínima y máxima — reducciones que devuelven Future en ambos lados, una pasada fresca cada una.
heading: La petición más rápida y la más lenta
order: 24
tier: 2
functions: fx, toAsync, min, max
domain: logs
verdict: tie
async: true
---
  <h2>Requisito</h2>
  <p>
    Un health check sondea ocho endpoints a través de una llamada
    asíncrona <code>measure</code> e informa de la latencia más rápida y
    la más lenta en milisegundos. Las muestras fijas están en el código;
    las dos versiones deben imprimir las dos líneas que aparecen bajo
    <em>Salida esperada</em>.
  </p>

  {{output}}

  <h2>Lado a lado</h2>
  {{comparison}}

  <h2>Por qué difieren</h2>
  <p>
    Las reducciones son donde push y pull convergen: para conocer el
    extremo tienes que ver la secuencia entera, así que tanto
    <code>min</code> como <code>max</code> son terminales y ambos
    devuelven un <code>Future</code>. Las versiones de RxDart aceptan
    además un comparador opcional para elementos que no son
    <code>Comparable</code>; FxDart mantiene <code>min</code> y
    <code>max</code> como terminales numéricos y cubre los casos con clave
    con <code>minBy</code>/<code>maxBy</code>. Sobre enteros planos las
    dos llamadas son idénticas palabra por palabra — el lado FxDart solo
    eleva antes los tirones a una cadena asíncrona con
    <code>toAsync</code>.
  </p>
  <p>
    La arruga espejada es que <em>cada</em> reducción consume la fuente.
    Un stream de Dart es de suscripción única, así que pedir el mínimo y
    luego el máximo significa dos suscripciones — de ahí la fábrica
    <code>latencies()</code> del lado RxDart. El lado FxDart tiene la
    misma forma por la misma razón: una llamada terminal drena la cadena,
    así que la segunda reducción tira de una fresca. Ambos, por tanto,
    miden dos veces (recolectar primero en una lista es la alternativa
    compartida), y ningún modelo tiene una ventaja que merezca
    reclamarse: empate, decidido por hacia dónde fluye ya el código de
    alrededor.
  </p>
