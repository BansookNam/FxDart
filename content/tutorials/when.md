---
slug: when
title: when — FxDart 101
description: FxDart when tutorial: apply a transform only when a predicate holds, otherwise pass the value through, with a live playground.
heading: <code>when</code>
section: 10
crumb: when
prev: not.html
prevLabel: not
next: unless.html
nextLabel: unless
---
  <p class="hero-sub">Applies a callback when a predicate holds, otherwise returns the value unchanged.</p>

  {{signature}}

  <h2>Lecture</h2>
  <p>
    <code>when(predicate, callback, value)</code> is a single conditional
    expressed as data: if <code>predicate(value)</code> is true, the result
    is <code>callback(value)</code>; otherwise the result is <code>value</code>
    itself, untouched. It reads nicely inside a <code>map</code> callback when
    you want to transform only the elements that need it and leave the rest alone.
  </p>
  <p>
    FxTS's version can widen the return type to a union <code>T | R</code>
    when the branches disagree. Dart has no union types, so both the
    <code>callback</code> branch and the pass-through branch must share the
    same type <code>T</code> — if you need genuinely different result types,
    reach for <a href="cases.html"><code>cases</code></a> instead, which
    allows <code>R</code> to differ from the input type.
  </p>

  <h2>Demo 1 · Basics</h2>
  {{playground:0}}

  <h2>Demo 2 · Clamping values in a pipeline</h2>
  {{playground:1}}

  <h2>Try it yourself</h2>
  <p>Exercise: use <code>when</code> to double only the positive prices,
    leaving negative ones untouched.</p>
  {{playground:2}}

  <div class="callout">
    <strong>Related:</strong>
    <a href="unless.html"><code>unless</code></a> — the inverse-condition sibling of when ·
    <a href="cases.html"><code>cases</code></a> — multiple predicates, and a differing result type ·
    <a href="not.html"><code>not</code></a> / <a href="negate.html"><code>negate</code></a> — build the predicate you pass in ·
    <a href="map.html"><code>map</code></a> — the usual place to use when as a callback
  </div>
