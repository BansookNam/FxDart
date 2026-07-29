---
slug: refunds-vs-charges
title: Reembolsos frente a cargos, ambos formateados — Dart vs FxDart
description: Divide un libro de cuentas en reembolsos y cargos e imprime ambos lados — dos pasadas de where en Dart nativo frente a un solo partition en FxDart.
heading: Reembolsos frente a cargos, ambos formateados
order: 15
tier: 2
functions: partition, map, join
domain: transactions
verdict: fxdart
async: false
---
  <h2>Requisito</h2>
  <p>
    Un libro de cuentas mezcla cargos y reembolsos (importes negativos).
    Divídelo en los dos grupos, formatea cada transacción como
    <code>merchant $amount</code> e imprime una línea por grupo, primero
    los reembolsos. Los datos están en el código de abajo; ambas versiones
    deben imprimir las líneas que aparecen bajo <em>Salida esperada</em>.
  </p>

  {{output}}

  <h2>Lado a lado</h2>
  {{comparison}}

  <h2>Por qué difieren</h2>
  <p>
    Dart no tiene <code>partition</code>: cuando necesitas <em>ambas</em>
    mitades, <code>where</code> solo te da una, así que la versión nativa
    filtra dos veces —una con el predicado y otra con su negación, escrita
    a mano (<code>&lt; 0</code> y <code>&gt;= 0</code>)—. Eso son dos
    pasadas sobre los datos y dos predicados que mantener sincronizados: si
    algún día cambia la regla de los reembolsos, nada obliga a la segunda
    línea a seguirla. El <code>partition</code> de FxDart convierte la
    división en una sola declaración: un único predicado, una única pasada
    y una desestructuración de record que pone nombre a ambas mitades. El
    formateo posterior con <code>map</code> + <code>join</code> es igual en
    ambas.
  </p>
