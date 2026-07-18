---
slug: slice
title: slice — FxDart 101
description: Tutorial de slice en FxDart: extrae de un iterable la ventana de índices [start, end), con playground en vivo.
heading: <code>slice</code>
section: 5
crumb: slice
prev: dropUntil.html
prevLabel: dropUntil
next: chunk.html
nextLabel: chunk
---
  <p class="hero-sub">Devuelve los valores entre el índice <code>start</code> (incluido) y <code>end</code> (excluido).</p>

  {{signature}}

  <h2>Lección</h2>
  <p>
    <code>slice</code> es una ventana de índices genérica: emite los elementos
    cuya posición cae en <code>[start, end)</code>, y omitir <code>end</code>
    significa «hasta el final de la fuente». Es un único operador que engloba a
    la vez a <code>drop</code> (mediante <code>start</code>) y a
    <code>take</code> (mediante <code>end</code>).
  </p>
  <p>
    Ojo con el orden de los argumentos en la forma data-first: a diferencia de
    la mayoría de funciones de FxDart, el <code>iterable</code> va en
    <strong>medio</strong>: <code>slice(start, iterable, [end])</code>,
    igual que en FxTS. La forma encadenada no tiene esta rareza, porque el
    iterable es el receptor: <code>fx(iterable).slice(start, end)</code>. Por
    dentro, <code>slice</code> se limita a recorrer la fuente una vez contando
    índices, así que sigue siendo perezoso y funciona sin problema sobre una
    fuente infinita mientras le des un <code>end</code>.
  </p>

  <h2>Demo 1 · Fundamentos &amp; orden de los argumentos</h2>
  {{playground:0}}

  <h2>Demo 2 · Asíncrono</h2>
  {{playground:1}}

  <h2>Pruébalo tú</h2>
  <p>Ejercicio: usa <code>slice</code> para quedarte con la ventana desde el
    índice 2 hasta el índice 5 (sin incluirlo).</p>
  {{playground:2}}

  <div class="callout">
    <strong>Relacionado:</strong>
    <a href="drop.html"><code>drop</code></a> — solo la mitad de slice correspondiente al índice inicial ·
    <a href="take.html"><code>take</code></a> — solo la mitad de slice correspondiente al final o al conteo ·
    <a href="chunk.html"><code>chunk</code></a> — ventanas de tamaño fijo a lo largo de toda la fuente
  </div>
