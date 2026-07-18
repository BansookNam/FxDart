---
slug: tap
title: tap — FxDart 101
description: FxDart tap tutorial: run a side effect on a value and return it unchanged, data-first, with a live playground.
heading: <code>tap</code>
section: 10
crumb: tap
prev: always.html
prevLabel: always
next: apply.html
nextLabel: apply
---
  <p class="hero-sub">Calls a function with a value for its side effect, then returns the value unchanged.</p>

  {{signature}}

  <h2>Lecture</h2>
  <p>
    <code>tap</code> is data-first: <code>tap(f, value)</code> runs
    <code>f(value)</code> — usually a <code>print</code>, a log call, or some
    other side effect — and then hands <code>value</code> straight back
    unchanged. It exists so you can peek at a value <em>without breaking the
    expression it's part of</em>: wrap any single value in <code>tap</code>
    and the surrounding code doesn't need to change at all.
  </p>
  <p>
    <code>tap</code> operates on one value at a time. Its cousin
    <a href="peek.html"><code>peek</code></a> is the pipeline version — it
    runs a side effect for every element of an <code>Iterable</code> as it's
    pulled through. For a curried, reusable "logger" you close over
    <code>f</code> yourself: <code>(v) => tap(f, v)</code>, as shown below.
  </p>

  <h2>Demo 1 · Basics</h2>
  {{playground:0}}

  <h2>Demo 2 · Logging inside a pipe</h2>
  <p>
    Closing over <code>tap</code> gives a reusable "curried" logger you can
    drop into a <code>pipe</code> chain to inspect intermediate values without
    altering the flow of data:
  </p>
  {{playground:1}}

  <h2>Try it yourself</h2>
  <p>Exercise: use <code>tap</code> to print each value as it flows through
    the <code>map</code> callback, before it gets multiplied by 10.</p>
  {{playground:2}}

  <div class="callout">
    <strong>Related:</strong>
    <a href="peek.html"><code>peek</code></a> — the pipeline version of tap ·
    <a href="pipe1.html"><code>pipe1</code></a> / <a href="pipe.html"><code>pipe</code></a> — compose a value through functions ·
    <a href="identity.html"><code>identity</code></a> — pass through with no side effect at all ·
    <a href="apply.html"><code>apply</code></a> — invoke a function with a dynamic argument list
  </div>
