---
slug: sampled-gauge
title: Muestrear el medidor en cada tick de sondeo — RxDart vs FxDart
description: Leer el valor más reciente del medidor en cada tick de sondeo — un stream disparador de sample explícito vs una variable de último valor llevada a mano y leída a través del puente.
heading: Muestrear el medidor en cada tick de sondeo
order: 42
tier: 4
functions: fx, streams, map
domain: sensors
verdict: rxdart
async: true
---
  <h2>Requisito</h2>
  <p>
    Un medidor de presión emite lecturas 1..8, una cada 50&nbsp;ms. Un
    panel sondea tres veces — a los 125, 275 y 425&nbsp;ms — y cada
    sondeo debe mostrar la lectura <strong>más reciente</strong> en ese
    instante: 2, 5 y luego 8. Imprime las tres lecturas sondeadas después
    de que los streams se cierren. Ambos calendarios están simulados en
    el código; las dos versiones deben imprimir las líneas que aparecen
    bajo <em>Salida esperada</em>.
  </p>

  {{output}}

  <h2>Lado a lado</h2>
  {{comparison}}

  <h2>Por qué difieren</h2>
  <p>
    «El valor más reciente en este instante» es un concepto que solo
    existe en el modelo push — significa <em>lo último que haya
    llegado</em>, lo cual presupone que las cosas llegan por su cuenta.
    El <code>sample</code> de RxDart toma el stream del medidor y un
    stream disparador y hace exactamente este trabajo: en cada disparo,
    emite el valor de la fuente más nuevo desde el disparo anterior. Un
    operador, y el estado («¿qué es lo actual?») vive dentro de él.
  </p>
  <p>
    Un pipeline pull no tiene «valor actual» — nada llega hasta que
    preguntas. Así que el lado FxDart divide el trabajo en dos: una
    suscripción llana sigue la lectura más reciente del medidor en una
    variable mutable, y el stream de sondeo entra por
    <code>fxStream</code> para que cada tick tirado pueda hacer
    <code>map</code> a una instantánea de esa variable. Imprime las
    mismas tres lecturas, pero la lógica de muestreo es código push
    escrito a mano que se sienta <em>junto a</em> la cadena, no expresado
    por ella. Veredicto RxDart: muestrear estado vivo es nativo del push
    — este partido se juega en casa del push.
  </p>
