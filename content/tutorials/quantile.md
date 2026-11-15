---
slug: quantile
title: quantile — FxDart 101
description: FxDart quantile and quantileBy tutorial: a median or percentile by quickselect in O(n), without sorting the whole input, with a live playground.
heading: <code>fxQuantile</code> · <code>fxQuantileBy</code>
section: 7
crumb: quantile
prev: minBy.html
prevLabel: minBy
next: topBy.html
nextLabel: topBy
---
  <p class="hero-sub">The median, a p95, or any percentile — found in linear time, without sorting everything.</p>

  {{signature}}

  <h2>Lecture</h2>
  <p>
    The usual way to read a percentile is to sort a copy and index it:
    <code>sorted[((n - 1) * q).round()]</code>. That is
    <code>O(n log n)</code> to read one position.
    <code>fxQuantile(q, xs)</code> returns the same value by
    <strong>quickselect</strong>, which only partitions until that one
    position is settled — <code>O(n)</code> on average, and median-of-three
    pivots keep already-sorted and reversed input, the common real shapes,
    linear too. The input is never reordered; the work happens on a copy.
  </p>
  <p>
    The rank is <em>nearest rank</em>: the value at index
    <code>((n - 1) * q).round()</code> of the sorted input. So
    <code>q = 0</code> is the minimum, <code>1</code> the maximum and
    <code>0.5</code> the median — the upper of the two middle values when
    the length is even. Nothing is interpolated: the answer is always one of
    the inputs. Empty input returns <code>null</code>; a <code>q</code>
    outside <code>[0, 1]</code> throws <code>ArgumentError</code>.
  </p>
  <p>
    <code>fxQuantileBy(q, f, xs)</code> ranks by a numeric key and returns
    the <em>element</em> — the median-priced product, not the median price.
    <code>f</code> runs once per element. On the chain they are
    <code>fx(numbers).quantile(q)</code> and
    <code>fx(items).quantileBy(q, f)</code>. fxdart extension (not part of
    FxTS).
  </p>

  <h2>Demo 1 · Median and percentiles</h2>
  {{playground:0}}

  <h2>Demo 2 · quantileBy returns the element</h2>
  {{playground:1}}

  <h2>Try it yourself</h2>
  <p>Exercise: replace the sort-and-index with one call.</p>
  {{playground:2}}

  <div class="callout">
    <strong>Related:</strong>
    <a href="minBy.html"><code>minBy</code></a> · <a href="maxBy.html"><code>maxBy</code></a> — the two ends, in one walk ·
    <a href="sortBy.html"><code>sortBy</code></a> — when you need the whole order ·
    <a href="averageBy.html"><code>averageBy</code></a> — the mean instead of the median
  </div>
