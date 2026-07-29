---
slug: paginated-products
title: Listado de productos paginado — Dart vs FxDart
description: Filtra, ordena por precio y extrae la página 2 — Dart ya tiene skip/take, así que este caso es un empate de verdad.
heading: Listado de productos paginado
order: 22
tier: 3
functions: filter, sortBy, drop, take, map
domain: orders
verdict: tie
async: false
---
  <h2>Requisito</h2>
  <p>
    El catálogo de una tienda pequeña: nombre, precio y bandera de
    disponibilidad. Muestra la <strong>página 2</strong> de los productos
    en stock, ordenados por precio ascendente, tres por página — una línea
    por producto. Los datos están en el código de abajo; ambas versiones
    deben imprimir las líneas que aparecen bajo <em>Salida esperada</em>.
  </p>

  {{output}}

  <h2>Lado a lado</h2>
  {{comparison}}

  <h2>Por qué difieren</h2>
  <p>
    Apenas difieren — esto es un empate, y conviene decirlo con claridad.
    La paginación es exactamente la forma que el <code>Iterable</code> de
    Dart ya cubre: <code>skip</code> y <code>take</code> se leen igual de
    bien que el <code>drop</code> y el <code>take</code> de FxDart, y los
    dos siguen siendo perezosos. La única arruga nativa es ordenar por una
    clave — el núcleo de Dart necesita un comparador (el
    <code>sortedBy</code> de <code>package:collection</code> cierra
    incluso esa brecha). Elige FxDart aquí solo si el resto del código ya
    habla su vocabulario; Dart nativo no pierde nada en esta tarea.
  </p>
