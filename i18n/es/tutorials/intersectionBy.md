---
slug: intersectionBy
title: intersectionBy — FxDart 101
description: Tutorial de intersectionBy en FxDart: conserva los elementos por una clave calculada compartida con otro iterable, con un playground en vivo.
heading: <code>intersectionBy</code>
section: 4
crumb: intersectionBy
prev: intersection.html
prevLabel: intersection
next: compress.html
nextLabel: compress
---
  <p class="hero-sub"><code>intersection</code>, comparando por una clave calculada en vez de por igualdad de valor.</p>

  {{signature}}

  <h2>Lección</h2>
  <p>
    La misma forma que <a href="differenceBy.html"><code>differenceBy</code></a>,
    con la condición opuesta: <code>intersectionBy(f, iterable1, iterable2)</code>
    recorre <strong><code>iterable2</code></strong> y conserva cada elemento
    cuya clave <code>f</code> <em>sí</em> aparezca entre las claves
    <code>f</code> de <code>iterable1</code>, sin duplicados según esa clave.
    <code>f</code> se aplica a ambos iterables, así que los dos deben
    compartir el mismo tipo de elemento <code>A</code> — solo el tipo de la
    clave de comparación <code>B</code> puede diferir de <code>A</code>.
  </p>
  <p>
    Es la opción natural para dos listas de registros completos que comparten
    un campo identificador: una lista de SKUs "destacados" y un catálogo de
    productos, una lista de IDs de usuarios activos y una lista de objetos de
    usuario completos, y así sucesivamente. <code>intersection</code> no es
    más que <code>intersectionBy((a) =&gt; a, iterable1, iterable2)</code>.
  </p>
  <p>
    No existe método de cadena; llama a la función data-first o a su
    contraparte asíncrona. El marcador de concurrencia de
    <code>.concurrent(n)</code> se aplica a <code>iterable2</code>,
    exactamente igual que con <code>intersectionAsync</code>.
  </p>

  <h2>Demo 1 · Fundamentos</h2>
  {{playground:0}}

  <h2>Demo 2 · Asíncrono, con concurrencia</h2>
  {{playground:1}}

  <h2>Pruébalo tú</h2>
  <p>Ejercicio: usa <code>intersectionBy</code> (con la clave <code>'sku'</code>)
    para encontrar los productos que están en oferta.</p>
  {{playground:2}}

  <div class="callout">
    <strong>Relacionado:</strong>
    <a href="intersection.html"><code>intersection</code></a> — la versión por igualdad de valor ·
    <a href="differenceBy.html"><code>differenceBy</code></a> — excluye por una clave calculada compartida en su lugar ·
    <a href="uniqBy.html"><code>uniqBy</code></a> — elimina duplicados de un solo iterable por clave ·
    <a href="compress.html"><code>compress</code></a> — filtra con una máscara booleana paralela
  </div>
