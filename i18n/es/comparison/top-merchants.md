---
slug: top-merchants
title: Los 5 comercios con más gasto total — Dart vs FxDart
description: Agrupar un libro de cuentas por comercio y ordenar los totales — groupListsBy + sortedBy en Dart nativo frente a una sola cadena groupedBy → sortByDesc → take en FxDart.
heading: Los 5 comercios con más gasto total
order: 11
tier: 2
functions: groupedBy, sortByDesc, take
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
    El núcleo de Dart no sabe agrupar en absoluto, así que la versión nativa
    tiene que recurrir a <code>package:collection</code> — y ahí agrupar
    <em>corta</em> la cadena: <code>groupListsBy</code> devuelve un
    <code>Map</code>, de modo que ordenarlo exige nombrar una variable
    intermedia, volver a entrar por <code>.entries</code> y leer cada grupo
    como un par sin tipo <code>kv.key</code> / <code>kv.value</code>. Ordenar
    añade dos rodeos más: un argumento de tipo <code>&lt;num&gt;</code>
    explícito (la inferencia falla porque <code>double</code> es
    <code>Comparable&lt;num&gt;</code>, no
    <code>Comparable&lt;double&gt;</code>) y una clave <em>negada</em>, ya que
    <code>sortedBy</code> solo ordena de menor a mayor.
  </p>
  <p>
    En FxDart los cuatro pasos son cuatro eslabones de una sola cadena, de
    arriba abajo en el mismo orden en que el requisito los enuncia.
    <code>groupedBy</code> se queda dentro del pipeline — produce grupos
    <code>(key:, items:)</code> en lugar de un mapa, así que no hay nada que
    desempaquetar y volver a envolver — y <code>sortByDesc</code> dice
    &laquo;descendente&raquo; en su nombre en vez de codificarlo como un signo
    menos. Sin variable intermedia, sin ceremonia de argumentos de tipo y sin
    truco del signo: el código dice agrupa, ordena, toma cinco.
  </p>
