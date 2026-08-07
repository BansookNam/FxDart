---
slug: withIndex
title: mapWithIndex &amp; friends — FxDart 101
description: FxDart mapWithIndex, filterWithIndex, flatMapWithIndex and foldWithIndex tutorial: take the element's position as a second argument, with a live playground.
heading: <code>mapWithIndex</code> &amp; friends
section: 6
crumb: …WithIndex
prev: zipWithIndex.html
prevLabel: indexed
next: transpose.html
nextLabel: transpose
---
  <p class="hero-sub">The four index-aware operators — <code>map</code>, <code>filter</code>, <code>flatMap</code> and <code>fold</code> with the element's position as a second argument.</p>

  {{signature}}

  <h2>Lecture</h2>
  <p>
    <a href="zipWithIndex.html"><code>zipWithIndex</code></a> already gives
    you the position: pair every element with its index, then read the pair.
    That works, and it is the right tool when the pair itself is what you
    want. When it isn't, you pay for a record per element and a callback body
    written in <code>p.$1</code> / <code>p.$2</code> rather than names.
  </p>
  <p>
    These four take the index directly instead. There is nothing to allocate
    and nothing to unpack, and the chain says what it does.
  </p>
  <p>
    <strong>The index counts that stage's input.</strong> It is not the
    element's position in the original source — a
    <a href="filter.html"><code>filter</code></a> above
    <code>mapWithIndex</code> renumbers what survives it, starting from 0
    again. <code>filterWithIndex</code> is the one to read twice: its count
    advances across the elements it <em>drops</em>, because those are still
    input. <code>flatMapWithIndex</code> counts source elements, not emitted
    ones, so an inner iterable of five values still advances the index by one.
  </p>
  <p>
    Every one has an <code>…Async</code> form, and the numbering survives
    <a href="concurrent.html"><code>concurrent</code></a>: it overlaps the
    upstream pulls but still resolves them in order, so element <em>n</em>
    gets index <em>n</em> whatever the latencies were. The counter also lives
    per <em>iteration</em>, so re-running a chain starts again at 0.
  </p>
  <p>
    One Dart wrinkle on <code>foldWithIndex</code>: an untyped accumulator
    lambda infers <code>Acc</code> as <code>Object?</code> and the arithmetic
    stops compiling. That is not new here — Dart's own
    <code>Iterable.fold</code> behaves the same way — and the fix is the same:
    write <code>foldWithIndex&lt;int&gt;(…)</code>.
  </p>

  <h2>Demo 1 · mapWithIndex, and what it replaces</h2>
  {{playground:0}}

  <h2>Demo 2 · filter, flatMap, fold — and async</h2>
  {{playground:1}}

  <h2>Try it yourself</h2>
  <p>Exercise: number the finishers 1st, 2nd, 3rd using the index.</p>
  {{playground:2}}

  <div class="callout">
    <strong>Related:</strong>
    <a href="zipWithIndex.html"><code>indexed</code></a> — the pair form, when the pair is what you want ·
    <a href="map.html"><code>map</code></a> / <a href="filter.html"><code>filter</code></a> / <a href="flatMap.html"><code>flatMap</code></a> — the operators these extend ·
    <a href="fold.html"><code>fold</code></a> — the seeded reduction ·
    <a href="foldRight.html"><code>foldRight</code></a> — the same fold from the other end
  </div>
