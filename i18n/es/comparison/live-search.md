---
slug: live-search
title: Búsqueda en vivo sobre un stream de pulsaciones — Dart vs FxDart
description: Convierte un stream de pulsaciones en búsquedas de backend sin duplicados — fromStream + filter + uniq + take + map frente a await-for con cláusulas de guarda.
heading: Búsqueda en vivo sobre un stream de pulsaciones
order: 45
tier: 4
functions: streams, filter, uniq, take, map, head
alsoLink: debounce
domain: general
verdict: fxdart
async: true
---
  <h2>Requisito</h2>
  <p>
    Un cuadro de búsqueda emite cada pulsación de tecla como un
    <code>Stream</code> de Dart —alguien escribiendo hacia
    <em>darts</em>, con algunos valores repetidos por la repetición
    automática del teclado (secuencia fija en el código de abajo).
    Conviértelo en búsquedas de backend: descarta las consultas de menos
    de dos caracteres, no busques nunca dos veces la misma consulta,
    detente después de cuatro consultas buscadas e imprime cada consulta
    con su número de resultados y el mejor resultado —además de cuántas
    llamadas al backend se hicieron realmente.
  </p>
  <p>
    Con <code>fxStream</code> el stream de pulsaciones se convierte en un
    pipeline y cada regla se convierte en un operador: <code>filter</code>
    para el mínimo de longitud, <code>uniq</code> para las repeticiones,
    <code>take(4)</code> para el presupuesto, y después <code>map</code>
    realiza la búsqueda. Como <code>take</code> está antes del paso de
    búsqueda y la cadena está basada en pull, se producen exactamente
    cuatro llamadas al backend y la cola del stream no se consume nunca.
  </p>

  {{output}}

  <h2>Lado a lado</h2>
  {{comparison}}

  <h2>Por qué difieren</h2>
  <p>
    El bucle nativo <code>await for</code> es compacto —pero fíjate en
    dónde han acabado las reglas: el mínimo de longitud y la
    deduplicación comparten una única expresión <code>continue</code>
    (<code>q.length &lt; 2 || !seen.add(q)</code>, que cuela una mutación
    dentro de una condición), y el presupuesto es una comprobación de
    contador con un <code>break</code>. Tres políticas comprimidas en dos
    cláusulas de guarda; añadir una cuarta implica desenredarlas. El
    pipeline gasta un operador con nombre por regla, en el orden en que se
    aplican, y esa misma cadena aceptaría sin cambios el stream de cambios
    de texto de un widget real. Una advertencia honesta: el
    <code>debounce</code> de fxdart es una utilidad para llamadas a
    funciones, no un operador de stream —silenciar por tiempo un stream
    parlanchín es una herramienta distinta de las cuatro reglas que se ven
    aquí.
  </p>
