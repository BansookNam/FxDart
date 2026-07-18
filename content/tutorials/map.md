---
slug: map
title: map — FxDart 101
description: FxDart map tutorial: transform each element of a lazy pipeline, sync and async, with a live playground.
heading: <code>map</code>
section: 3
crumb: map
next: mapEffect.html
nextLabel: mapEffect
---
  <p class="hero-sub">Returns a lazy iterable of values produced by running each element through a function.</p>

  {{signature}}

  <h2>Lecture</h2>
  <p>
    <code>map</code> is the most fundamental transformer: it applies a function
    to every element. In FxDart it is <strong>lazy</strong> — calling
    <code>map</code> does no work at all. The function runs only when a terminal
    operator (<code>toArray</code>, <code>each</code>, <code>reduce</code>, …)
    pulls values through the pipeline. That means you can <code>map</code> over
    an enormous — even infinite — sequence, as long as you only pull what you
    need.
  </p>
  <p>
    It comes in data-first form (<code>map(f, iterable)</code>) and as a chain
    method (<code>fx(iterable).map(f)</code>). Both return the same lazy result.
  </p>

  <h2>Demo 1 · Basics &amp; laziness</h2>
  <p>Note how the mapping function only runs for the 3 values that
    <code>take(3)</code> pulls — out of a million:</p>
  {{playground:0}}

  <h2>Demo 2 · Async, with concurrency</h2>
  <p>
    <code>mapAsync</code> (or <code>.toAsync().map(...)</code>) accepts an async
    function. On its own it awaits each element in order; add
    <code>concurrent(n)</code> and the upstream evaluates <code>n</code> elements
    at a time — results still arrive in order:
  </p>
  {{playground:1}}

  <h2>Try it yourself</h2>
  <p>Exercise: use <code>map</code> to turn this list of maps into a list of
    formatted name strings like <code>"KIM (32)"</code>.</p>
  {{playground:2}}

  <div class="callout">
    <strong>Related:</strong>
    <a href="mapEffect.html"><code>mapEffect</code></a> — same as map, signals side effects ·
    <a href="flatMap.html"><code>flatMap</code></a> — map + flatten ·
    <a href="peek.html"><code>peek</code></a> — observe without transforming ·
    <a href="concurrent.html"><code>concurrent</code></a> — parallel evaluation
  </div>
