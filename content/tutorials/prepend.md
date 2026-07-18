---
slug: prepend
title: prepend — FxDart 101
description: FxDart prepend tutorial: add one value to the front of a lazy iterable, with a live playground.
heading: <code>prepend</code>
section: 6
crumb: prepend
prev: append.html
prevLabel: append
next: concat.html
nextLabel: concat
---
  <p class="hero-sub">Yields one value first, then all values of the source.</p>

  {{signature}}

  <h2>Lecture</h2>
  <p>
    <code>prepend</code> is <code>append</code>'s mirror: it yields
    <code>a</code> first, then falls through to the source. Since the
    source itself is untouched until it's actually pulled, prepending is
    cheap regardless of how expensive or large the source is — no copying,
    no shifting indices, just one extra value ahead of the rest.
  </p>
  <p>
    <code>prependAsync</code> accepts a <code>Future</code> for <code>a</code>
    as well; it's awaited first, before the first pull reaches the
    underlying source.
  </p>

  <h2>Demo 1 · Basics</h2>
  {{playground:0}}

  <h2>Demo 2 · Async, with a future value</h2>
  {{playground:1}}

  <h2>Try it yourself</h2>
  <p>Exercise: prepend <code>'mix'</code> to the front of the steps.</p>
  {{playground:2}}

  <div class="callout">
    <strong>Related:</strong>
    <a href="append.html"><code>append</code></a> — add a value at the end instead ·
    <a href="concat.html"><code>concat</code></a> — join two full iterables ·
    <a href="reverse.html"><code>reverse</code></a>
  </div>
