---
slug: min
title: min — FxDart 101
description: FxDart min tutorial: the smallest number in a pipeline, +infinity when empty, NaN-poisoned, with a live playground.
heading: <code>min</code>
section: 7
crumb: min
prev: average.html
prevLabel: average
next: max.html
nextLabel: max
---
  <p class="hero-sub">The smallest number in the pipeline — with FxTS's exact quirks on empty and <code>NaN</code> input.</p>

  {{signature}}

  <h2>Lecture</h2>
  <p>
    <code>min</code> is a terminal, numeric-only fold — internally it's
    <code>fold(double.infinity, ..., iterable)</code>, comparing each element
    against a running minimum that starts at <code>+infinity</code>.
  </p>
  <p>
    Two behaviors are worth memorizing, because they surprise people coming
    from a "safe" API and are ported <strong>faithfully from FxTS</strong>:
  </p>
  <ul>
    <li>
      An <strong>empty</strong> iterable returns <code>double.infinity</code>
      — not <code>null</code>, not an error. That's simply what the fold seed
      is when nothing ever beats it.
    </li>
    <li>
      A single <code>NaN</code> anywhere in the iterable
      <strong>poisons</strong> the whole result to <code>NaN</code> — every
      comparison against <code>NaN</code> is false, so once it's the running
      minimum (or shows up as a candidate), it stays <code>NaN</code> forever.
    </li>
  </ul>
  <p>
    If you need "smallest, or <code>null</code> if empty" semantics instead,
    check <code>result.isInfinite</code> yourself, or reach for
    <code><a href="find.html">find</a></code> /
    <code><a href="reduce.html">reduce</a></code> with your own comparator.
  </p>

  <h2>Demo 1 · Basics, empty, and NaN</h2>
  {{playground:0}}

  <h2>Demo 2 · Async</h2>
  {{playground:1}}

  <h2>Try it yourself</h2>
  <p>Exercise: find the <strong>cheapest</strong> price among the products.</p>
  {{playground:2}}

  <div class="callout">
    <strong>Related:</strong>
    <a href="max.html"><code>max</code></a> — the mirror image ·
    <a href="sum.html"><code>sum</code></a> · <a href="average.html"><code>average</code></a> — the other numeric terminals ·
    <a href="find.html"><code>find</code></a> — for a null-safe "smallest matching" search
  </div>
