---
slug: topBy
title: topBy — FxDart 101
description: FxDart topBy and bottomBy tutorial: the k largest or smallest elements by key in one pass, ordered, ties won by the first seen — instead of sorting everything and taking k, with a live playground.
heading: <code>fxTopBy</code> · <code>fxBottomBy</code>
section: 7
crumb: topBy
prev: quantile.html
prevLabel: quantile
next: size.html
nextLabel: count
---
  <p class="hero-sub">The top 3, the 5 cheapest — in one pass, already in order, without sorting the rest.</p>

  {{signature}}

  <h2>Lecture</h2>
  <p>
    The usual way to read a leaderboard is
    <code>sortByDesc(f, xs).take(k)</code>: sort the whole input, keep
    <code>k</code>, throw the rest away. <code>fxTopBy(k, f, xs)</code>
    returns the same <code>k</code> elements from <strong>one pass</strong>
    that keeps only a <code>k</code>-sized boundary — memory is
    proportional to <code>k</code>, not to the input, and nothing outside
    the boundary is retained. <code>fxBottomBy(k, f, xs)</code> is the
    mirror image: the <code>k</code> smallest keys, smallest first.
  </p>
  <p>
    The result needs no second pass. It is <strong>ordered</strong> —
    descending for <code>topBy</code>, ascending for
    <code>bottomBy</code> — and a <strong>tie is won by the element seen
    first</strong>: a later element whose key only equals the weakest kept
    key does not displace it, and equal keys inside the result keep their
    input order. <code>k &lt;= 0</code> returns an empty list; a
    <code>k</code> past the end returns every element, ordered. Keys are
    compared exactly as <code><a href="sortBy.html">sortBy</a></code>
    compares them, so any <code>Comparable</code> works.
  </p>
  <p>
    The boundary is kept by insertion, so the worst case is
    <code>O(n·k)</code>: this is for a small <code>k</code> over a large
    input; when <code>k</code> approaches the input length, sort instead.
    On the sync chain <code>fx(xs).topBy(k, f)</code> is a
    <em>step</em> — it returns an <code>Fx</code>, so you can keep
    chaining — while <code>FxAsync.topBy</code> and the
    <code>fxTopByAsync</code> twins end the chain with a
    <code>Future&lt;List&gt;</code>; their key function stays synchronous.
    fxdart extension (not part of FxTS) — the shape of Python's
    <code>heapq.nlargest</code>.
  </p>

  <h2>Demo 1 · Order, ties &amp; k</h2>
  {{playground:0}}

  <h2>Demo 2 · On the chain, sync and async</h2>
  {{playground:1}}

  <h2>Try it yourself</h2>
  <p>Exercise: replace the sort-and-take with one call.</p>
  {{playground:2}}

  <div class="callout">
    <strong>Related:</strong>
    <a href="sortByDesc.html"><code>sortByDesc</code></a> — when you need the whole order ·
    <a href="maxBy.html"><code>maxBy</code></a> · <a href="minBy.html"><code>minBy</code></a> — when <code>k</code> is 1 ·
    <a href="quantile.html"><code>quantile</code></a> — one position, not the first <code>k</code>
  </div>
