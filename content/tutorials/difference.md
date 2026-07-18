---
slug: difference
title: difference — FxDart 101
description: FxDart difference tutorial: elements of one iterable that don't occur in another, with a live playground.
heading: <code>difference</code>
section: 4
crumb: difference
prev: uniqBy.html
prevLabel: uniqBy
next: differenceBy.html
nextLabel: differenceBy
---
  <p class="hero-sub">Returns the elements of the second iterable that do not occur in the first — argument order matters.</p>

  {{signature}}

  <h2>Lecture</h2>
  <p>
    Read the signature carefully: <code>difference(iterable1, iterable2)</code>
    walks <strong><code>iterable2</code></strong> and yields each of its
    elements that is <em>not</em> found in <code>iterable1</code>
    (deduplicated, like <code>uniq</code>). <code>iterable1</code> is only
    ever used as a membership set to test against — none of its own
    elements can appear in the output, and its own duplicates don't matter.
    This order is not symmetric: swapping the arguments produces a
    completely different (and generally different-length) result. A useful
    way to remember it: think of <code>iterable1</code> as "the exclusion
    list" and <code>iterable2</code> as "the list you're filtering."
  </p>
  <p>
    Internally it's <code>differenceBy((a) =&gt; a, iterable1, iterable2)</code> —
    see <a href="differenceBy.html"><code>differenceBy</code></a> if you
    need to compare by a computed key instead of value equality.
  </p>
  <p>
    There's no chain method for <code>difference</code>; it only exists as
    a data-first function (and its async counterpart). On the async side,
    the concurrency marker from <code>.concurrent(n)</code> applies to
    <strong><code>iterable2</code></strong> — the exclusion set in
    <code>iterable1</code> is always drained up front before results start
    flowing.
  </p>

  <h2>Demo 1 · Basics &amp; argument order</h2>
  {{playground:0}}

  <h2>Demo 2 · Async, with concurrency</h2>
  {{playground:1}}

  <h2>Try it yourself</h2>
  <p>Exercise: use <code>difference</code> to find the tasks in
    <code>allTasks</code> that are not yet in <code>completed</code>.</p>
  {{playground:2}}

  <div class="callout">
    <strong>Related:</strong>
    <a href="differenceBy.html"><code>differenceBy</code></a> — the same, by a computed key ·
    <a href="intersection.html"><code>intersection</code></a> — keep the shared elements instead ·
    <a href="uniq.html"><code>uniq</code></a> — dedupe a single iterable ·
    <a href="../tutorials/includes.html"><code>includes</code></a> — test membership in a single iterable
  </div>
