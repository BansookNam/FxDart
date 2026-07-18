---
slug: partition
title: partition — FxDart 101
description: FxDart partition tutorial: split a pipeline into a (pass, fail) record by a predicate, with a live playground.
heading: <code>partition</code>
section: 7
crumb: partition
prev: sortBy.html
prevLabel: sortBy
next: head.html
nextLabel: head
---
  <p class="hero-sub">Splits a pipeline into two lists at once, by a single predicate.</p>

  {{signature}}

  <h2>Lecture</h2>
  <p>
    <code>partition</code> is a terminal operator that walks the pipeline
    once and sorts every element into one of two lists based on a predicate:
    elements the predicate returns <code>true</code> for go into the first
    list, everything else into the second. It's equivalent to calling
    <code><a href="filter.html">filter</a></code> and
    <code><a href="reject.html">reject</a></code> separately, but in a single
    pass over the data.
  </p>
  <p>
    FxTS returns a two-element tuple, <code>[pass, fail]</code>. Dart has no
    tuple type built into JS-style arrays, so FxDart uses a native Dart
    <strong>record</strong>: <code>(List&lt;A&gt;, List&lt;A&gt;)</code>. Access
    the two lists with <code>.$1</code> (pass) and <code>.$2</code> (fail),
    or destructure them directly with pattern-matching syntax:
    <code>final (pass, fail) = partition(f, iterable);</code>. This is the
    same tuple-to-record convention used by
    <code><a href="zip.html">zip</a></code> and
    <code><a href="entries.html">entries</a></code> elsewhere in FxDart.
  </p>
  <p>
    As with every terminal in this section, it pulls the whole lazy pipeline
    upstream of it, sync or async.
  </p>

  <h2>Demo 1 · Basics &amp; destructuring</h2>
  {{playground:0}}

  <h2>Demo 2 · Async</h2>
  {{playground:1}}

  <h2>Try it yourself</h2>
  <p>Exercise: partition the scores into <strong>pass</strong> (&gt;= 60) and <strong>fail</strong> (&lt; 60).</p>
  {{playground:2}}

  <div class="callout">
    <strong>Related:</strong>
    <a href="filter.html"><code>filter</code></a> · <a href="reject.html"><code>reject</code></a> — the two halves partition combines ·
    <a href="groupBy.html"><code>groupBy</code></a> — grouping into more than two buckets ·
    <a href="sort.html"><code>sort</code></a> — order within each side, if you need it
  </div>
