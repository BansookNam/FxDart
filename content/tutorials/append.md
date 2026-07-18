---
slug: append
title: append — FxDart 101
description: FxDart append tutorial: add one value to the end of a lazy iterable, with a live playground.
heading: <code>append</code>
section: 6
crumb: append
prev: split.html
prevLabel: split
next: prepend.html
nextLabel: prepend
---
  <p class="hero-sub">Yields all values of the source, then one extra value at the end.</p>

  {{signature}}

  <h2>Lecture</h2>
  <p>
    <code>append</code> is the simplest way to tack a single trailing value
    onto a lazy sequence without materializing anything: it just yields
    through the whole source and then yields <code>a</code> once the source
    is exhausted. Because the source is only consumed when pulled, this
    works fine even when the source is expensive to compute — the extra
    value is truly the last thing produced.
  </p>
  <p>
    On the async side, <code>a</code> itself may be a <code>Future</code> —
    <code>appendAsync</code> awaits it only once the upstream is done, so a
    slow "closing" value doesn't hold anything up early.
  </p>

  <h2>Demo 1 · Basics</h2>
  {{playground:0}}

  <h2>Demo 2 · Async, with a future value</h2>
  {{playground:1}}

  <h2>Try it yourself</h2>
  <p>Exercise: append <code>'cool'</code> to the end of the steps.</p>
  {{playground:2}}

  <div class="callout">
    <strong>Related:</strong>
    <a href="prepend.html"><code>prepend</code></a> — add a value at the front instead ·
    <a href="concat.html"><code>concat</code></a> — join two full iterables ·
    <a href="reverse.html"><code>reverse</code></a>
  </div>
