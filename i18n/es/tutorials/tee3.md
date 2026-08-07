---
slug: tee3
title: tee3 — FxDart 101
description: Tutorial de tee3 en FxDart: la forma de tres reducciones de tee, sobre una sola pasada de la fuente, con playground en vivo.
heading: <code>tee3</code>
section: 6
crumb: tee3
prev: tee.html
prevLabel: tee
next: ifEmpty.html
nextLabel: ifEmpty
---
  <p class="hero-sub">Tres folds sobre una pasada de la fuente: <a href="tee.html"><code>tee</code></a> con una reducción más.</p>

  {{signature}}

  <h2>Lección</h2>
  <p>
    <code>tee3</code> es <a href="tee.html"><code>tee</code></a> con un tercer
    fold. Todo lo que explica la página de
    <a href="tee.html"><code>tee</code></a> sigue valiendo igual: cada
    elemento hace avanzar todos los acumuladores antes de tirar del
    siguiente, así que la fuente se recorre exactamente una vez y no se
    almacena nada; los acumuladores son independientes y no tienen por qué
    compartir tipo; y los lectores han de ser folds, no pipelines. Lee esa
    página primero para el razonamiento y para saber cuándo
    <a href="fork.html"><code>fork</code></a> es la mejor herramienta.
  </p>
  <p>
    Dart no tiene genéricos variádicos, así que cada aridad es su propia
    función — la misma razón por la que a
    <a href="zip.html"><code>zip</code></a> le acompaña <code>zip3</code>. Dos
    y tres cubren los casos que merecen nombre; más allá, reduce a un pequeño
    record o clase tuya y usa <a href="fold.html"><code>fold</code></a> a
    secas.
  </p>

  <h2>Demo · Total, pico y cuenta con una sola lectura</h2>
  <p>
    <code>sensor()</code> cuenta sus propios valores. Tres pasadas separadas
    dejarían <code>reads</code> en 18; <code>tee3</code> lo deja en 6:
  </p>
  {{playground:0}}

  <div class="callout">
    <strong>Relacionado:</strong>
    <a href="tee.html"><code>tee</code></a> — la forma de dos folds, y la explicación completa ·
    <a href="fork.html"><code>fork</code></a> — lectores independientes, a costa de un búfer ·
    <a href="fold.html"><code>fold</code></a> — un solo fold
  </div>
