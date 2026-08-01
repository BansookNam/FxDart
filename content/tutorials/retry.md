---
slug: retry
title: retry — FxDart 101
description: FxDart retry and mapRetry tutorial: rerun flaky effects with backoff, per element or per pipeline, parallel-safe — with a live playground.
heading: <code>retry</code>
section: 11
crumb: retry
prev: concurrentPool.html
prevLabel: concurrentPool
next: timeout.html
nextLabel: timeout
---
  <p class="hero-sub">Runs a flaky effect again until it succeeds — up to <code>attempts</code> times, with optional backoff between failures.</p>

  {{signature}}

  <h2>Lecture</h2>
  <p>
    Real pipelines call real services, and real services flake. The
    hand-rolled answer is a <code>for</code> loop with a
    <code>try</code>/<code>catch</code>, a counter, and a
    <code>Future.delayed</code> — copied into every project, subtly
    different each time. <code>retry(attempts, f)</code> is that loop,
    once: run <code>f</code>, and on error run it again, up to
    <code>attempts</code> total runs; when the budget is spent the
    <em>last</em> error rethrows with its original stack trace. The
    <code>delay</code> hook receives the failure count
    (<code>1, 2, …</code>), so backoff is one line:
    <code>delay: (failed)&nbsp;=&gt;&nbsp;Duration(seconds:&nbsp;failed)</code>.
  </p>
  <p>
    <code>mapRetry(attempts, f)</code> is the same idea per element: a
    <code><a href="map.html">map</a></code> whose every call gets its own
    retry budget. It is built on the parallel-safe <code>mapAsync</code>,
    so under <code><a href="concurrent.html">concurrent(n)</a></code>
    each in-flight element retries <em>independently</em> — one slow,
    flaky item re-runs while its neighbors sail through, and order is
    still preserved. To retry a whole pipeline instead, wrap its
    terminal: <code>retry(3, ()&nbsp;=&gt;&nbsp;fxAsync(…).toList())</code> —
    the partial result is discarded and the pipeline re-runs from a fresh
    iterator.
  </p>
  <p>
    fxdart extension (no FxTS counterpart), after Rx's
    <code>retry</code>/<code>retryWhen</code> — re-designed for the pull
    model, where "resubscribe" means "build the iterable again". For
    <em>typed</em> failure handling after the retries run out, hand the
    result to <code><a href="eitherPipelines.html">eitherCatching</a></code>.
  </p>

  <h2>Demo 1 · A flaky fetch, with backoff</h2>
  {{playground:0}}

  <h2>Demo 2 · mapRetry under concurrent</h2>
  {{playground:1}}

  <h2>Try it yourself</h2>
  <p>Exercise: make the import survive its flaky rows.</p>
  {{playground:2}}

  <div class="callout">
    <strong>Related:</strong>
    <a href="timeout.html"><code>timeout</code></a> — bound how long each pull may take ·
    <a href="concurrent.html"><code>concurrent</code></a> — retries stay independent per in-flight element ·
    <a href="eitherPipelines.html">typed errors</a> — when the failure should be a value, not an exception
  </div>
