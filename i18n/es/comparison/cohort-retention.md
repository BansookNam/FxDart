---
slug: cohort-retention
title: Tabla de retención por cohortes — Dart vs FxDart
description: Cohortes por mes de alta frente a la actividad posterior — pipelines anidados de groupBy/dropWhile/filter frente a bucles for anidados con listas acumuladoras.
heading: Tabla de retención por cohortes
order: 50
tier: 4
functions: groupBy, sortBy, map, dropWhile, filter, size, join
domain: users
verdict: fxdart
async: false
---
  <h2>Requisito</h2>
  <p>
    Cada usuario (los datos están en el código) tiene un mes de alta y la
    lista de meses en los que estuvo activo. Agrupa a los usuarios en
    <strong>cohortes por mes de alta</strong> y, para cada mes
    <em>posterior</em>, imprime qué porcentaje de la cohorte seguía activo
    —una fila por cohorte, de la más antigua a la más reciente. Ambas
    versiones deben imprimir la tabla que aparece bajo
    <em>Salida esperada</em>.
  </p>

  {{output}}

  <h2>Lado a lado</h2>
  {{comparison}}

  <h2>Por qué difieren</h2>
  <p>
    Una tabla de retención es un pipeline dentro de otro pipeline: las
    cohortes por fuera, los meses por dentro. En FxDart ambas capas son
    expresiones —<code>groupBy</code> → <code>sortBy</code> →
    <code>map</code> sobre las cohortes y, dentro de cada fila,
    <code>dropWhile</code> salta los meses hasta el mes de alta antes de que
    <code>filter</code> + <code>size</code> cuenten los usuarios que siguen
    activos. La versión nativa necesita una lista acumuladora mutable por
    capa (<code>rows</code>, <code>cells</code>) y dos bucles
    <code>for</code> anidados para coserlas; la lógica de retención en sí es
    la misma, pero está repartida por los cuerpos de los bucles en lugar de
    ser la columna vertebral visible del código.
  </p>
