---
slug: first-over-budget-rx
title: Primera transacción por encima del presupuesto — RxDart vs FxDart
description: Encontrar la primera transacción por encima de 100 y detenerse — el firstWhere de Rx cancela la suscripción, el find de fxdart deja de tirar; ambos examinan solo 4 de 8.
heading: Primera transacción por encima del presupuesto
order: 1
tier: 1
functions: fx, find
domain: transactions
verdict: tie
async: false
---
  <h2>Requisito</h2>
  <p>
    Recorre el feed de tarjeta de esta semana en orden de llegada e
    informa de la <strong>primera</strong> transacción por encima del
    presupuesto de 100 — y deja de buscar. Imprime también cuántas
    transacciones se examinaron realmente, para demostrar que la búsqueda
    cortocircuitó. Los datos están en el código; las dos versiones deben
    imprimir las líneas que aparecen bajo <em>Salida esperada</em>.
  </p>

  {{output}}

  <h2>Lado a lado</h2>
  {{comparison}}

  <h2>Por qué difieren</h2>
  <p>
    Aquí ambos lados son genuinamente perezosos, cada uno en su propio
    dialecto. El <code>firstWhere</code> de RxDart resuelve su future en
    la primera coincidencia y <strong>cancela la suscripción</strong> —
    las cuatro transacciones restantes nunca se entregan. El
    <code>find</code> de FxDart simplemente <strong>deja de
    tirar</strong> — las cuatro transacciones restantes nunca se
    demandan. Cancelación y demanda son las palabras de cada modelo para
    la misma economía, y la línea «Examined 4 of 8» sale idéntica en
    ambos lados.
  </p>
  <p>
    La diferencia instructiva es <em>dónde vive el contador</em>. Un
    stream tiene un «entre»: <code>doOnData</code> pincha la tubería entre
    operadores, así que el predicado rx se mantiene puro mientras el tap
    observa el tráfico. Una cadena pull no tiene «entre» — el momento de
    la demanda es la propia llamada al predicado, así que el lado FxDart
    cuenta dentro de él. Ninguna de las dos formas es mejor; son los
    idiomas de observación nativos de push y pull. Veredicto: empate — un
    operador cada uno, y ambos se detienen exactamente en el momento
    justo.
  </p>
