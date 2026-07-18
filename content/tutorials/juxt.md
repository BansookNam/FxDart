---
slug: juxt
title: juxt — FxDart 101
description: FxDart juxt tutorial: apply several functions to the same value and collect all the results, with a live playground.
heading: <code>juxt</code>
section: 10
crumb: juxt
prev: apply.html
prevLabel: apply
next: memoize.html
nextLabel: memoize
---
  <p class="hero-sub">Applies every function in a list to the same value and collects the results.</p>

  {{signature}}

  <h2>Lecture</h2>
  <p>
    Give <code>juxt</code> a list of functions that all accept the same
    input, and it gives you back one function that runs the input through
    every one of them and returns a <code>List</code> of the results, in
    order. It's a compact way to compute several independent views of a
    single value without repeating yourself.
  </p>
  <p>
    FxTS's <code>juxt</code> is variadic and can accept functions with
    different argument counts. Dart has no variadic generics, so FxDart's
    version takes a single unary function <code>T -&gt; R</code> per entry
    — still enough to cover the common case of "run these N read-only
    projections against this one value."
  </p>

  <h2>Demo 1 · Basics</h2>
  <p>The classic example from the dartdoc: computing the min and max of a
    list in one pass:</p>
  {{playground:0}}

  <h2>Demo 2 · Projecting several fields</h2>
  <p>Pulling multiple fields out of a record-like <code>Map</code> at once:</p>
  {{playground:1}}

  <h2>Try it yourself</h2>
  <p>Exercise: use <code>juxt</code> to compute the <code>sum</code> and
    <code>average</code> of this list in a single pass.</p>
  {{playground:2}}

  <div class="callout">
    <strong>Related:</strong>
    <a href="apply.html"><code>apply</code></a> — call a function with a dynamic argument list ·
    <a href="cases.html"><code>cases</code></a> — pick one function based on a predicate instead of running them all ·
    <a href="min.html"><code>min</code></a> / <a href="max.html"><code>max</code></a> — used together in the demo above ·
    <a href="zip.html"><code>zip</code></a> — combine values from two sequences instead of one
  </div>
