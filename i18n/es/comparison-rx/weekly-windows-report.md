---
slug: weekly-windows-report
title: Totales semanales de una serie diaria — RxDart vs FxDart
description: Enrollar 21 días de gasto en tres totales numerados por semana — bufferCount con scan reclutado como contador frente a chunk más zipWithIndex.
heading: Totales semanales de una serie diaria
order: 24
tier: 2
functions: fx, chunk, sumBy, map, zipWithIndex
domain: transactions
verdict: fxdart
async: false
---
  <h2>Requisito</h2>
  <p>
    Tres semanas de gasto diario (del 1 al 21 de agosto, guardado en
    centavos) se enrollan en una línea por semana:
    <code>week n: $total</code>, con el total convertido a dólares a dos
    decimales. Los 21 importes están en el código; las dos versiones deben
    imprimir las tres líneas que aparecen bajo <em>Salida esperada</em>.
  </p>

  {{output}}

  <h2>Lado a lado</h2>
  {{comparison}}

  <h2>Por qué difieren</h2>
  <p>
    El ventaneo en sí queda en tablas: <code>bufferCount(7)</code> y
    <code>chunk(7)</code> son el idioma idéntico para la misma ventana
    fija, y ambos emitirían una ventana final corta si 21 no dividiera
    exacto. El trabajo se parte en <em>numerar</em> las ventanas. RxDart
    no tiene operador con índice, así que la jugada idiomática es reclutar
    a <code>scan</code> como contador — un record acumulador cuyo único
    papel es llevar <code>week + 1</code> junto al búfer. Funciona, pero
    el fold es un espectador vestido con la ropa de un operador de estado.
  </p>
  <p>
    El lado pull tiene una palabra hecha a propósito:
    <code>zipWithIndex</code> empareja cada chunk con su posición de forma
    perezosa, sin acumulador a la vista, y <code>sumBy</code> pliega los
    centavos de cada semana a dólares en el mismo gesto. Ese es el patrón
    recurrente del tier 2 — ambos modelos ventanean bien los datos
    finitos, pero el vocabulario pull es más ancho exactamente donde la
    contabilidad (índices, claves, agregados parciales) se encuentra con
    la ventana. Un operador reutilizado contra uno pensado para esto: el
    veredicto se lo lleva FxDart.
  </p>
