---
slug: reject
title: whereNot — FxDart 101
description: FxDart whereNot tutorial: keep every element a predicate rejects — the mirror image of where, with a live playground.
heading: <code>whereNot</code>
section: 4
crumb: whereNot
prev: filter.html
prevLabel: filter
next: compact.html
nextLabel: compact
---
  <p class="hero-sub">Keeps every element a predicate returns false for — the mirror image of where.</p>

  {{signature}}

  <h2>Lecture</h2>
  <p>
    <code>whereNot</code> is implemented as
    <code>where((a) =&gt; !f(a), iterable)</code> — it exists purely for
    readability. <code>list.whereNot(isInvalid)</code> reads more naturally
    than <code>list.where((a) =&gt; !isInvalid(a))</code>, especially once
    the predicate already has a clear, positive name. <code>whereNot</code>
    is the Dart-idiomatic name; fxdart also accepts the FxTS spelling
    <code>reject</code> — they're the same operator. Pick whichever of
    <code>where</code>/<code>whereNot</code> lets you avoid writing a
    negation at the call site.
  </p>
  <p>
    Everything about <code>where</code>'s behavior carries over unchanged:
    it's lazy, and the async form inherits <code>whereAsync</code>'s
    dedicated concurrent path, so <code>.concurrent(n)</code> genuinely
    evaluates <code>n</code> predicates in parallel while still returning
    results in original order.
  </p>

  <h2>Demo 1 · Basics</h2>
  {{playground:0}}

  <h2>Demo 2 · Async, with concurrency</h2>
  {{playground:1}}

  <h2>Try it yourself</h2>
  <p>Exercise: use <code>whereNot</code> to drop the <code>'info: ok'</code>
    lines, keeping only the errors.</p>
  {{playground:2}}

  <div class="callout">
    <strong>Related:</strong>
    <a href="filter.html"><code>filter</code></a> — the function reject delegates to ·
    <a href="compact.html"><code>compact</code></a> — reject nulls specifically ·
    <a href="uniq.html"><code>uniq</code></a> — remove duplicates ·
    <a href="concurrent.html"><code>concurrent</code></a> — parallel evaluation
  </div>
