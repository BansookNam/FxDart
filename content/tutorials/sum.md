---
slug: sum
title: sum — FxDart 101
description: FxDart sum tutorial: add up every number in a pipeline, with a live playground.
heading: <code>sum</code>
section: 7
crumb: sum
prev: reduceLazy.html
prevLabel: reduceLazy
next: sumBy.html
nextLabel: sumBy
---
  <p class="hero-sub">Adds up every number a lazy pipeline produces.</p>

  {{signature}}

  <h2>Lecture</h2>
  <p>
    <code>sum</code> is a terminal operator, and one of the simplest
    special-cased folds in the library: it's literally
    <code>fold(0, (a, b) =&gt; a + b, iterable)</code> underneath. Like every
    terminal, calling it pulls the entire lazy pipeline upstream of it — so
    you can build an elaborate chain of <code>map</code>/<code>filter</code>
    steps and only pay for the values <code>sum</code> actually needs, which
    is all of them.
  </p>
  <p>
    Because the seed is <code>0</code>, summing an empty iterable gives
    <code>0</code> — no error, no <code>NaN</code>. That's different from its
    neighbors <code><a href="min.html">min</a></code>,
    <code><a href="max.html">max</a></code>, and
    <code><a href="average.html">average</a></code>, which each have their
    own (surprising!) empty-input behavior worth knowing about.
  </p>
  <p>
    The chain form is available as an extension method,
    <code>Fx&lt;num&gt;.sum()</code> / <code>FxAsync&lt;num&gt;.sum()</code> —
    it only shows up once your chain's element type is known to be
    <code>num</code> (or <code>int</code>/<code>double</code>, thanks to
    generic covariance).
  </p>

  <h2>Demo 1 · Basics</h2>
  {{playground:0}}

  <h2>Demo 2 · Async</h2>
  {{playground:1}}

  <h2>Try it yourself</h2>
  <p>Exercise: sum only the <strong>even</strong> numbers in the list.</p>
  {{playground:2}}

  <div class="callout">
    <strong>Related:</strong>
    <a href="average.html"><code>average</code></a> — sum divided by count ·
    <a href="fold.html"><code>fold</code></a> — the general form sum specializes ·
    <a href="min.html"><code>min</code></a> · <a href="max.html"><code>max</code></a> — the other numeric terminals
  </div>
