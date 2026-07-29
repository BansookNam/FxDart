---
slug: top-merchants
title: Los 5 comercios con más gasto total — Dart vs FxDart
description: Agrupar un libro de cuentas por comercio y ordenar los totales — groupListsBy + sortedBy en Dart nativo frente a una cadena groupBy → sortBy → take en FxDart.
heading: Los 5 comercios con más gasto total
order: 11
tier: 2
functions: groupBy, sortBy, take
domain: transactions
verdict: fxdart
async: false
---
  <h2>Requisito</h2>
  <p>
    Dado un mes de transacciones del libro de cuentas —cada una con fecha,
    comercio e importe—, encuentra los <strong>cinco comercios en los que
    más gastaste</strong>: agrupa por comercio, suma cada grupo, ordena los
    totales de mayor a menor e imprime los cinco primeros. Los datos están en
    el código de abajo; ambas versiones deben imprimir las líneas que
    aparecen bajo <em>Salida esperada</em>.
  </p>

  {{output}}

  <h2>Lado a lado</h2>
  {{comparison}}

  <h2>Por qué difieren</h2>
  <p>
    El núcleo de Dart no tiene <code>groupBy</code> en absoluto — la
    versión nativa tiene que recurrir a <code>package:collection</code>
    para <code>groupListsBy</code> y luego cambiar de modismo a mitad de
    tarea: un método de extensión para agrupar y otro
    (<code>sortedBy</code>, con un argumento de tipo
    <code>&lt;num&gt;</code> explícito y una clave negada para conseguir
    orden descendente) para ordenar. FxDart mantiene toda la tarea en un
    mismo vocabulario: <code>groupBy</code> produce el mapa y
    <code>fx(map.entries)</code> continúa la cadena con <code>sortBy</code>
    y <code>take</code>. La misma forma de solución — pero con una sola
    librería, un solo pipeline y sin ceremonia de argumentos de tipo.
  </p>
