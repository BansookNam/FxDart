---
slug: intersection
title: intersection — FxDart 101
description: Tutorial de intersection en FxDart: los elementos de un iterable que también aparecen en otro, con un playground en vivo.
heading: <code>intersection</code>
section: 4
crumb: intersection
prev: differenceBy.html
prevLabel: differenceBy
next: intersectionBy.html
nextLabel: intersectionBy
---
  <p class="hero-sub">Lo contrario de <code>difference</code>: los elementos del segundo iterable que SÍ aparecen en el primero.</p>

  {{signature}}

  <h2>Lección</h2>
  <p>
    <code>intersection(iterable1, iterable2)</code> comparte la convención de
    orden de argumentos de <code>difference</code>: el resultado recorre
    <strong><code>iterable2</code></strong> y conserva cada elemento (en el
    orden de <code>iterable2</code>, sin duplicados) que <em>sí</em> se
    encuentre en <code>iterable1</code>. <code>iterable1</code> se usa
    únicamente como conjunto de pertenencia — si intercambias los dos
    argumentos obtienes los mismos <em>valores</em> en el sentido de la teoría
    de conjuntos, pero el orden real (y de qué colección se colapsan los
    duplicados) es distinto, porque cambia la fuente de los elementos
    emitidos. Mira la Demo 1.
  </p>
  <p>
    Por dentro es
    <code>intersectionBy((a) =&gt; a, iterable1, iterable2)</code> — recurre
    directamente a <a href="intersectionBy.html"><code>intersectionBy</code></a>
    cuando necesites emparejar por una clave calculada entre dos listas de
    registros completos en vez de por igualdad de valor.
  </p>
  <p>
    No hay método de cadena; llama a la función data-first. En el lado
    asíncrono, el marcador de concurrencia de <code>.concurrent(n)</code> se
    aplica a <code>iterable2</code> — <code>iterable1</code> se consume por
    completo de antemano para construir el conjunto de pertenencia.
  </p>

  <h2>Demo 1 · Fundamentos &amp; orden de los argumentos</h2>
  {{playground:0}}

  <h2>Demo 2 · Asíncrono, con concurrencia</h2>
  {{playground:1}}

  <h2>Pruébalo tú</h2>
  <p>Ejercicio: usa <code>intersection</code> para averiguar cuáles de las
    habilidades del candidato son realmente necesarias.</p>
  {{playground:2}}

  <div class="callout">
    <strong>Relacionado:</strong>
    <a href="difference.html"><code>difference</code></a> — la contraparte de exclusión ·
    <a href="intersectionBy.html"><code>intersectionBy</code></a> — empareja por una clave calculada en su lugar ·
    <a href="uniq.html"><code>uniq</code></a> — elimina duplicados de un solo iterable ·
    <a href="../tutorials/includes.html"><code>includes</code></a> — comprueba la pertenencia de un único valor
  </div>
