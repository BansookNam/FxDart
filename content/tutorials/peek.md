---
slug: peek
title: peek — FxDart 101
description: FxDart peek tutorial: observe elements flowing through a pipeline without transforming them, with a live playground.
heading: <code>peek</code>
section: 3
crumb: peek
prev: scan.html
prevLabel: scan
next: pluck.html
nextLabel: pluck
---
  <p class="hero-sub">Runs a function for each element without changing anything — the pipeline equivalent of a debugger breakpoint.</p>

  {{signature}}

  <h2>Lecture</h2>
  <p>
    <code>peek</code> is <code>mapEffect</code>'s stricter cousin: where
    <code>mapEffect</code> can still change the value (it's <code>map</code>
    under a different name), <code>peek</code>'s callback returns
    <code>void</code> — it is only ever allowed to look. The element that
    went in comes back out completely untouched. Reach for it to drop a
    <code>print</code>, a metric, or a log line into the middle of a
    pipeline while debugging, without risking a typo that silently mutates
    the data.
  </p>
  <p>
    It's just as lazy as everything else here: the callback fires exactly
    once per element that gets pulled through, in order, and not before.
  </p>
  <p>
    <code>peekAsync</code> is built directly on top of <code>mapAsync</code>
    (it awaits <code>f</code>, then re-yields the original value), so it
    shares <code>map</code>'s concurrency behavior exactly:
    <code>.concurrent(n)</code> genuinely runs <code>n</code> callbacks in
    parallel — unlike <code>flatMap</code> or <code>scan</code>, whose
    internal state machines have to stay sequential.
  </p>

  <h2>Demo 1 · Basics</h2>
  <p>Same values in, same values out — <code>peek</code> only ever
    observes:</p>
  {{playground:0}}

  <h2>Demo 2 · Async, with real concurrency</h2>
  {{playground:1}}

  <h2>Try it yourself</h2>
  <p>Exercise: use <code>peek</code> to print
    <code>'checking price: $p'</code> for each price without changing the
    values, then sum them with <code>fold</code>.</p>
  {{playground:2}}

  <div class="callout">
    <strong>Related:</strong>
    <a href="mapEffect.html"><code>mapEffect</code></a> — like peek, but can transform ·
    <a href="map.html"><code>map</code></a> — transform each element ·
    <a href="pluck.html"><code>pluck</code></a> — pull one field out of each map ·
    <a href="concurrent.html"><code>concurrent</code></a> — parallel evaluation
  </div>
