---
slug: category-rank
title: Ranking del mes por categoría — Dart vs FxDart
description: Agrupar, totalizar y rankear el gasto — groupListsBy más el volteo del comparador en Dart nativo frente a una sola cadena groupedBy → sortByDesc en FxDart.
heading: Ranking del mes por categoría
order: 51
tier: 4
functions: filter, groupedBy, map, sumBy, sortByDesc, take
domain: transactions
verdict: fxdart
async: false
---
  <h2>Requisito</h2>
  <p>
    Dadas transacciones del libro de cuentas con algunos rezagados de
    junio mezclados, quédate solo con <strong>julio de 2026</strong> y
    calcula las <strong>tres categorías con más gasto total</strong> — la
    más grande primero —, imprimiendo cada categoría con su total y
    cuántas compras abarca. Los datos están en el código de abajo; las dos
    versiones deben imprimir las líneas que aparecen bajo
    <em>Salida esperada</em>.
  </p>

  {{output}}

  <h2>Lado a lado</h2>
  {{comparison}}

  <h2>Por qué difieren</h2>
  <p>
    La tarea es un solo pensamiento — quedarse con el mes, agrupar,
    totalizar, rankear, top tres — y la versión FxDart es una sola cadena:
    <code>filter</code> conserva julio, <code>groupedBy</code>
    produce registros <code>(key:, items:)</code>, así que el total por
    categoría está a un paso de <code>map</code>, y
    <code>sortByDesc</code> dice «el más grande primero» por clave. Dart
    nativo reparte el mismo pensamiento a través de un <code>Map</code>:
    <code>groupListsBy</code> (de <code>package:collection</code>) termina
    la cadena fluida, y el orden descendente se convierte en el volteo de
    operandos del comparador
    <code>(a,&nbsp;b)&nbsp;=&gt;&nbsp;b…compareTo(a…)</code> — un
    criadero clásico de bugs silenciosos, y la razón por la que el lado
    FxDart nunca niega una clave.
  </p>
  <p>
    Honestamente: <code>package:collection</code> cubre bien el
    agrupamiento, y para un informe puntual la versión nativa está bien.
    La cadena se gana el sueldo conforme el informe crece — cada paso
    añadido (un filtro, un segundo criterio de ranking) extiende el
    pipeline en vez de otro viaje de ida y vuelta por
    <code>entries</code>.
  </p>
