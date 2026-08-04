---
slug: empty-report-default
title: Una línea por defecto para un informe vacío — RxDart vs FxDart
description: Filtrar a una categoría sin coincidencias y aun así imprimir algo — defaultIfEmpty en el stream frente a ifEmpty en la cadena pull, la misma idea en ambos modelos.
heading: Una línea por defecto para un informe vacío
order: 7
tier: 1
functions: fx, filter, ifEmpty, map
domain: transactions
verdict: tie
async: false
---
  <h2>Requisito</h2>
  <p>
    Un informe de gastos filtra las transacciones de este mes a la
    categoría <code>travel</code> — y no hay ninguna. Un informe vacío no
    debe quedarse sin imprimir nada: debe imprimir en su lugar una única
    línea de <em>no travel spending</em>. Los datos están en el código;
    las dos versiones deben imprimir la línea que aparece bajo
    <em>Salida esperada</em>.
  </p>

  {{output}}

  <h2>Lado a lado</h2>
  {{comparison}}

  <h2>Por qué difieren</h2>
  <p>
    Casi en nada — y en el mismo sitio. «El vacío necesita un fallback» es
    un problema con el que ambos modelos chocan exactamente en el mismo
    lugar — una etapa aguas abajo no puede distinguir <em>filtrado hasta
    quedar en nada</em> de <em>nunca hubo nada</em> a menos que el
    pipeline diga qué emitir en ese caso — y ambas bibliotecas responden
    con un operador. El <code>defaultIfEmpty</code> de RxDart inyecta el
    valor por defecto cuando la fuente se completa sin ningún evento; el
    <code>defaultIfEmpty</code> de FxDart (añadido en 0.7.2, tomado
    abiertamente del vocabulario Rx, con
    <code>ifEmpty(() =&gt; fallback)</code> como forma perezosa sobre el
    iterable completo) lo produce cuando el primer tirón no encuentra
    nada.
  </p>
  <p>
    La diferencia residual es la habitual en esta Parte: la versión stream
    tiene que enterarse de que está vacía <em>esperando a la
    terminación</em>, así que el programa entero se vuelve asíncrono sobre
    una lista fija, mientras que la versión pull descubre el vacío de
    forma síncrona en la primera demanda. Ese coste es real pero pequeño
    aquí, y la paridad de operadores es la historia — un empate genuino, y
    un bonito ejemplo de las dos bibliotecas intercambiando ideas en lugar
    de competir.
  </p>
