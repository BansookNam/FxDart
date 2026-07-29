---
slug: daily-ledger-close
title: Gran final — cierre mensual de DailyLedger — Dart vs FxDart
description: El gran final: carga las entradas del libro de 3 en 3 y luego calcula el resumen de julio y el desglose por categoría — las formas reales de la app DailyLedger, de las dos maneras.
heading: Gran final — cierre mensual de DailyLedger
order: 50
tier: 4
functions: toAsync, map, concurrent, filter, partition, sumBy, groupBy, sortBy, take
domain: transactions
verdict: fxdart
async: true
---
  <h2>Requisito</h2>
  <p>
    Cierra el mes de un libro de cuentas personal. Diez entradas viven en
    un almacén (datos fijos en el código de abajo); carga cada una por id
    —como máximo <strong>tres cargas en curso</strong>, tal como demuestra
    el contador de máximo en curso— y luego calcula el cierre de julio
    de&nbsp;2026: quédate solo con las entradas de julio (una rezagada es
    de junio), separa los ingresos de los gastos, suma cada lado e imprime
    el neto junto con las tres categorías de gasto principales y su número
    de entradas.
  </p>
  <p>
    Las formas que ves aquí están sacadas de una app real: el modelo
    <code>Entry</code>, la separación ingresos/gastos (<code>filter</code> →
    <code>partition</code> → <code>sumBy</code> en cada mitad) y el desglose
    por categoría (<code>groupBy</code> → <code>sumBy</code> por grupo →
    <code>sortBy</code> descendente → <code>take(3)</code>) son un calco de
    los pipelines <code>monthSummary</code> y
    <code>categoryBreakdown</code> de DailyLedger, con la fase de carga
    asíncrona (<code>toAsync</code> → <code>map</code> →
    <code>concurrent(3)</code>) por delante.
  </p>

  {{output}}

  <h2>Lado a lado</h2>
  {{comparison}}

  <h2>Por qué difieren</h2>
  <p>
    Cincuenta ejemplos después, este es el patrón al que todos apuntaban:
    Dart nativo necesita tres dialectos para una sola funcionalidad —los
    helpers de <code>package:collection</code> para agrupar,
    <code>fold</code> con valores iniciales explícitos para los totales, y
    un pool de workers escrito a mano en cuanto la fase de carga necesita un
    límite de concurrencia—. Cada pieza está bien por separado; juntas
    convierten la lógica de negocio en lo más difícil de encontrar en la
    pantalla. La versión con FxDart usa el mismo vocabulario desde la fase
    de carga hasta el informe, y como cada etapa es un pipeline puro, se
    puede extraer cualquiera de ellas y probarla de forma unitaria como
    <em>entran entradas, salen datos de vista</em>.
  </p>
  <p>
    Estos pipelines no son un adorno de demostración: son exactamente cómo
    <a href="{{root}}DailyLedger/">la app de demostración DailyLedger</a>
    calcula su panel —mismo modelo, mismos operadores, funcionando en vivo
    en tu navegador. Si las cincuenta comparaciones te enseñaron las
    palabras, DailyLedger es la frase que iban construyendo.
  </p>
