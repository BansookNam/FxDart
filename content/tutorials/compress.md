---
slug: compress
title: compress — FxDart 101
description: FxDart compress tutorial: filter an iterable by a parallel list of booleans, with a live playground.
heading: <code>compress</code>
section: 4
crumb: compress
prev: intersectionBy.html
prevLabel: intersectionBy
next: ../tutorials/take.html
nextLabel: take
---
  <p class="hero-sub">Keeps the elements of an iterable wherever a parallel list of booleans is true.</p>

  {{signature}}

  <h2>Lecture</h2>
  <p>
    <code>compress</code> is a positional mask: element <code>i</code> of
    <code>iterable</code> survives only if <code>selectors[i]</code> is
    <code>true</code>. It's built directly out of two functions you already
    know — <code>map((r) =&gt; r.$2, filter((r) =&gt; r.$1, zip(selectors, iterable)))</code> —
    zip the mask with the data, filter to the true pairs, then unwrap. That
    also means it inherits <code>zip</code>'s behavior on mismatched
    lengths: iteration stops as soon as the <em>shorter</em> of
    <code>selectors</code> or <code>iterable</code> runs out, so a short
    selector list silently truncates the result. Reach for it when you
    already have (or can cheaply compute) a boolean mask up front — for
    example, "which quiz answers were correct" — rather than recomputing a
    predicate per element the way <code>filter</code> would.
  </p>
  <p>
    There's no chain method; call the data-first function or its async
    counterpart directly, or wrap the result with <code>fx(...)</code> /
    <code>fxAsync(...)</code> to keep chaining.
  </p>

  <h2>Demo 1 · Basics &amp; length mismatch</h2>
  {{playground:0}}

  <h2>Demo 2 · Async, with concurrency</h2>
  {{playground:1}}

  <h2>Try it yourself</h2>
  <p>Exercise: use <code>compress</code> to keep only the correct
    answers.</p>
  {{playground:2}}

  <div class="callout">
    <strong>Related:</strong>
    <a href="filter.html"><code>filter</code></a> — filter by a predicate instead of a precomputed mask ·
    <a href="../tutorials/zip.html"><code>zip</code></a> — the function compress is built on ·
    <a href="differenceBy.html"><code>differenceBy</code></a> — filter by membership against another iterable ·
    <a href="../tutorials/partition.html"><code>partition</code></a> — split into kept/rejected in one pass
  </div>
