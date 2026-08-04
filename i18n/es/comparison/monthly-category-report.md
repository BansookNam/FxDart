---
slug: monthly-category-report
title: Informe mensual por categorías, ordenado por gasto — Dart vs FxDart
description: Filtra un libro de cuentas a un solo mes, suma cada categoría y ordénalas — bucle más mapa mutable en Dart nativo frente a filter + groupBy + sortBy en FxDart.
heading: Informe mensual por categorías, ordenado por gasto
order: 29
tier: 3
functions: filter, groupBy, map, sortBy, join
domain: transactions
verdict: fxdart
async: false
---
  <h2>Requisito</h2>
  <p>
    A partir de un libro de cuentas que se desborda de junio a julio de
    2026, construye el informe de gasto de julio: quédate solo con las
    transacciones de julio, suma cada categoría e imprime una línea por
    categoría —<strong>primero el mayor gasto</strong>. Los datos están
    en el código de abajo; ambas versiones deben imprimir las líneas que
    aparecen bajo <em>Salida esperada</em>.
  </p>

  {{output}}

  <h2>Lado a lado</h2>
  {{comparison}}

  <h2>Por qué difieren</h2>
  <p>
    Dart nativo no tiene <code>groupBy</code>, así que el bucle hace la
    agrupación y la suma a la vez dentro de un mapa mutable —compacto,
    pero los cuatro requisitos (solo julio, por categoría, sumado,
    ordenado) quedan enredados en un mismo cuerpo. La cadena de FxDart los
    mantiene como cuatro pasos visibles: <code>filter</code> por el mes,
    <code>groupBy</code> por categoría, <code>map</code> de cada grupo a
    su total, <code>sortBy</code> descendente —y <code>join</code> da
    formato al informe. Añadir un requisito (digamos, un total mínimo) es
    un paso más en la cadena; en el bucle es otra rama dentro de un cuerpo
    que ya estaba cargado.
  </p>
