---
slug: join
title: join — FxDart 101
description: FxDart join tutorial: concatenate a pipeline's elements into one string, data-first, with a live playground.
heading: <code>join</code>
section: 7
crumb: join
prev: size.html
prevLabel: size
next: groupBy.html
nextLabel: groupBy
---
  <p class="hero-sub">Concatenates every element into one string, with a separator between them.</p>

  {{signature}}

  <h2>Lecture</h2>
  <p>
    <code>join</code> is a terminal operator: it pulls the whole pipeline,
    calling <code>toString()</code> on each element and stitching the results
    together with <code>sep</code> in between.
  </p>
  <p>
    Pay attention to argument order — the top-level, data-first
    <code>join</code> puts the <strong>separator first</strong>:
    <code>join(', ', iterable)</code>. That's the FxTS convention (data-first
    everywhere), and it's the opposite of Dart's own
    <code>Iterable.join(separator)</code> method, which takes the iterable
    as the receiver and the separator as its one argument.
  </p>
  <p>
    That difference bleeds into the chain form in a subtle way: on the
    <strong>sync</strong> chain, <code>.join(...)</code> is simply Dart's
    built-in <code>Iterable.join</code>, whose default separator is
    <code>''</code> (empty) when omitted. But <code>FxAsync.join</code> is
    written explicitly in FxDart and defaults its separator to
    <code>','</code> instead — matching FxTS's own default. Don't assume the
    two chains behave identically when you skip the argument.
  </p>

  <h2>Demo 1 · Basics &amp; the two defaults</h2>
  {{playground:0}}

  <h2>Demo 2 · Async, and its different default</h2>
  {{playground:1}}

  <h2>Try it yourself</h2>
  <p>Exercise: join the columns into a single CSV header row, separated by <code>','</code>.</p>
  {{playground:2}}

  <div class="callout">
    <strong>Related:</strong>
    <a href="sort.html"><code>sort</code></a> — order elements before joining them ·
    <a href="map.html"><code>map</code></a> — format each element before joining ·
    <a href="size.html"><code>size</code></a> — the other simple string/count terminal
  </div>
