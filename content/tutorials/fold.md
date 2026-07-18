---
slug: fold
title: fold — FxDart 101
description: FxDart fold tutorial: reduce with an explicit seed, safe on empty input, with a live playground.
heading: <code>fold</code>
section: 7
crumb: fold
prev: reduce.html
prevLabel: reduce
next: reduceLazy.html
nextLabel: reduceLazy
---
  <p class="hero-sub">The seeded form of reduce: always safe, even on an empty pipeline.</p>

  {{signature}}

  <h2>Lecture</h2>
  <p>
    <code>fold</code> is <code><a href="reduce.html">reduce</a></code> with an
    explicit starting value. In FxTS this is just <code>reduce</code> called
    with three arguments — <code>reduce(f, seed, iterable)</code>. Dart can't
    tell overloads apart by argument count, so FxDart splits the two: the
    unseeded form keeps the name <code>reduce</code>, and the seeded form is
    renamed <code>fold</code>, matching the name Dart's own
    <code>Iterable</code> already uses for exactly this operation.
  </p>
  <p>
    Note the argument order carefully: it's <code>fold(seed, f, iterable)</code>
    — seed first, then the combiner, then the source — mirroring
    <code>Iterable.fold(initialValue, combine)</code> on the chain form. That's
    different from FxTS's <code>reduce(f, seed, iterable)</code>, where the
    function comes first.
  </p>
  <p>
    Because you always supply the seed, <code>fold</code> never throws on an
    empty iterable — it just returns the seed unchanged. That makes it the
    safer default whenever you're not sure the pipeline has any elements at
    all. Like <code>reduce</code>, it's a terminal operator: nothing upstream
    runs until <code>fold</code> pulls it.
  </p>

  <h2>Demo 1 · Basics &amp; empty input</h2>
  {{playground:0}}

  <h2>Demo 2 · Async, building up a Map</h2>
  <p>The seed doesn't have to be a number — here we fold a delayed pipeline into a length histogram:</p>
  {{playground:1}}

  <h2>Try it yourself</h2>
  <p>Exercise: <code>fold</code> the deposits into a running balance, starting from <code>1000</code>.</p>
  {{playground:2}}

  <div class="callout">
    <strong>Related:</strong>
    <a href="reduce.html"><code>reduce</code></a> — the unseeded counterpart ·
    <a href="reduceLazy.html"><code>reduceLazy</code></a> — a reusable, curried reducer ·
    <a href="sum.html"><code>sum</code></a> — a common fold, specialized ·
    <a href="scan.html"><code>scan</code></a> — like fold, but lazily yields every intermediate value
  </div>
