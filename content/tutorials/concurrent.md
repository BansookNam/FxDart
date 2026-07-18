---
slug: concurrent
title: concurrent — FxDart 101
description: FxDart concurrent tutorial: run n async elements at once while preserving order, the concurrency-marker model, with a live playground.
heading: <code>concurrent</code>
section: 11
crumb: concurrent
next: concurrentPool.html
nextLabel: concurrentPool
---
  <p class="hero-sub">Evaluates up to n elements of an async pipeline at once, while the result still arrives in source order.</p>

  {{signature}}

  <h2>Lecture</h2>
  <p>
    <code>concurrent(n)</code> is FxDart's answer to "run several async steps
    in parallel, but keep the results in order." It works through the
    <strong>concurrency-marker</strong> model baked into
    <code>FxAsyncIterator.next([Concurrent? concurrent])</code>: when you call
    <code>.concurrent(3)</code>, every pull through it passes a
    <code>Concurrent(3)</code> marker <em>upstream</em>, one layer at a time,
    telling whatever produced the values ("evaluate 3 of you at once instead
    of one"). The upstream operator — typically a lazy <code>map</code> — sees
    that marker and, instead of awaiting one Future and then starting the
    next, calls its own source's <code>next()</code> three times without
    waiting in between, so three Futures are in flight simultaneously. As each
    settles, <code>concurrent</code> buffers the result but only releases
    values to <em>you</em> in the original order — so results always come out
    matching the input sequence, even if a later item finishes before an
    earlier one.
  </p>
  <p>
    This is the back-channel that <code>toAsync</code>'s lecture mentioned:
    Dart's <code>Stream</code> has no way to ask an upstream source "give me
    3 at once" after the fact, because a <code>Stream</code> pushes at its own
    pace. FxDart's pull-based <code>next()</code> protocol carries that
    request upstream on every single pull, which is what makes
    <code>concurrent(n)</code> possible at all.
  </p>
  <p>
    Tune <code>n</code> based on what you're limited by: a REST API might
    tolerate 5-10 concurrent requests, a local CPU-bound task might want
    <code>n</code> close to your core count, and <code>n = 1</code> is
    equivalent to plain sequential awaiting (which is exactly what you get
    without <code>concurrent</code> at all).
  </p>

  <h2>Demo 1 · Sequential vs. concurrent(3), timed</h2>
  <p>Six items, each with a 200ms delay. Sequential takes ~1200ms; asking for
    3 at a time cuts it to ~400ms:</p>
  {{playground:0}}

  <h2>Demo 2 · Order is preserved, even when completion order isn't</h2>
  <p>
    Item 2 finishes before item 1 here (100ms vs. 300ms), but
    <code>concurrent(3)</code> still hands back results in source order —
    compare this with <a href="concurrentPool.html"><code>concurrentPool</code></a>,
    which does the opposite:
  </p>
  {{playground:1}}

  <h2>Try it yourself</h2>
  <p>Exercise: this pipeline processes 6 items of 200ms each, sequentially
    (<code>n = 1</code>). Tune <code>n</code> up and watch the elapsed time
    drop — try <code>3</code>, then <code>6</code>.</p>
  {{playground:2}}

  <div class="callout">
    <strong>Related:</strong>
    <a href="concurrentPool.html"><code>concurrentPool</code></a> — completion-order variant ·
    <a href="toAsync.html"><code>toAsync</code></a> — the pull-based model this relies on ·
    <a href="asyncVariants.html">async variants</a> — the *Async naming convention ·
    <a href="map.html"><code>map</code></a> — the operator most often paired with concurrent
  </div>
