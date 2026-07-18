---
slug: takeRight
title: takeRight — FxDart 101
description: FxDart takeRight tutorial: keep only the last n values of a finite iterable, with a live playground.
heading: <code>takeRight</code>
section: 5
crumb: takeRight
prev: take.html
prevLabel: take
next: takeWhile.html
nextLabel: takeWhile
---
  <p class="hero-sub">Returns a lazy iterable of the last <code>length</code> values from a source.</p>

  {{signature}}

  <h2>Lecture</h2>
  <p>
    <code>takeRight</code> is <code>take</code>'s mirror image: instead of
    the first <code>length</code> values, you get the last ones. There's a
    catch, though — to know what the "last" values are, <code>takeRight</code>
    has to see every element first. It <strong>materializes</strong> the
    whole source into a list internally before yielding anything, so unlike
    most FxDart operators it does not work on infinite sequences.
  </p>
  <p>
    The async version has the same constraint: <code>takeRightAsync</code>
    drains the entire upstream (awaiting every element) before it can hand
    back the tail. Reach for it only when you know the source is finite and
    small enough to buffer.
  </p>

  <h2>Demo 1 · Basics</h2>
  {{playground:0}}

  <h2>Demo 2 · Async (must buffer the whole source first)</h2>
  {{playground:1}}

  <h2>Try it yourself</h2>
  <p>Exercise: keep only the last 3 scores.</p>
  {{playground:2}}

  <div class="callout">
    <strong>Related:</strong>
    <a href="take.html"><code>take</code></a> — first n instead of last n ·
    <a href="dropRight.html"><code>dropRight</code></a> — drop the last n ·
    <a href="reverse.html"><code>reverse</code></a> — also materializes the source ·
    <a href="slice.html"><code>slice</code></a> — arbitrary index window
  </div>
