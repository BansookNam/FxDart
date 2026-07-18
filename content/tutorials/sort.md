---
slug: sort
title: sort — FxDart 101
description: FxDart sort tutorial: comparator-based sorting that always returns a new list, never mutates, with a live playground.
heading: <code>sort</code>
section: 7
crumb: sort
prev: countBy.html
prevLabel: countBy
next: sortBy.html
nextLabel: sortBy
---
  <p class="hero-sub">Returns a brand-new sorted list from a comparator — it never mutates its input.</p>

  {{signature}}

  <h2>Lecture</h2>
  <p>
    <code>sort</code> takes a standard Dart comparator — return negative if
    <code>a</code> should come before <code>b</code>, positive if after, zero
    if tied — and produces a sorted result. The important difference from
    JavaScript's (and FxTS's) <code>Array.prototype.sort</code> is that
    FxDart's <code>sort</code> <strong>never mutates its input</strong>. It
    always allocates a new <code>List</code> (<code>List.of(iterable)..sort(f)</code>),
    leaving the original iterable exactly as it was. FxTS later added
    <code>toSorted</code> as the non-mutating alternative to its mutating
    <code>sort</code>; in FxDart, <code>toSorted</code> is simply an alias —
    since <code>sort</code> was already non-mutating, there was nothing left
    to differentiate.
  </p>
  <p>
    There's a nuance on the <strong>chain</strong> form worth calling out
    explicitly: on the sync <code>Fx</code> chain, <code>.sort(f)</code>
    returns another <code>Fx&lt;T&gt;</code> — not a <code>List&lt;T&gt;</code> —
    because <code>Fx</code> wraps its underlying sorted list to stay
    chainable. You still need a terminal like
    <code><a href="../101/index.html">.toArray()</a></code> to get a
    concrete <code>List</code> out of it. The <strong>async</strong> chain
    doesn't have that wrinkle: <code>FxAsync.sort(f)</code> is already a
    terminal that returns <code>Future&lt;List&lt;T&gt;&gt;</code> directly,
    because <code>FxAsync</code> can't return itself from something that
    needs to <code>await</code> the whole pipeline first.
  </p>
  <p>
    Reach for <code><a href="sortBy.html">sortBy</a></code> instead when you
    just want to sort by a key you extract, rather than writing the
    comparator yourself.
  </p>

  <h2>Demo 1 · Basics, no mutation, and toSorted</h2>
  {{playground:0}}

  <h2>Demo 2 · Async — already a terminal</h2>
  {{playground:1}}

  <h2>Try it yourself</h2>
  <p>Exercise: sort the numbers in <strong>descending</strong> order.</p>
  {{playground:2}}

  <div class="callout">
    <strong>Related:</strong>
    <a href="sortBy.html"><code>sortBy</code></a> — sort by an extracted key instead of a comparator ·
    <a href="reverse.html"><code>reverse</code></a> — flip element order without comparing ·
    <a href="partition.html"><code>partition</code></a> — split into two lists by a predicate
  </div>
