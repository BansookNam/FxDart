---
slug: sortByDesc
title: sortByDesc — FxDart 101
description: FxDart sortByDesc tutorial: sort by any comparable key, descending — no numeric negation trick — with a live playground.
heading: <code>sortByDesc</code>
section: 7
crumb: sortByDesc
prev: sortBy.html
prevLabel: sortBy
next: partition.html
nextLabel: partition
---
  <p class="hero-sub">Sort by any comparable key, descending — the negation trick, retired.</p>

  {{signature}}

  <h2>Lecture</h2>
  <p>
    Rankings want their biggest value first, and until now the only
    one-liner was <code>sortBy((a)&nbsp;=&gt;&nbsp;-key)</code> — a trick
    that works <em>only for numbers</em>. Dates, strings, and every other
    <code>Comparable</code> have no minus sign. <code>sortByDesc</code> is
    <code><a href="sortBy.html">sortBy</a></code> with the comparison
    swapped: same key extraction (each key computed exactly once), same
    unboxed fast paths for <code>double</code>/<code>int</code>/<code>String</code>
    keys, same never-mutates-the-input contract.
  </p>
  <p>
    The classic shape it replaces is the "top N" ranking:
    <code>sortByDesc(key).take(n)</code> reads as written, where the
    ascending spelling needed the negation <em>and</em> a comment
    explaining it. For "newest first" over dates it is the only direct
    spelling at all.
  </p>
  <p>
    Dart-native addition — the name follows Kotlin's
    <code>sortedByDescending</code>. When you need the single largest
    element rather than the full ordering, skip the sort entirely:
    <code><a href="maxBy.html">maxBy</a></code> is O(n).
  </p>

  <h2>Demo 1 · Rankings without negation</h2>
  {{playground:0}}

  <h2>Demo 2 · Keys numbers can't fake</h2>
  {{playground:1}}

  <h2>Try it yourself</h2>
  <p>Exercise: newest-first without negating anything.</p>
  {{playground:2}}

  <div class="callout">
    <strong>Related:</strong>
    <a href="sortBy.html"><code>sortBy</code></a> — ascending twin ·
    <a href="maxBy.html"><code>maxBy</code></a> — one walk when only the top element matters ·
    <a href="take.html"><code>take</code></a> — the second half of every "top N"
  </div>
