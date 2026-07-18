---
slug: add
title: add — FxDart 101
description: FxDart add tutorial: a generic + as a function value, usable as a reducer, with a live playground.
heading: <code>add</code>
section: 10
crumb: add
prev: cases.html
prevLabel: cases
next: comparisons.html
nextLabel: gt · gte · lt · lte
---
  <p class="hero-sub">Adds two values of the same type, as a function you can pass around.</p>

  {{signature}}

  <h2>Lecture</h2>
  <p>
    <code>add(a, b)</code> is <code>+</code> packaged as a function value.
    Since it dispatches to <code>+</code> dynamically, it works for anything
    that supports the operator — <code>num</code>, <code>String</code>
    concatenation, even <code>List</code> concatenation — mirroring FxTS's
    <code>add</code>, which accepts both numbers and strings.
  </p>
  <p>
    Its real value shows up wherever an API wants a binary
    <code>(T, T) -&gt; T</code> function rather than an inline
    <code>(a, b) =&gt; a + b</code> — most naturally as the combining
    function for <code>reduce</code>/<code>fold</code>. It's a binary
    function though, so to use it as a unary <code>map</code> callback
    (adding a fixed amount to every element) you close over one side
    yourself: <code>(b) =&gt; add(n, b)</code>.
  </p>

  <h2>Demo 1 · Basics</h2>
  {{playground:0}}

  <h2>Demo 2 · As a reducer, and closed over for map</h2>
  {{playground:1}}

  <h2>Try it yourself</h2>
  <p>Exercise: use <code>fold</code> + <code>add</code> to concatenate all
    the parts into one string.</p>
  {{playground:2}}

  <div class="callout">
    <strong>Related:</strong>
    <a href="reduce.html"><code>reduce</code></a> / <a href="fold.html"><code>fold</code></a> — the usual home for add as a combiner ·
    <a href="sum.html"><code>sum</code></a> — a ready-made sum for Iterable&lt;num&gt; ·
    <a href="comparisons.html"><code>gt · gte · lt · lte</code></a> — the comparison counterparts to add ·
    <a href="apply.html"><code>apply</code></a> — call any function with a dynamic argument list
  </div>
