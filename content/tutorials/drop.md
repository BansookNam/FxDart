---
slug: drop
title: drop — FxDart 101
description: FxDart drop tutorial: skip the first n values of a lazy pipeline, with a live playground.
heading: <code>drop</code>
section: 5
crumb: drop
prev: takeUntilInclusive.html
prevLabel: takeUntilInclusive
next: dropRight.html
nextLabel: dropRight
---
  <p class="hero-sub">Returns a lazy iterable that skips the first <code>length</code> values.</p>

  {{signature}}

  <h2>Lecture</h2>
  <p>
    <code>drop</code> is <code>take</code>'s opposite: it discards the first
    <code>length</code> values and yields everything after them. It's still
    lazy — nothing is skipped until the pipeline is actually pulled — and it
    works fine on infinite sources, since it only needs to count off a fixed
    number of elements before passing the rest straight through.
  </p>
  <p>
    On the <code>Fx</code> chain, <code>drop</code> is also available as
    <code>skip</code>, matching Dart's own <code>Iterable.skip</code> naming
    (FxDart's <code>Fx</code> already extends <code>Iterable</code>, so both
    spellings resolve to the same operator).
  </p>

  <h2>Demo 1 · Basics</h2>
  {{playground:0}}

  <h2>Demo 2 · Async, with concurrency</h2>
  {{playground:1}}

  <h2>Try it yourself</h2>
  <p>Exercise: drop the first 2 header lines.</p>
  {{playground:2}}

  <div class="callout">
    <strong>Related:</strong>
    <a href="take.html"><code>take</code></a> — the opposite, keep the first n ·
    <a href="dropRight.html"><code>dropRight</code></a> — drop from the end ·
    <a href="dropWhile.html"><code>dropWhile</code></a> — drop by predicate ·
    <a href="slice.html"><code>slice</code></a> — arbitrary index window
  </div>
