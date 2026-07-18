---
slug: intersection
title: intersection — FxDart 101
description: FxDart intersection tutorial: elements of one iterable also found in another, with a live playground.
heading: <code>intersection</code>
section: 4
crumb: intersection
prev: differenceBy.html
prevLabel: differenceBy
next: intersectionBy.html
nextLabel: intersectionBy
---
  <p class="hero-sub"><code>difference</code>'s opposite: elements of the second iterable that ARE also found in the first.</p>

  {{signature}}

  <h2>Lecture</h2>
  <p>
    <code>intersection(iterable1, iterable2)</code> shares
    <code>difference</code>'s argument-order convention: the result walks
    <strong><code>iterable2</code></strong>, and keeps each element (in
    <code>iterable2</code>'s order, deduplicated) that <em>is</em> found in
    <code>iterable1</code>. <code>iterable1</code> is only ever used as a
    membership set — swap the two arguments and you get the same
    <em>values</em> in a set-theory sense, but the actual order (and which
    collection's duplicates get collapsed) is different, since the source
    of the yielded elements changes. See Demo 1.
  </p>
  <p>
    Under the hood it's
    <code>intersectionBy((a) =&gt; a, iterable1, iterable2)</code> — reach
    for <a href="intersectionBy.html"><code>intersectionBy</code></a>
    directly when you need to match by a computed key across two lists of
    full records rather than by value equality.
  </p>
  <p>
    There's no chain method; call the data-first function. On the async
    side, the concurrency marker from <code>.concurrent(n)</code> applies to
    <code>iterable2</code> — <code>iterable1</code> is drained up front to
    build the membership set.
  </p>

  <h2>Demo 1 · Basics &amp; argument order</h2>
  {{playground:0}}

  <h2>Demo 2 · Async, with concurrency</h2>
  {{playground:1}}

  <h2>Try it yourself</h2>
  <p>Exercise: use <code>intersection</code> to find which of the
    candidate's skills are actually required.</p>
  {{playground:2}}

  <div class="callout">
    <strong>Related:</strong>
    <a href="difference.html"><code>difference</code></a> — the exclusion counterpart ·
    <a href="intersectionBy.html"><code>intersectionBy</code></a> — match by a computed key instead ·
    <a href="uniq.html"><code>uniq</code></a> — dedupe a single iterable ·
    <a href="../tutorials/includes.html"><code>includes</code></a> — test membership of a single value
  </div>
