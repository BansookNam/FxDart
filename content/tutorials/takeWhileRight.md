---
slug: takeWhileRight
title: takeWhileRight — FxDart 101
description: FxDart takeWhileRight tutorial: keep the longest trailing run that satisfies a predicate, in source order, with a live playground.
heading: <code>takeWhileRight</code>
section: 5
crumb: takeWhileRight
prev: takeWhile.html
prevLabel: takeWhile
next: takeUntilInclusive.html
nextLabel: takeUntilInclusive
---
  <p class="hero-sub">Keeps the longest run at the <em>end</em> of a source where a predicate holds, in source order.</p>

  {{signature}}

  <h2>Lecture</h2>
  <p>
    <a href="takeRight.html"><code>takeRight</code></a> takes the last
    <em>n</em> elements; <code>takeWhileRight</code> takes the last elements
    that <em>match</em>, however many that turns out to be. It is to
    <code>takeRight</code> what <a href="takeWhile.html"><code>takeWhile</code></a>
    is to <a href="take.html"><code>take</code></a> — a predicate where the
    other wanted a count.
  </p>
  <p>
    Only a run that reaches the very end counts. If the last element already
    fails, the result is empty no matter how long a matching run sat just
    before it. That is what makes it a suffix operator rather than a
    "longest match anywhere" search.
  </p>
  <p>
    The result comes back in <strong>source order</strong>, not reversed, so
    it chains with everything else in the library and lines up with
    <a href="dropWhileRight.html"><code>dropWhileRight</code></a> — together
    the two split a source in half with nothing lost or repeated.
  </p>
  <p>
    Nothing can be emitted before the source ends: until the last element has
    arrived, no element is known to belong to the suffix. Over a
    <code>List</code> the trailing run is found by walking backwards from the
    end, so the predicate only ever sees that run; over any other source
    every element is tested in order and the current run is buffered. Keep
    the predicate pure and the difference will not reach you.
  </p>

  <h2>Demo 1 · Basics</h2>
  {{playground:0}}

  <h2>Demo 2 · Async, and the split</h2>
  {{playground:1}}

  <h2>Try it yourself</h2>
  <p>Exercise: keep only the trailing run of readings at or above 30.</p>
  {{playground:2}}

  <div class="callout">
    <strong>Related:</strong>
    <a href="dropWhileRight.html"><code>dropWhileRight</code></a> — the complement: drop that same run ·
    <a href="takeRight.html"><code>takeRight</code></a> — a trailing slice by count ·
    <a href="takeWhile.html"><code>takeWhile</code></a> — the same idea from the front ·
    <a href="filter.html"><code>filter</code></a> — matches anywhere, not just at the end
  </div>
