---
slug: zipWithIndex
title: indexed — FxDart 101
description: FxDart indexed: pair each element with its 0-based index, with a live playground.
heading: <code>indexed</code>
section: 6
crumb: indexed
prev: zipWith.html
prevLabel: zipWith
next: transpose.html
nextLabel: transpose
---
  <p class="hero-sub">Pairs each element with its (0-based) index: <code>(index, value)</code>.</p>

  {{signature}}

  <h2>Lecture</h2>
  <p>
    <code>indexed</code> is <code>zip</code> against an implicit
    counter: each element comes out paired as <code>(index, value)</code>,
    counting up from <code>0</code>. It's the lazy-pipeline answer to a
    manual <code>for (var i = 0; i &lt; list.length; i++)</code> loop — no
    counter variable to manage, and it composes with the rest of the chain.
    <code>indexed</code> is the Dart-idiomatic name (it mirrors
    <code>Iterable.indexed</code>); fxdart also accepts the FxTS spelling
    <code>zipWithIndex</code> — they're the same operator.
  </p>
  <p>
    Because it only needs to track a running counter, <code>indexed</code>
    stays lazy and works over an infinite source just as well as a finite
    one; the async form counts the same way as elements resolve.
  </p>

  <h2>Demo 1 · Basics</h2>
  {{playground:0}}

  <h2>Demo 2 · Async</h2>
  {{playground:1}}

  <h2>Try it yourself</h2>
  <p>Exercise: pair each runner with their (0-based) finishing position.</p>
  {{playground:2}}

  <div class="callout">
    <strong>Related:</strong>
    <a href="zip.html"><code>zip</code></a> — pair two iterables together ·
    <a href="zipWith.html"><code>zipWith</code></a> — zip and combine in one step ·
    <a href="entries.html"><code>entries</code></a> — pair Map keys with values
  </div>
