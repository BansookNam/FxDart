---
slug: size
title: size — FxDart 101
description: FxDart size tutorial: count the elements a pipeline produces, with a live playground.
heading: <code>size</code>
section: 7
crumb: size
prev: max.html
prevLabel: max
next: join.html
nextLabel: join
---
  <p class="hero-sub">Counts how many elements a lazy pipeline produces.</p>

  {{signature}}

  <h2>Lecture</h2>
  <p>
    <code>size</code> is a terminal operator that counts elements by walking
    through all of them — there's no shortcut, because the upstream pipeline
    might be a lazily-computed <code>map</code>/<code>filter</code> chain with
    no fixed length until it's actually pulled. That means calling
    <code>size</code> on a <code>filter</code>ed million-element
    <code>range</code> really does iterate all million values; it just
    doesn't build a <code>List</code> to do it.
  </p>
  <p>
    It works on any element type — unlike the numeric terminals
    (<code><a href="sum.html">sum</a></code>,
    <code><a href="min.html">min</a></code>,
    <code><a href="max.html">max</a></code>,
    <code><a href="average.html">average</a></code>), <code>size</code>
    doesn't care what's inside the iterable, only how many there are.
  </p>
  <p>
    If you already have a concrete <code>List</code>, its <code>.length</code>
    is free — reach for <code>size</code> specifically when you're counting
    the output of a lazy chain without wanting to materialize it into a
    <code>List</code> first via <code><a href="../101/index.html">toArray</a></code>.
  </p>

  <h2>Demo 1 · Basics</h2>
  {{playground:0}}

  <h2>Demo 2 · Async</h2>
  {{playground:1}}

  <h2>Try it yourself</h2>
  <p>Exercise: count how many entries are <strong>out of stock</strong> (value <code>== 0</code>).</p>
  {{playground:2}}

  <div class="callout">
    <strong>Related:</strong>
    <a href="average.html"><code>average</code></a> — uses a size-like count internally ·
    <a href="isEmpty.html"><code>isEmpty</code></a> — a cheaper check when you only need to know "any at all?" ·
    <a href="../101/index.html">toArray</a> — materialize instead of just counting
  </div>
