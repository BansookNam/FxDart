---
slug: nth
title: nth — FxDart 101
description: FxDart nth tutorial: safely pull the element at an index, null on out-of-range, with a live playground.
heading: <code>nth</code>
section: 8
crumb: nth
prev: last.html
prevLabel: last
next: find.html
nextLabel: find
---
  <p class="hero-sub">Returns the element at a given index, or <code>null</code> when the index is out of range.</p>

  {{signature}}

  <h2>Lecture</h2>
  <p>
    <code>nth</code> walks the iterable and stops as soon as it reaches
    <code>index</code>, so it only ever pulls <code>index + 1</code>
    elements — cheap even on a huge lazy sequence, and much cheaper than
    materializing the whole thing just to index into a <code>List</code>.
    A negative index, or one past the end, simply yields <code>null</code>;
    unlike some languages' array indexing, there's no wraparound-from-the-end
    behavior here — the index has to be a valid, non-negative position.
  </p>
  <p>
    There's no chain method for <code>nth</code> — call the top-level
    function (or its async twin) directly on any <code>Iterable</code> or
    <code>Fx</code> chain, since <code>Fx</code> <em>is</em> an
    <code>Iterable</code>.
  </p>

  <h2>Demo 1 · Basics</h2>
  {{playground:0}}

  <h2>Demo 2 · Laziness &amp; async</h2>
  <p>Fetching index 3 only pulls 4 elements from the million-element range — proven with a <code>peek</code> counter:</p>
  {{playground:1}}

  <h2>Try it yourself</h2>
  <p>Exercise: use <code>nth</code> to print the silver medalist (index 1), or <code>'unclaimed'</code>.</p>
  {{playground:2}}

  <div class="callout">
    <strong>Related:</strong>
    <a href="head.html"><code>head</code></a> — shorthand for <code>nth(0, ...)</code> ·
    <a href="last.html"><code>last</code></a> — the final element ·
    <a href="find.html"><code>find</code></a> — locate by predicate instead of index ·
    <a href="slice.html"><code>slice</code></a> — pull a whole range
  </div>
