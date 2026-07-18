---
slug: compress
title: compress — FxDart 101
description: Tutorial de compress en FxDart: filtra un iterable con una lista paralela de booleanos, con un playground en vivo.
heading: <code>compress</code>
section: 4
crumb: compress
prev: intersectionBy.html
prevLabel: intersectionBy
next: ../tutorials/take.html
nextLabel: take
---
  <p class="hero-sub">Conserva los elementos de un iterable allí donde una lista paralela de booleanos vale true.</p>

  {{signature}}

  <h2>Lección</h2>
  <p>
    <code>compress</code> es una máscara posicional: el elemento <code>i</code> de
    <code>iterable</code> sobrevive solo si <code>selectors[i]</code> es
    <code>true</code>. Está construido directamente a partir de dos funciones que ya
    conoces — <code>map((r) =&gt; r.$2, filter((r) =&gt; r.$1, zip(selectors, iterable)))</code> —
    combina la máscara con los datos, filtra los pares que dan true y desempaqueta. Eso
    también significa que hereda el comportamiento de <code>zip</code> ante longitudes
    distintas: la iteración se detiene en cuanto se agota el <em>más corto</em> de
    <code>selectors</code> o <code>iterable</code>, así que una lista de selectores
    corta trunca el resultado en silencio. Úsalo cuando ya tengas de antemano (o puedas
    calcular a bajo coste) una máscara booleana — por ejemplo, "qué respuestas
    del test fueron correctas" — en vez de recalcular un predicado por elemento como
    haría <code>filter</code>.
  </p>
  <p>
    No hay método de cadena; llama directamente a la función data-first o a su
    contraparte asíncrona, o envuelve el resultado con <code>fx(...)</code> /
    <code>fxAsync(...)</code> para seguir encadenando.
  </p>

  <h2>Demo 1 · Fundamentos &amp; longitudes distintas</h2>
  {{playground:0}}

  <h2>Demo 2 · Asíncrono, con concurrencia</h2>
  {{playground:1}}

  <h2>Pruébalo tú</h2>
  <p>Ejercicio: usa <code>compress</code> para quedarte solo con las respuestas
    correctas.</p>
  {{playground:2}}

  <div class="callout">
    <strong>Relacionado:</strong>
    <a href="filter.html"><code>filter</code></a> — filtra por predicado en lugar de por una máscara precalculada ·
    <a href="../tutorials/zip.html"><code>zip</code></a> — la función sobre la que se construye compress ·
    <a href="differenceBy.html"><code>differenceBy</code></a> — filtra por pertenencia a otro iterable ·
    <a href="../tutorials/partition.html"><code>partition</code></a> — divide en conservados/descartados en una sola pasada
  </div>
