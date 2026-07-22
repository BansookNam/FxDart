---
slug: size
title: count — FxDart 101
description: FxDart count: count the elements a pipeline produces, with a live playground.
heading: <code>count</code>
section: 7
crumb: count
prev: max.html
prevLabel: max
next: join.html
nextLabel: join
---
  <p class="hero-sub">Counts how many elements a lazy pipeline produces.</p>

  {{signature}}

  <h2>Lecture</h2>
  <p>
    <code>count</code> is a terminal operator that counts elements by walking
    through all of them — there's no shortcut, because the upstream pipeline
    might be a lazily-computed <code>map</code>/<code>filter</code> chain with
    no fixed length until it's actually pulled. That means calling
    <code>count</code> on a <code>filter</code>ed million-element
    <code>range</code> really does iterate all million values; it just
    doesn't build a <code>List</code> to do it. <code>count</code> is the
    Dart-idiomatic name; fxdart also accepts the FxTS spelling
    <code>size</code> — they're the same operator.
  </p>
  <p>
    It works on any element type — unlike the numeric terminals
    (<code><a href="sum.html">sum</a></code>,
    <code><a href="min.html">min</a></code>,
    <code><a href="max.html">max</a></code>,
    <code><a href="average.html">average</a></code>), <code>count</code>
    doesn't care what's inside the iterable, only how many there are.
  </p>
  <p>
    On the sync chain, <code>count</code> <em>is</em> Dart's inherited
    <code>Iterable.length</code> getter (no parens) — since <code>Fx</code> is
    an <code>Iterable</code>, <code>fx(pipeline).length</code> walks the chain
    and returns the total. Use the top-level <code>count(iterable)</code>, or
    <code>.count()</code> on the <em>async</em> chain, when you'd rather write
    it as a named operator. If you already have a concrete <code>List</code>,
    its <code>.length</code> is free — reach for <code>count</code>
    specifically when you're counting the output of a lazy chain without
    wanting to materialize it into a <code>List</code> first via
    <code><a href="../101/index.html">toList</a></code>.
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
    <a href="average.html"><code>average</code></a> — uses a count-like tally internally ·
    <a href="isEmpty.html"><code>isEmpty</code></a> — a cheaper check when you only need to know "any at all?" ·
    <a href="../101/index.html">toList</a> — materialize instead of just counting
  </div>
