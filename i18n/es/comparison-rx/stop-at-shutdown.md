---
slug: stop-at-shutdown
title: Toma hasta el marcador de apagado, inclusive — RxDart vs FxDart
description: Conservar cada evento hasta SHUTDOWN incluido y descartar los rezagados — takeWhileInclusive frente a takeUntilInclusive, el mismo corte en dos grafías.
heading: Toma hasta el marcador de apagado, inclusive
order: 23
tier: 2
functions: fx, takeUntilInclusive, map
domain: logs
verdict: tie
async: false
---
  <h2>Requisito</h2>
  <p>
    El feed de eventos de esta noche contiene un marcador
    <code>SHUTDOWN</code>; todo lo que viene después pertenece a la
    siguiente ejecución y no debe aparecer en el informe. Conserva cada
    evento hasta el marcador, este <em>incluido</em>, e imprime cada uno
    como una línea <code>event:</code>. El feed está en el código; las dos
    versiones deben imprimir las líneas que aparecen bajo
    <em>Salida esperada</em>.
  </p>

  {{output}}

  <h2>Lado a lado</h2>
  {{comparison}}

  <h2>Por qué difieren</h2>
  <p>
    El <code>takeWhile</code> corriente tiene un problema de off-by-one
    para este trabajo: el elemento que rompe el predicado es exactamente
    el que todavía quieres. Ambas bibliotecas traen el arreglo inclusivo,
    escrito desde extremos opuestos — el <code>takeWhileInclusive</code>
    de RxDart sigue <em>mientras no sea el marcador</em>, el
    <code>takeUntilInclusive</code> de FxDart (el <code>takeUntil</code>
    de FxTS, renombrado por claridad en Dart) se detiene <em>en el
    marcador</em>. El mismo corte, con el predicado invertido.
  </p>
  <p>
    Los modelos hasta coinciden en lo que pasa después. Tras emitir el
    marcador, RxDart cancela la suscripción aguas arriba, así que los dos
    eventos rezagados nunca se entregan; FxDart simplemente deja de tirar,
    así que nunca se producen. Como en la búsqueda de presupuesto de la
    Parte&nbsp;1, cancelación y demanda son las palabras de los dos
    modelos para la misma economía — nada aguas abajo puede saber qué
    modelo había debajo. Empate, y una pareja de traducción útil que
    conviene conocer al mover código entre los dos.
  </p>
