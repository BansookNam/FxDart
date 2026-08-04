---
slug: spend-by-category-rx
title: Gasto agrupado por categoría — RxDart vs FxDart
description: Totales por categoría en orden de primera aparición — un stream de GroupedStreams plegado y vuelto a mezclar frente a un groupBy que simplemente devuelve un Map.
heading: Gasto agrupado por categoría
order: 17
tier: 2
functions: fx, groupedBy, map, sumBy
domain: transactions
verdict: fxdart
async: false
---
  <h2>Requisito</h2>
  <p>
    Totaliza nueve transacciones de agosto <strong>por categoría</strong>,
    e imprime los totales en el orden en que cada categoría aparece por
    primera vez en el extracto. Los datos están en el código; las dos
    versiones deben imprimir las líneas que aparecen bajo
    <em>Salida esperada</em>.
  </p>

  {{output}}

  <h2>Lado a lado</h2>
  {{comparison}}

  <h2>Por qué difieren</h2>
  <p>
    El agrupado es donde el compromiso del modelo push con «todo es un
    stream» sale caro. El <code>groupBy</code> de RxDart no puede devolver
    un mapa — la fuente podría no terminar nunca — así que devuelve un
    <em>stream de streams</em>: un <code>GroupedStream</code> por cada
    clave nueva. Para sacar los totales, cada stream interno debe plegarse
    (un <code>Future</code>), el future elevarse de vuelta a stream
    (<code>asStream</code>) y los resultados mezclarse con
    <code>flatMap</code> — tres capas de fontanería alrededor de un
    <code>sum</code>. (Un usuario rx pragmático puede esquivar
    <code>groupBy</code> por completo plegando el stream entero en un mapa
    mutable — más corto, pero abandona el operador del que trata este
    ejemplo y el agrupado vuelve a ser imperativo.) Y la forma tiene
    aristas afiladas: pliega con <code>asyncExpand</code> en lugar de
    <code>flatMap</code> y el programa entra en deadlock, porque pausar el
    stream exterior mientras se espera el total de un grupo detiene la
    fuente que debe completarse antes de que ningún grupo pueda cerrarse.
  </p>
  <p>
    Los datos de FxDart son finitos por construcción, así que agrupar no
    necesita streams-de-streams: <code>groupedBy</code> produce records
    <code>(key, items)</code> corrientes en orden de primera aparición de
    la clave y la cadena sigue adelante, con <code>sumBy</code> haciendo
    la aritmética por grupo. Nada se aplaza porque nada sigue llegando.
    Para feeds vivos e ilimitados el diseño de GroupedStream es la
    decisión correcta — pero para un extracto que ya está en la mano, este
    es un trabajo con forma de pull y la versión pull lo dice en tres
    líneas. El veredicto se lo lleva FxDart.
  </p>
