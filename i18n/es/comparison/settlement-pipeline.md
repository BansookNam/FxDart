---
slug: settlement-pipeline
title: Pipeline de liquidación de cierre de día — Dart vs FxDart
description: Validar, agrupar por comercio, publicar de dos en dos y luego informar — una sola cadena que cruza de síncrono a asíncrono, frente a groupListsBy más un pool de workers.
heading: Pipeline de liquidación de cierre de día
order: 52
tier: 4
functions: reject, groupBy, map, sumBy, sortBy, toAsync, concurrent, partition
domain: transactions
verdict: fxdart
async: true
---
  <h2>Requisito</h2>
  <p>
    Cierra el día. A partir de diez transacciones con tarjeta (en el código
    de abajo): descarta las <code>failed</code>, agrupa el resto por
    comercio y calcula el neto de cada comercio (los reembolsos van en
    negativo). Publica la liquidación de cada comercio en la pasarela
    bancaria — como mucho <strong>dos publicaciones en vuelo</strong>, con
    los resultados en orden de comercio — y luego imprime el informe: una
    línea por comercio, un desglose entre pagos y cobros (los reembolsos de
    un comercio superan sus cargos), el total general y la prueba del máximo
    en vuelo.
  </p>
  <p>
    Esta es la librería entera en un solo pipeline. Preparación síncrona:
    <code>reject</code> → <code>groupBy</code> → <code>sumBy</code> por
    grupo → <code>sortBy</code>. Cruza a asíncrono con <code>toAsync</code>
    y publica bajo <code>concurrent(2)</code>. El informe usa de nuevo
    <code>partition</code> y <code>sumBy</code>.
  </p>

  {{output}}

  <h2>Lado a lado</h2>
  {{comparison}}

  <h2>Por qué difieren</h2>
  <p>
    Cada mitad de esta tarea ya ha aparecido en un ejemplo más pequeño; lo
    interesante aquí es qué ocurre cuando se juntan. Dart nativo resuelve la
    preparación bastante bien con <code>package:collection</code>
    (<code>groupListsBy</code>, <code>sortedBy</code>) — aunque sacar el neto
    de cada grupo es un <code>fold</code> con un valor inicial explícito, y
    el desglose de pagos son dos pasadas de <code>where</code>. Después llega
    la frontera asíncrona y la forma se rompe: la publicación acotada
    necesita el pool de workers, una función aparte con nombre, con slots y
    un cursor, y el pipeline que venías leyendo se convierte en fontanería
    que tienes que seguir a mano. La versión con FxDart es una única cadena
    ininterrumpida desde las transacciones en bruto hasta las liquidaciones
    publicadas — catorce líneas en las que la política (qué es válido, cómo
    agrupar, con cuánta fuerza golpear la pasarela) es el texto visible, y la
    mecánica es problema de la librería.
  </p>
