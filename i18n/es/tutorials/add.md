---
slug: add
title: add — FxDart 101
description: Tutorial de add en FxDart: el + genérico como valor de función, utilizable como reductor, con un playground en vivo.
heading: <code>add</code>
section: 10
crumb: add
prev: cases.html
prevLabel: cases
next: comparisons.html
nextLabel: gt · gte · lt · lte
---
  <p class="hero-sub">Suma dos valores del mismo tipo, como una función que puedes pasar de un lado a otro.</p>

  {{signature}}

  <h2>Lección</h2>
  <p>
    <code>add(a, b)</code> es <code>+</code> empaquetado como valor de función.
    Como despacha a <code>+</code> de forma dinámica, funciona con cualquier cosa
    que soporte el operador — <code>num</code>, concatenación de
    <code>String</code>, incluso concatenación de <code>List</code> — igual que el
    <code>add</code> de FxTS, que acepta tanto números como cadenas.
  </p>
  <p>
    Su verdadero valor aparece allí donde una API espera una función binaria
    <code>(T, T) -&gt; T</code> en lugar de un
    <code>(a, b) =&gt; a + b</code> escrito en línea — de forma muy natural como la
    función combinadora de <code>reduce</code>/<code>fold</code>. Eso sí, es una
    función binaria, así que para usarla como retrollamada unaria de
    <code>map</code> (sumar una cantidad fija a cada elemento) tienes que fijar
    tú mismo uno de los lados: <code>(b) =&gt; add(n, b)</code>.
  </p>

  <h2>Demo 1 · Fundamentos</h2>
  {{playground:0}}

  <h2>Demo 2 · Como reductor, y con un lado fijado para map</h2>
  {{playground:1}}

  <h2>Pruébalo tú</h2>
  <p>Ejercicio: usa <code>fold</code> + <code>add</code> para concatenar todas
    las partes en una sola cadena.</p>
  {{playground:2}}

  <div class="callout">
    <strong>Relacionado:</strong>
    <a href="reduce.html"><code>reduce</code></a> / <a href="fold.html"><code>fold</code></a> — el sitio habitual de add como combinador ·
    <a href="sum.html"><code>sum</code></a> — una suma ya hecha para Iterable&lt;num&gt; ·
    <a href="comparisons.html"><code>gt · gte · lt · lte</code></a> — las contrapartes de comparación de add ·
    <a href="apply.html"><code>apply</code></a> — llama a cualquier función con una lista dinámica de argumentos
  </div>
