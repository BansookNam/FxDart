---
slug: zipWith
title: zipWith — FxDart 101
description: FxDart zipWith tutorial: zip two iterables and combine each pair through a function in one step, with a live playground.
heading: <code>zipWith</code>
section: 6
crumb: zipWith
prev: zip.html
prevLabel: zip
next: zipWithIndex.html
nextLabel: zipWithIndex
---
  <p class="hero-sub">Zips two iterables and combines each pair through a function, in one step.</p>

  {{signature}}

  <h2>Lecture</h2>
  <p>
    <code>zipWith</code> is exactly <code>zip</code> followed by
    <code>map</code> over the resulting pairs — in fact that's how it's
    implemented in FxDart, as <code>map((r) => f(r.$1, r.$2), zip(...))</code>.
    Reach for it when you don't actually want the intermediate
    <code>(A, B)</code> record, just the combined result: multiplying two
    parallel lists together, formatting a name and an age into one label,
    and so on.
  </p>
  <p>
    It stops at the shorter of the two inputs, same as <code>zip</code>, and
    the async form <code>zipWithAsync</code> inherits <code>zipAsync</code>'s
    parallel-per-pair pulling. There's no <code>Fx</code> chain form for
    <code>zipWith</code> — call the top-level function directly (or build it
    yourself as <code>.zip(other).map((r) => f(r.$1, r.$2))</code>).
  </p>

  <h2>Demo 1 · Basics</h2>
  {{playground:0}}

  <h2>Demo 2 · Async</h2>
  {{playground:1}}

  <h2>Try it yourself</h2>
  <p>Exercise: use <code>zipWith</code> to compute the line total
    (<code>price * quantity</code>) per pair.</p>
  {{playground:2}}

  <div class="callout">
    <strong>Related:</strong>
    <a href="zip.html"><code>zip</code></a> — the plain-pairs version this builds on ·
    <a href="zipWithIndex.html"><code>zipWithIndex</code></a> — zip against a running index ·
    <a href="map.html"><code>map</code></a>
  </div>
