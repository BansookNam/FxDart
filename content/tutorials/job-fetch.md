---
slug: job-fetch
title: Bounded concurrent fetch — FxDart 101
description: A job tutorial: fetch N records at most K at a time, keep order, keep every failure — mapConcurrent, mapRetry, mapOrAccumulate.
heading: Bounded concurrent fetch
section: 15
crumb: bounded concurrent fetch
prev: job-search.html
prevLabel: debounced search
---
  <p class="hero-sub">A bound, order kept, every failure kept. This is the job <code>Future.wait</code> does not have a primitive for.</p>

  {{signature}}

  <h2>Lecture</h2>
  <p>
    Fetching a known list of ids is not an event stream. The data is in
    hand; the work is I/O; the policy is "at most <em>n</em> in flight,
    results in the original order." That is
    <code><a href="mapConcurrent.html">mapConcurrent</a></code> (or
    <code>.toAsync().map(f).<a href="concurrent.html">concurrent</a>(n)</code>,
    the same chain written in three steps).
    <code>Future.wait(ids.map(fetch))</code> fires everything at once.
    Batching into groups of <em>n</em> waits for the slowest of each
    group. Doing it right by hand is a worker pool — a shared cursor,
    pre-sized slots, worker futures. FxDart's word for that pool is
    <code>concurrent(n)</code>.
  </p>
  <p>
    Flaky calls retry
    <em>per element</em> with
    <code><a href="retry.html">mapRetry</a></code>, not by wrapping the
    whole terminal. Validation that should report every problem — not
    just the first — is
    <code><a href="eitherPipelines.html">mapOrAccumulate</a></code> with
    <code>concurrency: n</code>. Each element runs in its own raise
    scope, so a failure in one cannot leak into a sibling, and the
    failures come out in input order.
  </p>
  <p>
    The
    <a href="../DartComparison/bounded-concurrency.html">Dart comparison</a>
    of the worker-pool job verdicts <strong>fxdart</strong> on clarity;
    the native pool is shorter than it looks once you have written it
    twice. This page is that job plus the typed-error half, which the
    comparison examples do not show.
  </p>

  <h2>Demo 1 · two in flight, order kept</h2>
  <p>
    Six fetches, never more than two overlapping. The fake call counts
    in-flight requests so the bound is visible in the printout.
  </p>
  {{playground:0}}

  <h2>Demo 2 · every failure kept, still bounded</h2>
  <p>
    Even ids fail. <code>mapOrAccumulate</code> still runs three at a
    time, still returns in order, and the <code>Left</code> holds
    <em>every</em> even id — fail-slow, not fail-fast.
  </p>
  {{playground:1}}

  <div class="callout">
    <strong>Related:</strong>
    <a href="whichSurface.html">which surface</a> — why this is pull-async ·
    <a href="concurrent.html"><code>concurrent</code></a> ·
    <a href="mapConcurrent.html"><code>mapConcurrent</code></a> ·
    <a href="retry.html"><code>retry</code> / <code>mapRetry</code></a> ·
    <a href="eitherPipelines.html"><code>mapOrAccumulate</code></a> ·
    <a href="job-search.html">debounced search</a> — the time job ·
    <a href="../DartComparison/bounded-concurrency.html">Dart vs FxDart: two at a time</a>
  </div>
