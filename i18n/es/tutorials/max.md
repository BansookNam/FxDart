---
slug: max
title: max — FxDart 101
description: Tutorial de max en FxDart: el número más grande de un pipeline, -infinito cuando está vacío, envenenado por NaN, con playground en vivo.
heading: <code>max</code>
section: 7
crumb: max
prev: min.html
prevLabel: min
next: maxBy.html
nextLabel: maxBy
---
  <p class="hero-sub">El número más grande del pipeline: la imagen especular de <code>min</code>.</p>

  {{signature}}

  <h2>Lección</h2>
  <p>
    <code>max</code> funciona exactamente igual que <code><a href="min.html">min</a></code>,
    pero al revés: es <code>fold(-double.infinity, ..., iterable)</code>, y conserva
    el mayor valor visto hasta el momento.
  </p>
  <p>
    Se aplican las mismas dos rarezas fieles a FxTS, solo que en espejo:
  </p>
  <ul>
    <li>Un iterable <strong>vacío</strong> devuelve <code>-double.infinity</code>, no <code>null</code>.</li>
    <li>Un solo <code>NaN</code> en cualquier posición <strong>envenena</strong> el resultado y lo convierte en <code>NaN</code>: el mismo razonamiento que en <code>min</code>, ya que toda comparación contra <code>NaN</code> es falsa.</li>
  </ul>
  <p>
    Como en los demás terminales numéricos, la forma encadenada
    (<code>Fx&lt;num&gt;.max()</code> / <code>FxAsync&lt;num&gt;.max()</code>)
    solo está disponible cuando el compilador sabe que tu cadena contiene números.
  </p>

  <h2>Demo 1 · Fundamentos, vacío y NaN</h2>
  {{playground:0}}

  <h2>Demo 2 · Asíncrono</h2>
  {{playground:1}}

  <h2>Pruébalo tú</h2>
  <p>Ejercicio: encuentra la temperatura <strong>más alta</strong> de la lista.</p>
  {{playground:2}}

  <div class="callout">
    <strong>Relacionado:</strong>
    <a href="min.html"><code>min</code></a> — la imagen especular ·
    <a href="sum.html"><code>sum</code></a> · <a href="average.html"><code>average</code></a> — los otros terminales numéricos ·
    <a href="sortBy.html"><code>sortBy</code></a> — para ordenar en lugar de solo encontrar el extremo
  </div>
