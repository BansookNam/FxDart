---
slug: paginate-users
title: Agrupar usuarios en páginas de 10 — Dart vs FxDart
description: Divide una lista de usuarios en páginas de tamaño fijo — slices de package:collection frente a chunk + map en FxDart.
heading: Agrupar usuarios en páginas de 10
order: 5
tier: 1
functions: chunk, map
alsoLink: concurrent
domain: users
verdict: fxdart
async: false
---
  <h2>Requisito</h2>
  <p>
    Divide doce usuarios en <strong>páginas de 10</strong> (la última
    puede quedarse corta) e imprime cada página en una línea con su
    número, su tamaño y sus nombres. Los datos están en el código de
    abajo; ambas versiones deben imprimir las líneas que aparecen bajo
    <em>Salida esperada</em>.
  </p>

  {{output}}

  <h2>Lado a lado</h2>
  {{comparison}}

  <h2>Por qué difieren</h2>
  <p>
    El núcleo de Dart no ofrece nada para trocear — sin ayuda esto es un
    bucle por índices sobre <code>sublist</code> con una guarda
    <code>min</code> para la última página, más corta. El
    <code>slices</code> de <code>package:collection</code> lo resuelve, y
    si ya dependes de él los dos paneles son casi gemelos. La ventaja de
    FxDart es que <code>chunk</code> no necesita ninguna dependencia
    extra, es perezoso (las páginas se materializan a medida que las
    consumes) y ese mismo paso funciona en cadenas asíncronas — agrupar
    peticiones antes de una etapa <code>concurrent</code> es el uso
    clásico. Una victoria modesta, pero real.
  </p>
