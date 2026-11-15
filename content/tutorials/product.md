---
slug: product
title: product — FxDart 101
description: FxDart product and productBy tutorial: multiply every number (or a key of every element), with 1 for empty input and ints kept as ints, sync and async, with a live playground.
heading: <code>fxProduct</code> · <code>fxProductBy</code>
section: 7
crumb: product
prev: sumByDouble.html
prevLabel: sumByDouble
next: average.html
nextLabel: average
---
  <p class="hero-sub">The multiplying sibling of <code>sum</code> — and an empty input is <code>1</code>, not <code>0</code>.</p>

  {{signature}}

  <h2>Lecture</h2>
  <p>
    <code>fxProduct(xs)</code> multiplies every number in the iterable;
    <code>fxProductBy(f, xs)</code> multiplies a numeric key of every
    element — <code>map</code> + <code>product</code> in one pass, the
    counterpart of <code><a href="sumBy.html">sumBy</a></code>. Both are
    terminal: they pull the whole input and return one <code>num</code>.
  </p>
  <p>
    Empty input returns <strong><code>1</code></strong>, the multiplicative
    identity, for the same reason <code>sum</code> of nothing is
    <code>0</code>: it is the only value that keeps
    <code>product(xs + ys) == product(xs) * product(ys)</code> true when
    one side is empty. If <code>0</code> came back, splitting a batch into
    chunks would zero out every total that had an empty chunk.
  </p>
  <p>
    The accumulation follows <code>sum</code>: while every value is an
    <code>int</code> the result is an <code>int</code>; the first
    <code>double</code> switches it to <code>double</code> seeded with the
    running total — exactly what a boxed <code>num acc *= v</code> would
    hold. On the chain they are <code>fx(numbers).product()</code> and
    <code>fx(items).productBy(f)</code>, and the async twins
    (<code>fxProductAsync</code>, <code>fxProductByAsync</code>, and the
    same names on <code>FxAsync</code>) accept a key function that returns a
    <code>Future</code>. fxdart extension (FxTS has <code>sum</code> but no
    <code>product</code>).
  </p>

  <h2>Demo 1 · Basics, empty input &amp; int vs double</h2>
  {{playground:0}}

  <h2>Demo 2 · productBy and async</h2>
  {{playground:1}}

  <h2>Try it yourself</h2>
  <p>Exercise: replace the multiplying loop with one call.</p>
  {{playground:2}}

  <div class="callout">
    <strong>Related:</strong>
    <a href="sum.html"><code>sum</code></a> · <a href="sumBy.html"><code>sumBy</code></a> — the additive pair, empty is <code>0</code> ·
    <a href="fold.html"><code>fold</code></a> — any other accumulation, with your own seed ·
    <a href="average.html"><code>average</code></a> — the next numeric aggregate
  </div>
