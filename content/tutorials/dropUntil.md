---
slug: dropUntil
title: dropUntil — FxDart 101
description: FxDart dropUntil tutorial: skip values up to and including the first match, then yield the rest, with a live playground.
heading: <code>dropUntil</code>
section: 5
crumb: dropUntil
prev: dropWhile.html
prevLabel: dropWhile
next: slice.html
nextLabel: slice
---
  <p class="hero-sub">Skips values until the predicate matches — the matching element is dropped too — then yields the rest.</p>

  {{signature}}

  <h2>Lecture</h2>
  <p>
    <code>dropUntil</code> is the drop-side counterpart to
    <code>takeUntilInclusive</code> — and the two treat their matching
    element in opposite ways. <code>dropWhile</code> stops dropping right
    <em>before</em> the failing element, keeping it in the output;
    <code>dropUntil</code> stops <em>at</em> the matching element and
    discards it along with everything before it. Only elements strictly
    after the match survive.
  </p>
  <p>
    Use it when a marker or sentinel needs to disappear along with the
    prefix it delimits — "everything after the <code>READY</code> line, not
    including <code>READY</code> itself".
  </p>

  <h2>Demo 1 · Basics</h2>
  <p>Compare with <code>dropWhile</code>: here the matching element
    (<code>3</code> / <code>'STOP'</code>) does not appear in the result:</p>
  {{playground:0}}

  <h2>Demo 2 · Async</h2>
  {{playground:1}}

  <h2>Try it yourself</h2>
  <p>Exercise: drop everything up to and including <code>'READY'</code>.</p>
  {{playground:2}}

  <div class="callout">
    <strong>Related:</strong>
    <a href="dropWhile.html"><code>dropWhile</code></a> — keeps the matching element ·
    <a href="takeUntilInclusive.html"><code>takeUntilInclusive</code></a> — the take-side counterpart ·
    <a href="drop.html"><code>drop</code></a> — drop by fixed count
  </div>
