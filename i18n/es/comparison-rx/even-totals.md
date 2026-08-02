---
slug: even-totals
title: Suma los importes pares válidos — RxDart vs FxDart
description: Descarta los parseos fallidos, quédate con los pares y suma — un pipeline de Stream con un main asíncrono frente a una sola cadena pull síncrona sobre la misma lista fija.
heading: Suma los importes pares válidos
order: 1
tier: 1
functions: fx, compact, filter, sum
domain: transactions
verdict: fxdart
async: false
---
  <h2>Requisito</h2>
  <p>
    Una importación de extracto produjo una lista de importes parseados en
    la que dos líneas no se pudieron parsear (<code>null</code>). Descarta
    los fallos, quédate con los importes <strong>pares</strong> e imprime
    su total. Los datos están en el código; las dos versiones deben
    imprimir la línea que aparece bajo <em>Salida esperada</em>.
  </p>

  {{output}}

  <h2>Lado a lado</h2>
  {{comparison}}

  <h2>Por qué difieren</h2>
  <p>
    Los pipelines son casi idénticos palabra por palabra —
    <code>whereNotNull → where → fold</code> frente a
    <code>compact → filter → sum</code>. Lo que difiere es todo lo que hay
    <em>alrededor</em>. El lado RxDart tiene que elevar una lista
    corriente a un <code>Stream</code>, volverse asíncrono y hacer
    <code>await</code> de un fold, porque un stream solo entrega valores a
    lo largo de vueltas del event loop — incluso cuando todos los valores
    ya están en memoria. El lado FxDart sigue siendo una expresión
    síncrona: tirar de los valores, sumar, listo.
  </p>
  <p>
    Ese es el tema recurrente de esta Parte: para datos que son
    <em>finitos y ya están aquí</em>, un stream añade un mecanismo de
    entrega que el problema nunca pidió. El vocabulario de operadores de
    RxDart es bueno — <code>whereNotNull</code> es exactamente
    <code>compact</code> — pero el modelo de debajo cobra un impuesto
    asíncrono en cada tarea sobre datos fijos. Aquí la respuesta entera es
    un número, así que la ceremonia — la elevación, el main asíncrono, el
    fold con await — es toda la diferencia entre los dos programas; eso es
    lo que sostiene el veredicto en esta página, mientras que parejas
    posteriores con el mismo residuo se quedan en empate. El veredicto se
    invierte en la Parte 4, donde los valores llegan de verdad a lo largo
    del tiempo y esa misma maquinaria pasa a ser el punto.
  </p>
