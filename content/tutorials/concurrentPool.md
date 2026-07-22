---
slug: concurrentPool
title: concurrentPool — FxDart 101
description: FxDart concurrentPool tutorial: a fixed-size pool of in-flight requests that yields results in completion order, with a live playground.
heading: <code>concurrentPool</code>
section: 11
crumb: concurrentPool
next: debounce.html
nextLabel: debounce
---
  <p class="hero-sub">Like concurrent, but yields results in completion order — whichever finishes first comes out first.</p>

  {{signature}}

  <h2>Lecture</h2>
  <p>
    <code>concurrentPool(n)</code> keeps up to <code>n</code> requests in
    flight against the upstream source, exactly like <code>concurrent(n)</code>
    — but it hands results back to you in the order they <strong>complete</strong>,
    not the order they started in. Think of it as a worker pool: as soon as
    one slot frees up, the next pending item is launched into it, and
    whichever finishes first is yielded first. This matches FxTS's
    <code>concurrentPool</code> and is the right tool when you don't care
    which result came from which input — you just want to react to results as
    soon as each one is ready (e.g. updating a progress list as each fetch
    lands), rather than blocking on the slowest one to preserve order.
  </p>
  <p>
    Unlike <code>concurrent</code>, which is driven by the downstream demand
    marker, <code>concurrentPool</code> <strong>eagerly keeps its pool
    full</strong>: from the first pull onward it holds up to <code>n</code>
    requests in flight no matter how many consumers are waiting. Even a
    one-pull-at-a-time terminal like <code>.toList()</code> or
    <code>.each()</code> gets the full overlap — and sees results in the
    order they finish.
  </p>

  <h2>Demo 1 · Completion order</h2>
  <p>Item 1 is slowest (300ms) and item 2 is fastest (100ms) — the result
    comes out fastest-first, straight from <code>.toList()</code>:</p>
  {{playground:0}}

  <h2>Demo 2 · Contrast with concurrent</h2>
  <p>Same delays, same pool size of 3 — the only difference is which order
    the results land in:</p>
  {{playground:1}}

  <h2>Try it yourself</h2>
  <p>Exercise: this pool size of 1 processes items one at a time, in launch
    order. Bump it to 3 so all three race at once, and watch the printed
    order switch to completion order.</p>
  {{playground:2}}

  <div class="callout">
    <strong>Related:</strong>
    <a href="concurrent.html"><code>concurrent</code></a> — order-preserving variant ·
    <a href="toAsync.html"><code>toAsync</code></a> — the pull-based model this relies on ·
    <a href="streams.html">Stream bridges</a> — apply concurrentPool before toStream() ·
    <a href="debounce.html"><code>debounce</code></a> — rate-limiting for callbacks
  </div>
