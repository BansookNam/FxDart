---
slug: combine
title: combine — FxDart 101
description: Tutorial de combine en FxDart: un solo combinador para el estilo combineLatest, el estilo withLatestFrom, zipAll y withLatestFromAll — impulsado por CombineSpec — con playground en vivo.
heading: <code>combine</code> &amp; <code>CombineSpec</code>
section: 14
crumb: combine
prev: waitAll.html
prevLabel: waitAll
next: stopOn.html
nextLabel: stopOn
---
  <p class="hero-sub">Un solo combinador para «quién dispara» y «quién debe haber hablado» — más <code>zipAll</code> y <code>withLatestFromAll</code>.</p>

  {{signature}}

  <h2>Lección</h2>
  <p>
    <code><a href="combineLatest.html">combineLatest</a></code>,
    <code><a href="withLatestFrom.html">withLatestFrom</a></code> y
    <code><a href="waitAll.html">zip</a></code> difieren en quién puede
    disparar una emisión y en si todo lado debe haber hablado.
    <code>combine</code> es la forma unificada: una lista de
    <code>CombineSpec</code>, cada uno un <code>source</code> más dos
    flags. Es una función de nivel superior, no
    <code>FxEvents.combine</code> — Dart no puede añadir estáticos a
    <code>FxEvents</code> desde otro archivo.
  </p>
  <p>
    <code>causesEmit: true</code> (el valor por defecto) significa que un
    evento de esta fuente puede producir una salida, una vez que todo
    spec <code>requireFirst</code> tiene un valor. Specs todos-true son
    <code>FxEvents.combineLatestAll</code>.
    <code>causesEmit: false</code> significa que esta fuente es solo
    contexto: actualiza el slot pero nunca dispara una emisión por sí
    sola — eso es <code>withLatestFrom</code>.
    <code>requireFirst: true</code> (el valor por defecto) retiene toda
    emisión hasta que esta fuente ha producido al menos un valor;
    <code>false</code> deja que el slot sea <code>null</code> hasta que
    hable. El resultado se cierra cuando todas las fuentes se han
    cerrado.
  </p>
  <p>
    Junto a él viven dos combinadores más.
    <code>zipAll</code> sobre
    <code>FxEvents&lt;Stream&lt;T&gt;&gt;</code> recoge cada stream
    interior hasta que el exterior completa, y luego los empareja por
    índice — los interiores ni siquiera se suscriben hasta entonces.
    <code>withLatestFromAll</code> es el <code>withLatestFrom</code>
    N-ario: en cada evento de la fuente, lo combina con el más reciente
    de todos los demás, descartando los eventos de la fuente que llegan
    antes de que todos los demás hayan hablado. Capa de eventos de
    fxdart, según el <code>combineLatest</code> /
    <code>withLatestFrom</code> / <code>zipAll</code> de Rx.
  </p>

  <h2>Demo 1 · Ambos lados disparan</h2>
  {{playground:0}}

  <h2>Demo 2 · Solo contexto — causesEmit: false</h2>
  {{playground:1}}

  <h2>Pruébalo tú</h2>
  <p>Ejercicio: <code>zipAll</code> sobre un stream de streams, y <code>withLatestFromAll</code> sobre una fuente.</p>
  {{playground:2}}

  <div class="callout">
    <strong>Relacionado:</strong>
    <a href="combineLatest.html"><code>combineLatest</code></a> — ambos lados disparan, el CombineSpec todos-true ·
    <a href="withLatestFrom.html"><code>withLatestFrom</code></a> — unilateral, el spec causesEmit: false ·
    <a href="waitAll.html"><code>waitAll</code></a> — zip, combineLatestAll, concat
  </div>
