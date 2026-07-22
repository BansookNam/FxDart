---
slug: average
title: average — FxDart 101
description: FxDart average tutorial: the mean of every number in a pipeline, NaN when empty, with a live playground.
heading: <code>average</code>
section: 7
crumb: average
prev: sumBy.html
prevLabel: sumBy
next: averageBy.html
nextLabel: averageBy
---
  <p class="hero-sub">The mean of every number the pipeline produces — <code>NaN</code> when there are none.</p>

  {{signature}}

  <h2>Lecture</h2>
  <p>
    <code>average</code> is a terminal operator that walks the whole
    pipeline once, tracking both a running total and a running count, then
    divides. It always returns a <code>double</code>, even for a list of
    plain <code>int</code>s.
  </p>
  <p>
    The one behavior worth internalizing: <code>average</code> of an
    <strong>empty</strong> iterable is <code>double.nan</code> — it's
    computing <code>0 / 0</code>, not throwing and not defaulting to
    <code>0</code>. This mirrors FxTS exactly. If your pipeline might be
    empty, check for that explicitly (<code>result.isNaN</code>) rather than
    assuming a numeric fallback.
  </p>
  <p>
    Like <code><a href="sum.html">sum</a></code>, the chain form is exposed
    through a <code>Fx&lt;num&gt;</code> / <code>FxAsync&lt;num&gt;</code>
    extension, so it only becomes available once the compiler can see your
    chain's element type is numeric.
  </p>

  <h2>Demo 1 · Basics &amp; the empty case</h2>
  {{playground:0}}

  <h2>Demo 2 · Async</h2>
  {{playground:1}}

  <h2>Try it yourself</h2>
  <p>Exercise: average only the <strong>passing</strong> scores (&gt;= 60).</p>
  {{playground:2}}

  <div class="callout">
    <strong>Related:</strong>
    <a href="sum.html"><code>sum</code></a> — the numerator this divides ·
    <a href="size.html"><code>size</code></a> — the denominator this divides by ·
    <a href="min.html"><code>min</code></a> · <a href="max.html"><code>max</code></a> — the other numeric terminals
  </div>
