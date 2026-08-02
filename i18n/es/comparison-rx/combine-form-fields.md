---
slug: combine-form-fields
title: Habilitar el envío cuando el formulario es válido — RxDart vs FxDart
description: Combinar los últimos valores de email y contraseña para gobernar el botón de envío — Rx.combineLatest2 vs combineLatest en la capa de eventos de fxdart 0.8.0.
heading: Habilitar el envío cuando el formulario es válido
order: 43
tier: 4
functions: fxEvents, combineLatest
domain: users
verdict: tie
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
    Ya no difieren. El estado de <em>último-valor-por-fuente</em> es el
    combinador que define el modelo push, y ambos paneles lo declaran
    ahora en una línea: retener el valor más nuevo de cada campo,
    esperar a que ambos hayan hablado, re-emitir el par en cada cambio
    de cualquiera de los lados. RxDart escribe
    <code>Rx.combineLatest2(emails(), passwords(), ...)</code>; fxdart
    escribe <code>fxEvents(emails()).combineLatest(passwords(),
    ...)</code>. La misma regla de espera, la misma re-emisión por
    cualquiera de los lados, el mismo cierre-cuando-ambos-cierran — la
    fusión etiquetada con pliegue que el panel de fxdart solía fabricar
    a mano ha desaparecido.
  </p>
  <p>
    La capa de eventos de fxdart&nbsp;0.8.0 absorbió el enfoque Rx
    exactamente para esta clase de trabajo: una cadena envoltorio
    deliberada sobre <code>Stream</code>s llanos — no una extensión, así
    que convive con rxdart o cualquier otra biblioteca de streams sin
    conflictos — que porta los combinadores de último valor que los
    pipelines pull no pueden tener. Una salvedad honesta se mantiene: el
    catálogo de operadores de RxDart sigue siendo mucho más amplio que
    la capa de eventos de fxdart. Cuando el estado combinado del
    formulario deba gobernar trabajo tipado y dirigido por demanda —
    digamos, una llamada de envío validada con errores tipados —
    <code>.pull()</code> cruza desde los pares en vivo al pipeline
    <code>FxAsync</code>.
  </p>
