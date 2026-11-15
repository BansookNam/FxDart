---
slug: mapCatching
title: mapCatching — FxDart 101
description: FxDart mapCatching tutorial: recover each element's error in place so one bad row never ends the pipeline, sync and async, with typed errors left untouched.
heading: <code>fxMapCatching</code>
section: 11
crumb: mapCatching
prev: retry.html
prevLabel: retry
next: timeout.html
nextLabel: timeout
---
  <p class="hero-sub">A <code>map</code> where each element's failure is replaced by a value — one bad row never ends the iteration.</p>

  {{signature}}

  <h2>Lecture</h2>
  <p>
    A <code><a href="map.html">map</a></code> whose callback throws ends
    the whole pipeline at that element: one malformed row in ten thousand
    and you get an exception, not nine thousand nine hundred and ninety-nine
    results. <code>mapCatching(f, onError)</code> runs <code>f</code> on each
    element and, when it throws, hands the error and its stack trace to
    <code>onError</code> and yields what that returns <em>in the failed
    element's place</em>. The next element is mapped as if nothing had
    happened. It stays lazy, and on <code>Fx</code> it stays on the sync
    chain — there is nothing to await.
  </p>
  <p>
    It sits beside <code><a href="retry.html">mapRetry</a></code>, and the
    two are the two answers to a failing element: <code>mapRetry</code> runs
    it <em>again</em>; <code>mapCatching</code> gives up on it and
    substitutes.
    The async form, <code>fxMapCatchingAsync</code> /
    <code>fxAsync(…).mapCatching</code>, lets both <code>f</code> and
    <code>onError</code> await, and is built on the parallel-safe
    <code>fxMapAsync</code>, so under
    <code><a href="concurrent.html">concurrent(n)</a></code> each in-flight
    element recovers on its own and order is kept. RxDart writes this as
    <code>onErrorReturnWith</code>; on an fxdart
    <a href="fxEvents.html">push stream</a> the neighbours are
    <a href="onErrorResume.html"><code>onErrorReturn</code></a>, which
    substitutes one fixed value per error, and
    <a href="attempt.html"><code>attempt</code></a>, which keeps the error
    as a <code>Left</code> instead of replacing it.
  </p>
  <p>
    One thing is <strong>never</strong> recovered: the library's own raise
    signal. A <code>r.raise(…)</code> — from a <code>bind</code>, an
    <code>ensure</code>, or a nested builder — crossing <code>f</code> is
    rethrown, so it still short-circuits the enclosing
    <a href="raise.html"><code>fxEither</code></a> /
    <a href="nullable.html"><code>fxNullable</code></a> block. Recovering it
    would turn a typed error into a lost one. As with any lazy pipeline in a
    raise block, materialize it (<code>toList()</code>) inside the block.
    fxdart extension (not part of FxTS).
  </p>

  <h2>Demo 1 · One bad row, recovered in place</h2>
  {{playground:0}}

  <h2>Demo 2 · Async under concurrent, and raise passes through</h2>
  {{playground:1}}

  <h2>Try it yourself</h2>
  <p>Exercise: replace the <code>try</code>/<code>catch</code> loop with one operator.</p>
  {{playground:2}}

  <div class="callout">
    <strong>Related:</strong>
    <a href="retry.html"><code>retry</code></a> — run the element again instead of replacing it ·
    <a href="onErrorResume.html"><code>onErrorReturn</code></a> — the same idea on a push stream ·
    <a href="eitherPipelines.html">typed errors</a> — when the failure should stay a value you can inspect
  </div>
