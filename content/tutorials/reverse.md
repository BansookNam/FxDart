---
slug: reverse
title: reverse — FxDart 101
description: FxDart reverse tutorial: yield a finite iterable back to front, with a live playground.
heading: <code>reverse</code>
section: 6
crumb: reverse
prev: transpose.html
prevLabel: transpose
next: fork.html
nextLabel: fork
---
  <p class="hero-sub">Returns the source in reverse order.</p>

  {{signature}}

  <h2>Lecture</h2>
  <p>
    <code>reverse</code> yields a source's elements last-to-first. Like
    <code>takeRight</code> and <code>dropRight</code>, there's no way to know
    what "last" means without first seeing everything, so <code>reverse</code>
    <strong>materializes</strong> the whole source into a list before it
    yields a single value. It's an operator for finite, bufferable sources —
    it will never terminate on an infinite one.
  </p>
  <p>
    <code>reverseAsync</code> follows the same rule: it awaits every element
    of the upstream first, then replays them back to front. If you only need
    the tail of a sequence rather than a true reversal, prefer
    <code>takeRight</code> — it materializes too, but at least stops as soon
    as it has the values it needs to output in order.
  </p>

  <h2>Demo 1 · Basics</h2>
  {{playground:0}}

  <h2>Demo 2 · Async (must buffer the whole source first)</h2>
  {{playground:1}}

  <h2>Try it yourself</h2>
  <p>Exercise: reverse the history so the most recent visit comes first.</p>
  {{playground:2}}

  <div class="callout">
    <strong>Related:</strong>
    <a href="takeRight.html"><code>takeRight</code></a> — also materializes, only needs the tail ·
    <a href="dropRight.html"><code>dropRight</code></a> ·
    <a href="sort.html"><code>sort</code></a> — also materializes into a new list
  </div>
