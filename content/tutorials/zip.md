---
slug: zip
title: zip — FxDart 101
description: FxDart zip tutorial: pair up elements from two (or three) iterables into records, with a live playground.
heading: <code>zip</code>
section: 6
crumb: zip
prev: concat.html
prevLabel: concat
next: zipWith.html
nextLabel: zipWith
---
  <p class="hero-sub">Pairs up elements from two iterables into records, stopping at the shorter one.</p>

  {{signature}}

  <h2>Lecture</h2>
  <p>
    <code>zip</code> walks two iterables side by side and yields one pair
    per step, stopping the moment either input runs out. Where FxTS returns
    a TS tuple, FxDart returns a Dart <strong>record</strong> —
    <code>(A, B)</code> — so you destructure results with
    <code>.$1</code>/<code>.$2</code> or pattern matching instead of
    array indices. Since Dart has no variadic generics, each arity gets its
    own function: <code>zip</code> for two iterables, <code>zip3</code> for
    three.
  </p>
  <p>
    <code>zipAsync</code> issues both sides' <code>next()</code> calls
    <em>before</em> awaiting either — so it pulls the two sources in
    parallel per pair rather than sequentially. Zipping two 100ms-per-item
    sources still only costs ~100ms per pair, not 200ms.
  </p>

  <h2>Demo 1 · Basics</h2>
  {{playground:0}}

  <h2>Demo 2 · Async, pulled in parallel per pair</h2>
  {{playground:1}}

  <h2>Try it yourself</h2>
  <p>Exercise: zip <code>names</code> and <code>ages</code> together into
    <code>(name, age)</code> records.</p>
  {{playground:2}}

  <div class="callout">
    <strong>Related:</strong>
    <a href="zipWith.html"><code>zipWith</code></a> — zip and combine in one step ·
    <a href="zipWithIndex.html"><code>zipWithIndex</code></a> — zip against a running index ·
    <a href="transpose.html"><code>transpose</code></a> — zip an arbitrary number of rows ·
    <a href="concat.html"><code>concat</code></a> — chain instead of pair
  </div>
