---
slug: average
title: average — FxDart 101
description: Tutorial de average en FxDart: la media de todos los números de un pipeline, NaN cuando está vacío, con playground en vivo.
heading: <code>average</code>
section: 7
crumb: average
prev: sumBy.html
prevLabel: sumBy
next: averageBy.html
nextLabel: averageBy
---
  <p class="hero-sub">La media de todos los números que produce el pipeline — <code>NaN</code> cuando no hay ninguno.</p>

  {{signature}}

  <h2>Lección</h2>
  <p>
    <code>average</code> es un operador terminal que recorre el pipeline
    entero una sola vez, llevando a la vez un total y un contador
    acumulados, y luego divide. Siempre devuelve un <code>double</code>,
    incluso para una lista de <code>int</code> normales.
  </p>
  <p>
    El comportamiento que conviene interiorizar es este: el
    <code>average</code> de un iterable <strong>vacío</strong> es
    <code>double.nan</code>; está calculando <code>0 / 0</code>, no lanza una
    excepción ni recurre por defecto a <code>0</code>. Esto refleja exactamente lo
    que hace FxTS. Si tu pipeline puede quedar vacío, compruébalo de forma
    explícita (<code>result.isNaN</code>) en lugar de dar por hecho un valor
    numérico de reserva.
  </p>
  <p>
    Igual que <code><a href="sum.html">sum</a></code>, la forma encadenada se
    expone mediante una extensión sobre <code>Fx&lt;num&gt;</code> /
    <code>FxAsync&lt;num&gt;</code>, así que solo está disponible cuando el
    compilador puede ver que el tipo de elemento de tu cadena es numérico.
  </p>

  <h2>Demo 1 · Fundamentos &amp; el caso vacío</h2>
  {{playground:0}}

  <h2>Demo 2 · Asíncrono</h2>
  {{playground:1}}

  <h2>Pruébalo tú</h2>
  <p>Ejercicio: promedia solo las notas <strong>aprobadas</strong> (&gt;= 60).</p>
  {{playground:2}}

  <div class="callout">
    <strong>Relacionado:</strong>
    <a href="sum.html"><code>sum</code></a> — el numerador de esta división ·
    <a href="size.html"><code>size</code></a> — el denominador de esta división ·
    <a href="min.html"><code>min</code></a> · <a href="max.html"><code>max</code></a> — los otros terminales numéricos
  </div>
