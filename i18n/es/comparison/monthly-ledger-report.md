---
slug: monthly-ledger-report
title: Informe mensual completo del libro de cuentas — Dart vs FxDart
description: Un único informe a partir de un libro de cuentas — total, desglose por categorías, comercios principales — como tres pipelines de fxdart frente a bucles y mapas intermedios.
heading: Informe mensual completo del libro de cuentas
order: 31
tier: 4
functions: filter, sumBy, groupBy, map, sortBy, take, zipWithIndex, join
domain: transactions
verdict: fxdart
async: false
---
  <h2>Requisito</h2>
  <p>
    A partir de un mes de transacciones del libro de cuentas (los datos
    están en el código), construye una única cadena de informe con tres
    secciones: el <strong>total gastado</strong> (sin contar los
    ingresos), un <strong>desglose por categoría</strong> ordenado por
    gasto y los <strong>3 comercios principales</strong> como lista
    numerada. Ambas versiones deben imprimir exactamente el informe que
    aparece bajo <em>Salida esperada</em>.
  </p>

  {{output}}

  <h2>Lado a lado</h2>
  {{comparison}}

  <h2>Por qué difieren</h2>
  <p>
    En FxDart cada sección del informe tiene la misma forma:
    <code>groupBy</code> → <code>sumBy</code> por grupo →
    <code>sortBy</code> descendente —y después <code>take</code> y
    <code>zipWithIndex</code> convierten la sección de comercios en un top
    3 numerado sin ninguna variable de índice. La versión nativa tiene que
    expresar cada uno de esos pasos en un dialecto distinto:
    <code>fold</code> con un valor inicial para cada suma,
    <code>sortedBy&lt;num&gt;</code> con una clave negada, un
    collection-for para una sección y un bucle <code>for</code> indexado
    para la otra. El informe crece sección a sección en ambos lados —pero
    solo uno de los dos crece añadiendo pasos al pipeline en vez de
    acumulando variables intermedias con formas distintas.
  </p>
