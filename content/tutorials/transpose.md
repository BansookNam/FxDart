---
slug: transpose
title: transpose — FxDart 101
description: FxDart transpose tutorial: turn rows into columns for any number of iterables, with a live playground.
heading: <code>transpose</code>
section: 6
crumb: transpose
prev: zipWithIndex.html
prevLabel: zipWithIndex
next: reverse.html
nextLabel: reverse
---
  <p class="hero-sub">Turns a collection of rows into a collection of columns.</p>

  {{signature}}

  <h2>Lecture</h2>
  <p>
    <code>transpose</code> is <code>zip</code> generalized to <em>any</em>
    number of iterables: the n-th output list holds the n-th element of
    every input row that still has one. Where <code>zip</code>/<code>zip3</code>
    take each row as a separate argument (because Dart can't express
    variadic generics), <code>transpose</code> takes all the rows as a
    <strong>single</strong> iterable of iterables —
    <code>transpose([row1, row2, row3])</code> — so it works for any row
    count decided at runtime.
  </p>
  <p>
    Unlike <code>zip</code>, which stops as soon as the shortest input runs
    dry, <code>transpose</code> keeps going as long as <em>any</em> row still
    has values left — a shorter row just stops contributing to later output
    lists, which may end up shorter than the row count. It only stops
    entirely once every row is exhausted.
  </p>

  <h2>Demo 1 · Basics &amp; ragged rows</h2>
  {{playground:0}}

  <h2>Demo 2 · Async</h2>
  {{playground:1}}

  <h2>Try it yourself</h2>
  <p>Exercise: transpose the matrix (rows become columns).</p>
  {{playground:2}}

  <div class="callout">
    <strong>Related:</strong>
    <a href="zip.html"><code>zip</code></a> — the two-row special case ·
    <a href="chunk.html"><code>chunk</code></a> — batch a flat source into rows first ·
    <a href="reverse.html"><code>reverse</code></a>
  </div>
