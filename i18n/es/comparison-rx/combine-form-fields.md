---
slug: combine-form-fields
title: Habilitar el envío cuando el formulario es válido — RxDart vs FxDart
description: Combinar los últimos valores de email y contraseña para gobernar el botón de envío — Rx.combineLatest2 vs un stream etiquetado fusionado a mano y plegado con scan.
heading: Habilitar el envío cuando el formulario es válido
order: 43
tier: 4
functions: fx, streams, scan, filter
domain: users
verdict: rxdart
async: true
---
  <h2>Requisito</h2>
  <p>
    Un formulario de registro tiene dos campos. El campo de email emite
    <code>nam</code>, luego <code>nam@fx.dev</code>; el campo de
    contraseña emite <code>hunter2</code>, luego <code>box-belt-42</code>
    — en desplazamientos fijos intercalados. Tras cada cambio una vez que
    ambos campos hayan emitido, re-evalúa el par de últimos valores
    (válido = el email contiene <code>@</code>, la contraseña ≥ 8
    caracteres) e imprime el estado combinado — tres líneas de los cuatro
    eventos de campo, porque el primer cambio aterriza antes de que la
    contraseña haya hablado; termina con el estado final del botón de
    envío. Las dos versiones deben imprimir las líneas que aparecen bajo
    <em>Salida esperada</em>.
  </p>

  {{output}}

  <h2>Lado a lado</h2>
  {{comparison}}

  <h2>Por qué difieren</h2>
  <p>
    Esto es estado de <em>último-valor-por-fuente</em> — el combinador
    que define el modelo push. <code>Rx.combineLatest2</code> retiene el
    valor más nuevo de cada campo, espera a que ambos hayan hablado, y
    re-emite el par en cada cambio de cualquiera de los lados. La lógica
    del formulario se lee exactamente como el requisito, y las cuatro
    líneas de salida caen de una sola declaración.
  </p>
  <p>
    Un pipeline pull consume <em>una</em> secuencia, así que el lado
    FxDart debe reconstruir primero lo que <code>combineLatest</code>
    consigue gratis: fusionar los dos campos en un único stream de
    eventos etiquetados (un controller escrito a mano, con su propia
    contabilidad de cierre de dos suscripciones), tender el puente con
    <code>fxStream</code>, y luego hacer <code>scan</code> de las
    etiquetas hacia un registro de estado (email, contraseña) y
    <code>filter</code> para descartar los estados donde un campo aún no
    ha emitido. El pliegue en sí es honesto, tipado y legible — pero es
    una reimplementación del operador, no un uso de él. El estado
    reactivo de UI como este es exactamente para lo que RxDart existe, y
    el veredicto es de RxDart sin discusión.
  </p>
