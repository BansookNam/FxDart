---
slug: size
title: count — FxDart 101
description: Tutorial de size en FxDart: cuenta los elementos que produce un pipeline, con playground en vivo.
heading: <code>count</code>
section: 7
crumb: count
prev: minBy.html
prevLabel: minBy
next: join.html
nextLabel: join
---
  <p class="hero-sub">Cuenta cuántos elementos produce un pipeline perezoso.</p>

  {{signature}}

  <h2>Lección</h2>
  <p>
    <code>count</code> es un operador terminal que cuenta los elementos
    recorriéndolos todos: no hay atajo posible, porque el pipeline de aguas
    arriba puede ser una cadena de <code>map</code>/<code>filter</code>
    evaluada de forma perezosa, sin longitud fija hasta que realmente se tira
    de ella. Es decir, llamar a <code>count</code> sobre un <code>range</code>
    de un millón de elementos con <code>filter</code> recorre de verdad el
    millón de valores; simplemente no construye una <code>List</code> para
    ello. <code>count</code> es el nombre idiomático en Dart; fxdart también
    acepta <code>size</code>, la grafía de FxTS: son el mismo operador.
  </p>
  <p>
    Funciona con cualquier tipo de elemento: a diferencia de los terminales
    numéricos (<code><a href="sum.html">sum</a></code>,
    <code><a href="min.html">min</a></code>,
    <code><a href="max.html">max</a></code>,
    <code><a href="average.html">average</a></code>), a <code>count</code> no
    le importa qué hay dentro del iterable, solo cuántos elementos hay.
  </p>
  <p>
    En la cadena síncrona, <code>count</code> <em>es</em> el getter
    <code>Iterable.length</code> heredado de Dart (sin paréntesis): como
    <code>Fx</code> es un <code>Iterable</code>, <code>fx(pipeline).length</code>
    recorre la cadena y devuelve el total. Usa el <code>count(iterable)</code>
    de nivel superior, o <code>.count()</code> en la cadena <em>asíncrona</em>,
    cuando prefieras escribirlo como un operador con nombre. Si ya tienes una
    <code>List</code> concreta, su <code>.length</code> es gratis: recurre a
    <code>count</code> precisamente cuando quieras contar la salida de una
    cadena perezosa sin materializarla antes en una <code>List</code> con
    <code><a href="../101/index.html">toList</a></code>.
  </p>

  <h2>Demo 1 · Fundamentos</h2>
  {{playground:0}}

  <h2>Demo 2 · Asíncrono</h2>
  {{playground:1}}

  <h2>Pruébalo tú</h2>
  <p>Ejercicio: cuenta cuántas entradas están <strong>sin stock</strong> (valor <code>== 0</code>).</p>
  {{playground:2}}

  <div class="callout">
    <strong>Relacionado:</strong>
    <a href="average.html"><code>average</code></a> — usa internamente un conteo similar a count ·
    <a href="isEmpty.html"><code>isEmpty</code></a> — una comprobación más barata cuando solo necesitas saber «¿hay alguno?» ·
    <a href="../101/index.html">toList</a> — materializa en lugar de solo contar
  </div>
