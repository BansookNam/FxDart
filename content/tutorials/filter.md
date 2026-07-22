---
slug: filter
title: where — FxDart 101
description: FxDart where tutorial: keep only the elements a predicate accepts, sync and async, with a live playground.
heading: <code>where</code>
section: 4
crumb: where
prev: pluck.html
prevLabel: pluck
next: reject.html
nextLabel: reject
---
  <p class="hero-sub">Returns a lazy iterable of the elements a predicate returns true for.</p>

  {{signature}}

  <h2>Lecture</h2>
  <p>
    <code>where</code> is the other fundamental transformer alongside
    <code>map</code>: it keeps every element for which the predicate
    returns <code>true</code> and drops the rest, lazily. Nothing runs
    until a terminal operator pulls values through. <code>where</code> is
    the Dart-idiomatic name; fxdart also accepts the FxTS spelling
    <code>filter</code> — they're the same operator.
  </p>
  <p>
    Because it's lazy, combining <code>where</code> with <code>take</code>
    only evaluates as many predicate calls as needed to satisfy the
    <code>take</code> — see Demo 1.
  </p>
  <p>
    <code>whereAsync</code> has its own dedicated concurrent implementation
    (rather than reusing <code>mapAsync</code>'s): when you attach
    <code>.concurrent(n)</code>, <code>n</code> predicates are evaluated in
    parallel, but the elements that pass are still released downstream in
    their original order — concurrency changes throughput, never the
    result.
  </p>

  <h2>Demo 1 · Basics &amp; laziness</h2>
  {{playground:0}}

  <h2>Demo 2 · Async, with concurrency</h2>
  {{playground:1}}

  <h2>Try it yourself</h2>
  <p>Exercise: use <code>where</code> to keep only ages 18 and over.</p>
  {{playground:2}}

  <div class="callout">
    <strong>Related:</strong>
    <a href="reject.html"><code>reject</code></a> — the opposite of filter ·
    <a href="compact.html"><code>compact</code></a> — filter out nulls ·
    <a href="map.html"><code>map</code></a> — transform instead of keep/drop ·
    <a href="concurrent.html"><code>concurrent</code></a> — parallel evaluation
  </div>
