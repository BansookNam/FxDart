---
slug: sumByDouble
title: sumByDouble — FxDart 101
description: FxDart sumByDouble and sumByInt tutorial: sum a selector with the result already typed as double or int, sync and async, with a live playground.
heading: <code>sumByDouble</code> · <code>sumByInt</code>
section: 7
crumb: sumByDouble
prev: sumBy.html
prevLabel: sumBy
next: product.html
nextLabel: product
---
  <p class="hero-sub"><code>sumBy</code> with the result already typed: a <code>double</code> or an <code>int</code>, no cast.</p>

  {{signature}}

  <h2>Lecture</h2>
  <p>
    <code><a href="sumBy.html">sumBy</a></code> returns <code>num</code>,
    because its selector may return either kind of number. That is right
    for a mixed column and a nuisance for a typed one: a gold rate stored in
    a <code>double</code> field, or a count stored in an <code>int</code>,
    needs <code>.toDouble()</code> or <code>.toInt()</code> after every
    sum. <code>sumByDouble(f)</code> and <code>sumByInt(f)</code> take a
    selector that already returns that type and give it back unchanged.
  </p>
  <p>
    They also do slightly less work. <code>sumBy</code> keeps an
    <code>int</code> accumulator and switches to a <code>double</code> the
    first time a non-integer arrives, which costs a type test per element;
    these two start in the right accumulator and add. The addition order is
    the same left-to-right walk, so <code>sumByDouble</code> rounds exactly
    as <code>sumBy</code> does. Empty input returns <code>0.0</code> and
    <code>0</code>, keeping the type.
  </p>
  <p>
    fxdart extension (not part of FxTS). Three camelCase words, so by the
    naming rule there is no <code>fx</code> prefix on the top-level form.
  </p>

  <h2>Demo 1 · No cast</h2>
  {{playground:0}}

  <h2>Demo 2 · Empty input and async</h2>
  {{playground:1}}

  <h2>Try it yourself</h2>
  <p>Exercise: drop both casts by using the typed sums.</p>
  {{playground:2}}

  <div class="callout">
    <strong>Related:</strong>
    <a href="sumBy.html"><code>sumBy</code></a> — the <code>num</code> form for mixed columns ·
    <a href="sum.html"><code>sum</code></a> — the numbers themselves ·
    <a href="averageBy.html"><code>averageBy</code></a> — the mean of a selector
  </div>
