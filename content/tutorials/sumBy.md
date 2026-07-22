---
slug: sumBy
title: sumBy — FxDart 101
description: FxDart sumBy tutorial: sum a key of every element — map + sum in one step — with a live playground.
heading: <code>sumBy</code>
section: 7
crumb: sumBy
prev: sum.html
prevLabel: sum
next: average.html
nextLabel: average
---
  <p class="hero-sub">Sum a key of every element — <code>map</code> + <code>sum</code> in one step, <code>0</code> when empty.</p>

  {{signature}}

  <h2>Lecture</h2>
  <p>
    <code>sumBy</code> collapses the most common two-stage tail in data
    pipelines — <code>.map((x) =&gt; x.field).sum()</code> — into a single
    terminal. It folds a running total while extracting the key, so nothing
    intermediate is materialized and the intent ("total this field") is one
    call instead of a projection plus an aggregation.
  </p>
  <p>
    The contract is <code><a href="sum.html">sum</a></code>'s: an empty
    pipeline totals to <code>0</code>, and int keys keep int arithmetic
    while any double key promotes the total to <code>double</code>.
  </p>
  <p>
    This is a Dart-native addition (FxTS ships only the numeric
    <code>sum</code>), in the same family as
    <code><a href="maxBy.html">maxBy</a></code> /
    <code><a href="minBy.html">minBy</a></code> — Kotlin spells it
    <code>sumOf</code>.
  </p>

  <h2>Demo 1 · Basics &amp; the empty case</h2>
  {{playground:0}}

  <h2>Demo 2 · Async keys</h2>
  {{playground:1}}

  <h2>Try it yourself</h2>
  <p>Exercise: total the long words' lengths with one call.</p>
  {{playground:2}}

  <div class="callout">
    <strong>Related:</strong>
    <a href="sum.html"><code>sum</code></a> — when the pipeline already holds numbers ·
    <a href="maxBy.html"><code>maxBy</code></a> · <a href="minBy.html"><code>minBy</code></a> — the same by-key family ·
    <a href="fold.html"><code>fold</code></a> — the general shape this specializes
  </div>
