---
slug: mapAccum
title: mapAccum — FxDart 101
description: FxDart mapAccum tutorial: a running accumulation that emits one value per input — scan without the seed in the output — with a live playground.
heading: <code>fxMapAccum</code>
section: 3
crumb: mapAccum
prev: scan.html
prevLabel: scan
next: peek.html
nextLabel: peek
---
  <p class="hero-sub">A running accumulation, one value out for each value in — <code>scan</code> without the seed.</p>

  {{signature}}

  <h2>Lecture</h2>
  <p>
    <code><a href="scan.html">scan</a></code> emits its seed first, so
    <code>n</code> values in give <code>n + 1</code> out. That is right when
    the starting state is part of the answer — a ledger's opening balance —
    and wrong when it is only the state the first element folds into, which
    is why so many <code>scan</code> calls end in a trailing
    <code>.drop(1)</code>. <code>fxMapAccum(f, seed, xs)</code> is that
    shape as one operator: it folds <code>seed</code> into each value with
    <code>f</code> and emits every intermediate accumulation, but never the
    seed itself. <code>n</code> in, <code>n</code> out — an empty input
    emits nothing at all.
  </p>
  <p>
    The argument order matches <code>fxScan</code> on purpose, so moving
    from one to the other is a one-word edit. It is lazy, <code>f</code>
    runs exactly once per pulled element, in order, and the accumulator
    belongs to the iteration: iterating twice starts from
    <code>seed</code> both times. The accumulator type <code>B</code> need
    not match the element type — fold strings into a path, numbers into a
    record.
  </p>
  <p>
    <code>fxMapAccumAsync</code> lets both <code>f</code> and
    <code>seed</code> be a <code>Future</code>. The fold is serialized —
    each step needs the previous one — but an upstream stage can still run
    under <code><a href="concurrent.html">concurrent(n)</a></code>, as in
    Demo 2. On the chain it is <code>fx(xs).mapAccum(f, seed)</code>.
    fxdart extension (not part of FxTS) — Rust's
    <code>Iterator::scan</code>, Haskell's <code>mapAccumL</code> and
    RxDart's <code>scan</code> emit the same <code>n</code> values.
  </p>

  <h2>Demo 1 · scan, minus the seed</h2>
  {{playground:0}}

  <h2>Demo 2 · Async, with concurrency upstream</h2>
  {{playground:1}}

  <h2>Try it yourself</h2>
  <p>Exercise: drop the trailing <code>drop(1)</code>.</p>
  {{playground:2}}

  <div class="callout">
    <strong>Related:</strong>
    <a href="scan.html"><code>scan</code></a> — the same fold, seed included ·
    <a href="reduce.html"><code>reduce</code>/<code>fold</code></a> — only the final value ·
    <a href="drop.html"><code>drop</code></a> — what <code>mapAccum</code> saves you from ·
    <a href="concurrent.html"><code>concurrent</code></a> — parallel evaluation upstream
  </div>
