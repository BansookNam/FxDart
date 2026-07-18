---
slug: repeat
title: repeat — FxDart 101
description: Tutorial de repeat en FxDart: emite el mismo valor n veces, de forma perezosa.
heading: <code>repeat</code>
section: 2
crumb: repeat
prev: range.html
prevLabel: range
next: cycle.html
nextLabel: cycle
---
  <p class="hero-sub">Emite el mismo valor n veces — una fuente perezosa y finita para rellenar y emparejar.</p>

  {{signature}}

  <h2>Lección</h2>
  <p>
    <code>repeat(n, value)</code> emite <code>value</code> exactamente
    <code>n</code> veces y se detiene: es finito y perezoso, como el resto de
    generadores de esta sección. Ten en cuenta que repite el <em>mismo</em>
    valor (o la misma referencia de objeto, si no es un primitivo) cada vez; si
    necesitas un valor nuevo en cada iteración, genéralo aparte (por ejemplo,
    con un <code>map</code> sobre el resultado) en lugar de esperar que
    <code>repeat</code> llame a una función de fábrica.
  </p>
  <p>
    Resulta más útil combinado con otra cosa: aplícale <code>zip</code> con una
    secuencia de longitud variable para estampar una etiqueta constante en cada
    elemento, o usa <code>fx(...).join()</code> para construir una cadena
    separadora de ancho fijo. <code>repeat(0, value)</code> es una forma válida
    y perfectamente normal de obtener un iterable vacío.
  </p>
  <p>
    Si lo que quieres es repetir una <em>secuencia</em> entera en vez de un
    único valor —y seguir indefinidamente en lugar de un número fijo
    <code>n</code> de veces— eso es <code>cycle</code>, que veremos a
    continuación.
  </p>

  <h2>Demo 1 · Fundamentos</h2>
  {{playground:0}}

  <h2>Demo 2 · Emparejar una constante con una secuencia variable</h2>
  <p>
    <code>repeat</code> emite el MISMO valor cada vez: combínalo con
    <code>zip</code> para estampar una constante sobre una secuencia de
    longitud variable:
  </p>
  {{playground:1}}

  <h2>Pruébalo tú</h2>
  <p>Ejercicio: construye una <code>List&lt;int&gt;</code> de 5 elementos con
    el valor 7 usando <code>repeat</code>.</p>
  {{playground:2}}

  <div class="callout">
    <strong>Relacionado:</strong>
    <a href="range.html"><code>range</code></a> — una secuencia perezosa de enteros crecientes o decrecientes ·
    <a href="cycle.html"><code>cycle</code></a> — repite una secuencia entera, para siempre ·
    <a href="zip.html"><code>zip</code></a> — empareja, se usa a menudo junto a repeat ·
    <a href="fx.html"><code>fx</code></a> — la cadena en la que repeat suele envolverse
  </div>
