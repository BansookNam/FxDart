---
slug: reject
title: reject — FxDart 101
description: FxDart reject tutorial: the exact opposite of filter, with a live playground.
heading: <code>reject</code>
section: 4
crumb: reject
prev: filter.html
prevLabel: filter
next: compact.html
nextLabel: compact
---
  <p class="hero-sub">Keeps every element a predicate returns false for — the mirror image of filter.</p>

  {{signature}}

  <h2>Lecture</h2>
  <p>
    <code>reject</code> is implemented as
    <code>filter((a) =&gt; !f(a), iterable)</code> — it exists purely for
    readability. <code>list.reject(isInvalid)</code> reads more naturally
    than <code>list.filter((a) =&gt; !isInvalid(a))</code>, especially once
    the predicate already has a clear, positive name. Pick whichever of
    <code>filter</code>/<code>reject</code> lets you avoid writing a
    negation at the call site.
  </p>
  <p>
    Everything about <code>filter</code>'s behavior carries over unchanged:
    it's lazy, and the async form inherits <code>filterAsync</code>'s
    dedicated concurrent path, so <code>.concurrent(n)</code> genuinely
    evaluates <code>n</code> predicates in parallel while still returning
    results in original order.
  </p>

  <h2>Demo 1 · Basics</h2>
  {{playground:0}}

  <h2>Demo 2 · Async, with concurrency</h2>
  {{playground:1}}

  <h2>Try it yourself</h2>
  <p>Exercise: use <code>reject</code> to drop the <code>'info: ok'</code>
    lines, keeping only the errors.</p>
  {{playground:2}}

  <div class="callout">
    <strong>Related:</strong>
    <a href="filter.html"><code>filter</code></a> — the function reject delegates to ·
    <a href="compact.html"><code>compact</code></a> — reject nulls specifically ·
    <a href="uniq.html"><code>uniq</code></a> — remove duplicates ·
    <a href="concurrent.html"><code>concurrent</code></a> — parallel evaluation
  </div>
