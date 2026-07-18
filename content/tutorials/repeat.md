---
slug: repeat
title: repeat — FxDart 101
description: FxDart repeat tutorial: yield the same value n times, lazily.
heading: <code>repeat</code>
section: 2
crumb: repeat
prev: range.html
prevLabel: range
next: cycle.html
nextLabel: cycle
---
  <p class="hero-sub">Yields the same value n times — a lazy, finite source for padding and pairing.</p>

  {{signature}}

  <h2>Lecture</h2>
  <p>
    <code>repeat(n, value)</code> yields <code>value</code> exactly
    <code>n</code> times, then stops — it's finite and lazy, like the rest
    of this section's generators. Note that it repeats the <em>same</em>
    value (or the same object reference, for non-primitives) every time; if
    you need a fresh value per iteration, generate it separately (e.g. with
    <code>map</code> over the result) rather than expecting
    <code>repeat</code> to call a factory function.
  </p>
  <p>
    It's most useful paired with something else: <code>zip</code> it
    against a variable-length sequence to stamp a constant label onto every
    element, or use <code>fx(...).join()</code> to build a fixed-width
    separator string. <code>repeat(0, value)</code> is a valid, perfectly
    normal way to get an empty iterable.
  </p>
  <p>
    If you actually want to repeat a whole <em>sequence</em> rather than
    one value — and keep going forever instead of a fixed <code>n</code>
    times — that's <code>cycle</code>, covered next.
  </p>

  <h2>Demo 1 · Basics</h2>
  {{playground:0}}

  <h2>Demo 2 · Pairing a constant with a variable sequence</h2>
  <p>
    <code>repeat</code> yields the SAME value every time — pair it with
    <code>zip</code> to stamp a constant onto a variable-length sequence:
  </p>
  {{playground:1}}

  <h2>Try it yourself</h2>
  <p>Exercise: build a 5-item <code>List&lt;int&gt;</code> of the value 7
    using <code>repeat</code>.</p>
  {{playground:2}}

  <div class="callout">
    <strong>Related:</strong>
    <a href="range.html"><code>range</code></a> — a lazy sequence of increasing/decreasing integers ·
    <a href="cycle.html"><code>cycle</code></a> — repeat a whole sequence, forever ·
    <a href="zip.html"><code>zip</code></a> — pairs repeat is often used with ·
    <a href="fx.html"><code>fx</code></a> — the chain repeat is usually wrapped in
  </div>
