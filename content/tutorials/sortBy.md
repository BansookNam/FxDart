---
slug: sortBy
title: sortBy — FxDart 101
description: FxDart sortBy tutorial: sort by an extracted key, ascending, always a new list, with a live playground.
heading: <code>sortBy</code>
section: 7
crumb: sortBy
prev: sort.html
prevLabel: sort
next: partition.html
nextLabel: partition
---
  <p class="hero-sub">Sorts ascending by a key you extract, instead of writing a comparator by hand.</p>

  {{signature}}

  <h2>Lecture</h2>
  <p>
    <code>sortBy</code> is <code><a href="sort.html">sort</a></code>'s
    convenience sibling: instead of writing
    <code>(a, b) =&gt; a.age.compareTo(b.age)</code> yourself, you give
    <code>sortBy</code> a key extractor — <code>(a) =&gt; a['age']</code> —
    and it builds the comparator for you, always ascending, always
    comparing the extracted keys with <code>Comparable.compare</code>. Under
    the hood it's literally <code>sort((a, b) =&gt; compare(f(a), f(b)), iterable)</code>.
  </p>
  <p>
    Every guarantee from <code>sort</code> carries over unchanged: the
    result is always a <strong>new</strong> list, never a mutation of the
    input. And the same chain-form nuance applies too — on the sync
    <code>Fx</code> chain, <code>.sortBy(f)</code> returns another
    <code>Fx&lt;T&gt;</code>, so you still need
    <code><a href="../101/index.html">.toList()</a></code> to materialize
    it, while on the <code>FxAsync</code> chain, <code>.sortBy(f)</code> is
    already a terminal returning <code>Future&lt;List&lt;T&gt;&gt;</code>.
  </p>
  <p>
    If you need descending order, or a multi-key sort, drop back down to
    <code>sort</code> with an explicit comparator — <code>sortBy</code> only
    covers the common "ascending by one extracted key" case.
  </p>

  <h2>Demo 1 · Basics</h2>
  {{playground:0}}

  <h2>Demo 2 · Async — already a terminal</h2>
  {{playground:1}}

  <h2>Try it yourself</h2>
  <p>Exercise: sort the people <strong>by age</strong>, youngest first.</p>
  {{playground:2}}

  <div class="callout">
    <strong>Related:</strong>
    <a href="sort.html"><code>sort</code></a> — the comparator-based form this builds on ·
    <a href="min.html"><code>min</code></a> · <a href="max.html"><code>max</code></a> — for a single extreme instead of a full ranking ·
    <a href="pluck.html"><code>pluck</code></a> — extract the same key without sorting
  </div>
