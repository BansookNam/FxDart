---
slug: uniq
title: uniq — FxDart 101
description: FxDart uniq tutorial: remove duplicate values while preserving first-seen order, with a live playground.
heading: <code>uniq</code>
section: 4
crumb: uniq
prev: compact.html
prevLabel: compact
next: uniqBy.html
nextLabel: uniqBy
---
  <p class="hero-sub">Removes duplicate values, keeping the first occurrence of each and preserving order.</p>

  {{signature}}

  <h2>Lecture</h2>
  <p>
    <code>uniq</code> walks the iterable once, keeping a <code>Set</code> of
    values already seen, and yields each element only the first time it
    shows up. It's implemented as <code>uniqBy((a) =&gt; a, iterable)</code> —
    the identity key — so if you ever need to dedupe by something other than
    equality of the whole value, reach for
    <a href="uniqBy.html"><code>uniqBy</code></a> instead.
  </p>
  <p>
    It's lazy and streaming: the <code>Set</code> only grows as elements are
    pulled, so it never buffers the whole source up front. Order is
    preserved — the first occurrence of a value is what survives, not the
    last.
  </p>
  <p>
    On the async side, <code>uniqAsync</code> is safe to combine with
    <code>.concurrent(n)</code> as long as the concurrency lives in an
    upstream fetch stage: fetch with <code>.map(...).concurrent(n)</code>
    first, then apply <code>.uniq()</code> to the already-resolved,
    in-order results, as in Demo 2.
  </p>

  <h2>Demo 1 · Basics</h2>
  {{playground:0}}

  <h2>Demo 2 · Async, with concurrency upstream</h2>
  {{playground:1}}

  <h2>Try it yourself</h2>
  <p>Exercise: use <code>uniq</code> to remove duplicate tags, preserving
    first-seen order.</p>
  {{playground:2}}

  <div class="callout">
    <strong>Related:</strong>
    <a href="uniqBy.html"><code>uniqBy</code></a> — dedupe by a computed key ·
    <a href="difference.html"><code>difference</code></a> — remove elements found in another iterable ·
    <a href="intersection.html"><code>intersection</code></a> — keep only shared elements ·
    <a href="compact.html"><code>compact</code></a> — drop nulls
  </div>
