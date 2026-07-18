---
slug: uniqBy
title: uniqBy — FxDart 101
description: FxDart uniqBy tutorial: remove duplicates by a computed key, with a live playground.
heading: <code>uniqBy</code>
section: 4
crumb: uniqBy
prev: uniq.html
prevLabel: uniq
next: difference.html
nextLabel: difference
---
  <p class="hero-sub">Removes duplicates as determined by a key function, rather than value equality.</p>

  {{signature}}

  <h2>Lecture</h2>
  <p>
    <code>uniqBy</code> is <code>uniq</code>'s general form: instead of
    comparing whole elements, it runs each element through <code>f</code>
    and keeps only the first element to produce each distinct key. It's the
    tool for "one row per customer," "one event per type," or dedupe by any
    field or computed value — <code>uniq</code> itself is just
    <code>uniqBy((a) =&gt; a, iterable)</code>.
  </p>
  <p>
    As with <code>uniq</code>, it's lazy and order-preserving: the first
    element for each key wins, and the internal <code>Set&lt;B&gt;</code>
    of seen keys only grows as you pull.
  </p>
  <p>
    The same async rule applies here as with <code>uniq</code>: put the
    concurrency in an upstream fetch (<code>.map(...).concurrent(n)</code>),
    then apply <code>uniqBy</code>/<code>uniqByAsync</code> to the
    already-resolved, in-order stream.
  </p>

  <h2>Demo 1 · Basics</h2>
  {{playground:0}}

  <h2>Demo 2 · Async, with concurrency upstream</h2>
  {{playground:1}}

  <h2>Try it yourself</h2>
  <p>Exercise: use <code>uniqBy</code> to keep only the first event of each
    <code>'type'</code>.</p>
  {{playground:2}}

  <div class="callout">
    <strong>Related:</strong>
    <a href="uniq.html"><code>uniq</code></a> — dedupe by value equality ·
    <a href="differenceBy.html"><code>differenceBy</code></a> — remove by a computed key against another iterable ·
    <a href="intersectionBy.html"><code>intersectionBy</code></a> — keep by a computed key shared with another iterable ·
    <a href="../tutorials/groupBy.html"><code>groupBy</code></a> — keep every element, grouped by key
  </div>
