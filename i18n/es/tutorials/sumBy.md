---
slug: sumBy
title: sumBy — FxDart 101
description: Tutorial de sumBy en FxDart: suma una clave de todos los elementos — map + sum en un solo paso — con un playground en vivo.
heading: <code>sumBy</code>
section: 7
crumb: sumBy
prev: sum.html
prevLabel: sum
next: average.html
nextLabel: average
---
  <p class="hero-sub">Suma una clave de todos los elementos — <code>map</code> + <code>sum</code> en un solo paso, <code>0</code> cuando está vacío.</p>

  {{signature}}

  <h2>Lección</h2>
  <p>
    <code>sumBy</code> condensa la cola de dos etapas más habitual de los
    pipelines de datos — <code>.map((x) =&gt; x.field).sum()</code> — en un
    único terminal. Va plegando un total acumulado mientras extrae la clave,
    así que no se materializa nada intermedio y la intención («totaliza este
    campo») es una sola llamada en lugar de una proyección más una agregación.
  </p>
  <p>
    El contrato es el de <code><a href="sum.html">sum</a></code>: un pipeline
    vacío suma <code>0</code>, y las claves int mantienen la aritmética entera
    mientras que cualquier clave double promociona el total a
    <code>double</code>.
  </p>
  <p>
    Es un añadido nativo de Dart (FxTS solo trae el <code>sum</code>
    numérico), de la misma familia que
    <code><a href="maxBy.html">maxBy</a></code> /
    <code><a href="minBy.html">minBy</a></code> — Kotlin lo llama
    <code>sumOf</code>.
  </p>

  <h2>Demo 1 · Fundamentos &amp; el caso vacío</h2>
  {{playground:0}}

  <h2>Demo 2 · Claves asíncronas</h2>
  {{playground:1}}

  <h2>Pruébalo tú</h2>
  <p>Ejercicio: totaliza con una sola llamada las longitudes de las palabras largas.</p>
  {{playground:2}}

  <div class="callout">
    <strong>Relacionado:</strong>
    <a href="sum.html"><code>sum</code></a> — cuando el pipeline ya contiene números ·
    <a href="maxBy.html"><code>maxBy</code></a> · <a href="minBy.html"><code>minBy</code></a> — la misma familia por clave ·
    <a href="fold.html"><code>fold</code></a> — la forma general que esto especializa
  </div>
