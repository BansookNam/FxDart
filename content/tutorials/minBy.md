---
slug: minBy
title: minBy — FxDart 101
description: FxDart minBy tutorial: the element with the smallest key in one walk — no sort, null when empty — with a live playground.
heading: <code>minBy</code>
section: 7
crumb: minBy
prev: maxBy.html
prevLabel: maxBy
next: size.html
nextLabel: count
---
  <p class="hero-sub">The element whose key is smallest — one walk, no sort, <code>null</code> when empty.</p>

  {{signature}}

  <h2>Lecture</h2>
  <p>
    <code>minBy</code> is the mirror of
    <code><a href="maxBy.html">maxBy</a></code>: it returns the
    <em>element</em> with the smallest key after a single O(n) walk,
    where <code>sortBy(key).head()</code> would sort the whole pipeline
    just to read one value.
  </p>
  <p>
    The contract matches <code>maxBy</code> exactly: keys compare like
    <code><a href="sortBy.html">sortBy</a></code>
    (<code>Comparable.compare</code>), ties keep the <strong>first</strong>
    element encountered, and an empty pipeline returns <code>null</code> —
    not <code>infinity</code>, which is what the numeric
    <code><a href="min.html">min</a></code> does, because there is no
    "zero element" to fall back to.
  </p>

  <h2>Demo 1 · Basics, empty case &amp; ties</h2>
  {{playground:0}}

  <h2>Demo 2 · Async</h2>
  {{playground:1}}

  <h2>Try it yourself</h2>
  <p>Exercise: find the fastest runner with one call.</p>
  {{playground:2}}

  <div class="callout">
    <strong>Related:</strong>
    <a href="maxBy.html"><code>maxBy</code></a> — the mirror image ·
    <a href="min.html"><code>min</code></a> — when you want the key itself, not the element ·
    <a href="head.html"><code>head</code></a> — the same nullable contract
  </div>
