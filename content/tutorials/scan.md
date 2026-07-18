---
slug: scan
title: scan — FxDart 101
description: FxDart scan tutorial: a lazy running accumulation, seeded or unseeded, with a live playground.
heading: <code>scan</code>
section: 3
crumb: scan
prev: flat.html
prevLabel: flat
next: peek.html
nextLabel: peek
---
  <p class="hero-sub">A lazy running accumulation — like <code>reduce</code>, but it yields every intermediate value instead of only the last.</p>

  {{signature}}

  <h2>Lecture</h2>
  <p>
    <code>scan</code> is <code>reduce</code>/<code>fold</code> with its
    intermediate steps exposed: instead of collapsing an iterable down to
    one final value, it emits <em>every</em> running accumulation, including
    the seed itself as the first value. That first-value-is-the-seed detail
    matters — <code>scan(f, 0, [1, 2, 3])</code> yields four values
    (<code>0</code>, then three running sums), not three.
  </p>
  <p>
    <code>scan1</code> is the unseeded variant, ported from FxTS's
    <code>scan(f, iterable)</code> overload (no seed argument). It uses the
    first element of the iterable as the initial accumulator and yields it
    immediately, then keeps folding the rest — mirroring <code>reduce</code>'s
    relationship to <code>fold</code>. On an empty iterable, <code>scan1</code>
    has no first element to seed with, so it yields nothing at all. Note
    there is no chain method for <code>scan1</code> (only <code>scan</code> is
    on <code>Fx</code>/<code>FxAsync</code>) — call it data-first:
    <code>scan1(f, iterable)</code>.
  </p>
  <p>
    Both are lazy: nothing runs until you pull. On the async side,
    <code>scanAsync</code>/<code>scan1Async</code> still fold one step at a
    time in order (each step needs the previous result), so
    <code>.concurrent(n)</code> doesn't parallelize the fold itself — but it
    does let an upstream fetch stage run concurrently, as long as the
    accumulator function itself stays cheap. See Demo 2.
  </p>

  <h2>Demo 1 · Basics — scan and scan1</h2>
  {{playground:0}}

  <h2>Demo 2 · Async, with concurrency upstream</h2>
  <p>
    The fold itself stays sequential, but the fetch that feeds it doesn't
    have to:
  </p>
  {{playground:1}}

  <h2>Try it yourself</h2>
  <p>Exercise: use <code>scan</code> to produce a running total of steps,
    seeded at <code>0</code>.</p>
  {{playground:2}}

  <div class="callout">
    <strong>Related:</strong>
    <a href="../tutorials/reduce.html"><code>reduce</code>/<code>fold</code></a> — collapse to one final value ·
    <a href="flat.html"><code>flat</code></a> — flatten nested iterables ·
    <a href="peek.html"><code>peek</code></a> — observe without transforming ·
    <a href="concurrent.html"><code>concurrent</code></a> — parallel evaluation
  </div>
