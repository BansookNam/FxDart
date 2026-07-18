---
slug: isEmpty
title: isEmpty — FxDart 101
description: FxDart isEmpty tutorial: a value-based emptiness check for null, strings, and collections, usable as a filter-friendly predicate.
heading: <code>isEmpty</code>
section: 8
crumb: isEmpty
prev: includes.html
prevLabel: includes
next: every.html
nextLabel: every
---
  <p class="hero-sub">A value-based emptiness check: true for <code>null</code>, <code>''</code>, and empty collections.</p>

  {{signature}}

  <h2>Lecture</h2>
  <p>
    This is <strong>not</strong> the same thing as <code>Iterable.isEmpty</code>,
    the getter you already get for free on every <code>List</code>, <code>Set</code>,
    or <code>Fx</code> chain. That getter only exists on iterables, and blows
    up (or is simply unavailable) on <code>null</code>. FxTS's <code>isEmpty</code>
    takes <em>any</em> value and answers a broader question: is this thing
    "nothing" in a practical sense? It returns <code>true</code> for
    <code>null</code>, an empty <code>String</code>, and an empty
    <code>Iterable</code>/<code>Map</code>/<code>Set</code> — and
    <code>false</code> for everything else, including numbers and booleans,
    which are never considered "empty."
  </p>
  <p>
    Because it takes a single <code>Object?</code> argument, it tears off
    directly into <code>filter</code>, <code>reject</code>, or any other
    predicate-shaped slot without a wrapper lambda.
  </p>

  <h2>Demo 1 · Basics</h2>
  {{playground:0}}

  <h2>Demo 2 · As a filter-friendly tear-off</h2>
  <p>
    A mixed bag of values, kept down to the ones <code>isEmpty</code> considers empty
    (the printed empty string shows up as nothing between the commas):
  </p>
  {{playground:1}}

  <h2>Try it yourself</h2>
  <p>Exercise: use <code>isEmpty</code> to print <code>'no comment'</code> when <code>comment</code> is empty, or the comment itself.</p>
  {{playground:2}}

  <div class="callout">
    <strong>Related:</strong>
    <a href="compact.html"><code>compact</code></a> — drop nulls from an iterable ·
    <a href="compactObject.html"><code>compactObject</code></a> — drop nulls from a Map ·
    <a href="predicates.html"><code>predicates</code></a> — more filter-friendly type checks ·
    <a href="includes.html"><code>includes</code></a> — the neighboring membership check
  </div>
