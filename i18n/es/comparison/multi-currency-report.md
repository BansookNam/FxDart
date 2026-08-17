---
slug: multi-currency-report
title: Informe de gastos multidivisa — Dart vs FxDart
description: Normaliza a USD el libro de cuentas de un viaje con tipos fijos y luego agrupa, ordena y resume — un pipeline por línea de informe frente al boilerplate de fold/reduce.
heading: Informe de gastos multidivisa
order: 31
tier: 4
functions: map, foldBy, sumBy, sortBy, uniq, maxBy, join
domain: transactions
verdict: fxdart
async: false
---
  <h2>Requisito</h2>
  <p>
    El libro de cuentas de un viaje (los datos están en el código) mezcla
    importes en EUR, GBP, JPY y USD. Convierte todo a USD con los tipos
    fijos del código y después informa de: los totales por categoría
    ordenados por gasto, las divisas que aparecen, el mayor gasto
    individual (con su importe original) y el total general. Ambas
    versiones deben imprimir el informe que aparece bajo <em>Salida
    esperada</em>.
  </p>

  {{output}}

  <h2>Lado a lado</h2>
  {{comparison}}

  <h2>Por qué difieren</h2>
  <p>
    Normalizar primero —<code>map</code> de cada transacción a un par
    <code>(tx, usd)</code>— permite que todas las preguntas posteriores
    se resuelvan sobre una sola lista: <code>foldBy</code> +
    <code>sortBy</code> para el desglose, <code>uniq</code> para la lista de
    divisas, <code>maxBy</code> y <code>sumBy</code> para las líneas de
    resumen. Cada línea del informe es un pipeline corto que da nombre a su
    agregación. La versión nativa hace exactamente los mismos movimientos,
    pero sin el vocabulario: los totales por categoría son un acumulador de
    mapa hecho a mano, la ordenación necesita un comparador escrito a mano, el
    máximo es un comparador de <code>reduce</code> y la lista de divisas
    necesita el baile de <code>toSet().toList()..sort()</code>. Nada de esto
    es difícil —simplemente hay más de todo, y menos de todo dice lo que
    significa.
  </p>
  <p>
    Que la agregación sea <code>foldBy</code> y no
    <code>groupBy</code> + <code>sumBy</code> es deliberado, y merece un
    momento. Aquí la respuesta es <em>un número por categoría</em>, así que
    agrupar primero construiría una <code>List</code> con todas las
    transacciones de cada categoría para luego plegarla y tirarla —asignación
    proporcional a la entrada, para una respuesta proporcional al número de
    categorías—. <code>foldBy</code> acumula directamente en el mapa de
    resultado, que es exactamente lo que hace el bucle nativo de al lado. Sobre
    un libro mayor de un millón de filas, esa única decisión vale unas 2,5× en
    <em>ambos</em> lados; mira
    <a href="../tutorials/performance.html">Escribir pipelines rápidos</a>.
    Recurre a <code>groupBy</code> cuando de verdad quieras los miembros.
  </p>
