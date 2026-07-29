---
slug: minBy
title: minBy — FxDart 101
description: Tutorial de minBy en FxDart: el elemento con la clave más pequeña en una sola pasada — sin ordenar, null cuando está vacío — con un playground en vivo.
heading: <code>minBy</code>
section: 7
crumb: minBy
prev: maxBy.html
prevLabel: maxBy
next: size.html
nextLabel: count
---
  <p class="hero-sub">El elemento cuya clave es la más pequeña — una sola pasada, sin ordenar, <code>null</code> cuando está vacío.</p>

  {{signature}}

  <h2>Lección</h2>
  <p>
    <code>minBy</code> es la imagen especular de
    <code><a href="maxBy.html">maxBy</a></code>: devuelve el
    <em>elemento</em> con la clave más pequeña tras una única pasada O(n),
    mientras que <code>sortBy(key).head()</code> ordenaría el pipeline entero
    solo para leer un valor.
  </p>
  <p>
    El contrato coincide exactamente con el de <code>maxBy</code>: las claves
    se comparan como en <code><a href="sortBy.html">sortBy</a></code>
    (<code>Comparable.compare</code>), los empates los gana el
    <strong>primer</strong> elemento encontrado, y un pipeline vacío devuelve
    <code>null</code> — no <code>infinity</code>, que es lo que hace el
    <code><a href="min.html">min</a></code> numérico, porque aquí no hay
    ningún «elemento cero» al que recurrir.
  </p>

  <h2>Demo 1 · Fundamentos, caso vacío &amp; empates</h2>
  {{playground:0}}

  <h2>Demo 2 · Asíncrono</h2>
  {{playground:1}}

  <h2>Pruébalo tú</h2>
  <p>Ejercicio: encuentra al corredor más rápido con una sola llamada.</p>
  {{playground:2}}

  <div class="callout">
    <strong>Relacionado:</strong>
    <a href="maxBy.html"><code>maxBy</code></a> — la imagen especular ·
    <a href="min.html"><code>min</code></a> — cuando quieres la clave en sí, no el elemento ·
    <a href="head.html"><code>head</code></a> — el mismo contrato con nulls
  </div>
