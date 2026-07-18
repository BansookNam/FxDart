---
slug: differenceBy
title: differenceBy — FxDart 101
description: Tutorial de differenceBy en FxDart: excluye elementos por una clave calculada presente en otro iterable, con playground en vivo.
heading: <code>differenceBy</code>
section: 4
crumb: differenceBy
prev: difference.html
prevLabel: difference
next: intersection.html
nextLabel: intersection
---
  <p class="hero-sub"><code>difference</code>, comparando por una clave calculada en vez de por igualdad de valor.</p>

  {{signature}}

  <h2>Lección</h2>
  <p>
    <code>differenceBy(f, iterable1, iterable2)</code> sigue exactamente la
    misma regla de orden de argumentos que <a href="difference.html"><code>difference</code></a>:
    el resultado sale <strong>de <code>iterable2</code></strong>, y conserva
    solo los elementos cuya clave <code>f</code> <em>no</em> aparezca entre
    las claves <code>f</code> de <code>iterable1</code> (colapsando los
    duplicados del resultado). La función <code>f</code> se aplica a
    <em>ambos</em> iterables, así que — a diferencia de
    <code>differenceBy</code> en otros lenguajes — ambos argumentos deben
    compartir el mismo tipo de elemento <code>A</code>; lo único que se
    compara es el tipo de clave derivado <code>B</code>.
  </p>
  <p>
    Esta es la forma que buscas cuando la "lista de exclusión" y la "lista
    de origen" son registros completos y no valores sueltos: una lista de
    objetos de usuario bloqueados y una lista de objetos de usuario,
    emparejadas por <code>id</code>; o una lista de productos no disponibles
    y un catálogo de productos, emparejados por <code>sku</code>.
  </p>
  <p>
    <code>difference</code> no es más que
    <code>differenceBy((a) =&gt; a, iterable1, iterable2)</code>. No hay
    método de cadena para ninguna de las dos — llama directamente a la
    función data-first. En el lado asíncrono, el marcador de concurrencia se
    aplica a <code>iterable2</code>, igual que en
    <code>differenceAsync</code>.
  </p>

  <h2>Demo 1 · Fundamentos</h2>
  {{playground:0}}

  <h2>Demo 2 · Asíncrono, con concurrencia</h2>
  {{playground:1}}

  <h2>Pruébalo tú</h2>
  <p>Ejercicio: usa <code>differenceBy</code> (con clave <code>'sku'</code>)
    para encontrar los productos que siguen disponibles.</p>
  {{playground:2}}

  <div class="callout">
    <strong>Relacionado:</strong>
    <a href="difference.html"><code>difference</code></a> — la versión por igualdad de valor ·
    <a href="intersectionBy.html"><code>intersectionBy</code></a> — quedarse con los que comparten la clave calculada ·
    <a href="uniqBy.html"><code>uniqBy</code></a> — elimina duplicados de un solo iterable por clave ·
    <a href="compress.html"><code>compress</code></a> — filtra con una máscara booleana paralela
  </div>
