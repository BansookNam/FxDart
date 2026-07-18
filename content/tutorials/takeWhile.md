---
slug: takeWhile
title: takeWhile — FxDart 101
description: FxDart takeWhile tutorial: keep taking values as long as a predicate holds, then stop, with a live playground.
heading: <code>takeWhile</code>
section: 5
crumb: takeWhile
prev: takeRight.html
prevLabel: takeRight
next: takeUntilInclusive.html
nextLabel: takeUntilInclusive
---
  <p class="hero-sub">Yields values as long as a predicate returns true, then stops for good.</p>

  {{signature}}

  <h2>Lecture</h2>
  <p>
    Where <code>take</code> counts values, <code>takeWhile</code> tests them.
    It yields elements one at a time and stops the <em>instant</em>
    <code>f</code> returns false — it never looks past that point, even if a
    later element would have passed. That makes it a natural fit for
    "consume until the data stops making sense" situations: a sorted stream
    up to a threshold, a log up to the first anomaly, and so on.
  </p>
  <p>
    Because it's lazy and short-circuits on the first failure, it's cheap to
    run even over a huge or infinite source — it only ever evaluates the
    prefix that actually matches.
  </p>

  <h2>Demo 1 · Basics</h2>
  <p>Note that <code>2</code> at the end never gets a chance — the predicate
    already failed on <code>7</code>:</p>
  {{playground:0}}

  <h2>Demo 2 · Async</h2>
  {{playground:1}}

  <h2>Try it yourself</h2>
  <p>Exercise: keep temperatures only while they stay below 25.</p>
  {{playground:2}}

  <div class="callout">
    <strong>Related:</strong>
    <a href="take.html"><code>take</code></a> — take by count instead of predicate ·
    <a href="takeUntilInclusive.html"><code>takeUntilInclusive</code></a> — stop after (and including) the match ·
    <a href="dropWhile.html"><code>dropWhile</code></a> — the inverse ·
    <a href="filter.html"><code>filter</code></a> — keeps matches everywhere, not just a prefix
  </div>
