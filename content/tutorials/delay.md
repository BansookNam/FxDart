---
slug: delay
title: delay &amp; sleep — FxDart 101
description: FxDart delay and sleep tutorial: the two building blocks every async demo on this site is built from, with a live playground.
heading: <code>fxDelay</code> &amp; <code>fxSleep</code>
section: 10
crumb: delay &amp; sleep
prev: comparisons.html
prevLabel: gt · gte · lt · lte
next: unicodeToList.html
nextLabel: unicodeToList
---
  <p class="hero-sub">Wait for a bit, then produce a value (delay) — or just wait (sleep).</p>

  {{signature}}

  <h2>Lecture</h2>
  <p>
    <code>fxDelay(wait, value)</code> returns a <code>Future</code> that
    completes with <code>value</code> after <code>wait</code> has elapsed.
    <code>fxSleep(wait)</code> is the same idea with nothing to return — it
    just completes after the duration. Both are thin wrappers over
    <code>Future.delayed</code>, and both are exactly what you'd reach for to
    simulate a slow operation: a network call, a database query, anything
    that takes time and eventually produces (or doesn't produce) a result.
  </p>
  <p>
    These two functions are the backbone of nearly every async demo across
    this whole tutorial site. Whenever you see <code>fxMapAsync</code>,
    <code>concurrent</code>, <code>debounce</code>, or <code>throttle</code>
    demonstrated with a <code>Stopwatch</code> proving something ran in
    parallel or was rate-limited, it's <code>fxDelay</code> or <code>fxSleep</code>
    doing the actual waiting under the hood.
  </p>

  <h2>Demo 1 · Basics</h2>
  {{playground:0}}

  <h2>Demo 2 · Simulating concurrent work</h2>
  <p>
    Three "requests" each take 150ms, but run concurrently — the whole batch
    still finishes in well under 450ms:
  </p>
  {{playground:1}}

  <h2>Try it yourself</h2>
  <p>Exercise: use <code>fxDelay</code> to simulate a 100ms "fetch" that
    returns <code>'pong'</code>.</p>
  {{playground:2}}

  <div class="callout">
    <strong>Related:</strong>
    <a href="memoize.html"><code>fxMemoize</code></a> — caches a delayed Future so it only waits once ·
    <a href="concurrent.html"><code>concurrent</code></a> — run multiple delays in parallel ·
    <a href="debounce.html"><code>fxDebounce</code></a> / <a href="throttle.html"><code>fxThrottle</code></a> — rate-limiting built on top of waiting ·
    <a href="toAsync.html"><code>toAsync</code></a> — turn a plain Iterable into an async pipeline
  </div>
