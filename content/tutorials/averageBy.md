---
slug: averageBy
title: averageBy — FxDart 101
description: FxDart averageBy tutorial: the mean of a key over every element — map + average in one step — with a live playground.
heading: <code>averageBy</code>
section: 7
crumb: averageBy
prev: average.html
prevLabel: average
next: min.html
nextLabel: min
---
  <p class="hero-sub">The mean of a key over every element — <code>map</code> + <code>average</code> in one step, <code>NaN</code> when empty.</p>

  {{signature}}

  <h2>Lecture</h2>
  <p>
    <code>averageBy</code> completes the by-key family
    (<code><a href="sumBy.html">sumBy</a></code> ·
    <code><a href="maxBy.html">maxBy</a></code> ·
    <code><a href="minBy.html">minBy</a></code>): it extracts a numeric key
    from each element and averages the keys, in one walk that tracks a
    running total and count.
  </p>
  <p>
    The contract is <code><a href="average.html">average</a></code>'s: an
    empty pipeline returns <code>double.nan</code> (it is computing
    <code>0 / 0</code>), never <code>0</code> — check
    <code>result.isNaN</code> when the input can be empty. The result is
    always a <code>double</code>.
  </p>

  <h2>Demo 1 · Basics &amp; the empty case</h2>
  {{playground:0}}

  <h2>Demo 2 · Async keys</h2>
  {{playground:1}}

  <h2>Try it yourself</h2>
  <p>Exercise: average only the read books' page counts with one call.</p>
  {{playground:2}}

  <div class="callout">
    <strong>Related:</strong>
    <a href="average.html"><code>average</code></a> — when the pipeline already holds numbers ·
    <a href="sumBy.html"><code>sumBy</code></a> — the numerator's cousin ·
    <a href="maxBy.html"><code>maxBy</code></a> · <a href="minBy.html"><code>minBy</code></a> — the rest of the family
  </div>
