---
slug: comparisons
title: gt · gte · lt · lte — FxDart 101
description: FxDart comparison tutorial: data-first gt, gte, lt, lte, and how to curry them into unary predicates, with a live playground.
heading: <code>gt</code> · <code>gte</code> · <code>lt</code> · <code>lte</code>
section: 10
crumb: gt · gte · lt · lte
prev: add.html
prevLabel: add
next: delay.html
nextLabel: delay &amp; sleep
---
  <p class="hero-sub">Data-first comparisons, as function values instead of operators.</p>

  {{signature}}

  <h2>Lecture</h2>
  <p>
    <code>gt</code>, <code>gte</code>, <code>lt</code>, and <code>lte</code>
    are the four ordering operators packaged as <strong>data-first</strong>
    functions: <code>gt(a, b) == (a &gt; b)</code>, with the first argument on
    the left, exactly like the operator. That makes them drop-in comparators
    wherever an API wants a function instead of an infix operator.
  </p>
  <p>
    Under the hood they require both values to be mutually
    <code>Comparable</code> and — with one exception — the exact same runtime
    type: <code>num</code> vs <code>num</code> and <code>String</code> vs
    <code>String</code> are allowed to mix (so <code>int</code> can compare
    against <code>double</code>), but anything else with mismatched types
    throws an <code>ArgumentError</code> rather than silently coercing.
  </p>
  <p>
    None of the four are curried — there's no <code>gt(5)</code> partial
    application. For a reusable unary predicate (say, for <code>filter</code>),
    write a small closure that fixes one side:
    <code>(b) =&gt; gt(b, 5)</code>.
  </p>

  <h2>Demo 1 · Basics, and the type-mismatch error</h2>
  {{playground:0}}

  <h2>Demo 2 · Currying into a filter predicate</h2>
  {{playground:1}}

  <h2>Try it yourself</h2>
  <p>Exercise: keep only the ages that are <code>gte</code> 18 (adults).</p>
  {{playground:2}}

  <div class="callout">
    <strong>Related:</strong>
    <a href="add.html"><code>add</code></a> — the arithmetic counterpart to these comparisons ·
    <a href="sort.html"><code>sort</code></a> / <a href="sortBy.html"><code>sortBy</code></a> — build a comparator from lt/gt ·
    <a href="min.html"><code>min</code></a> / <a href="max.html"><code>max</code></a> — aggregate versions of these comparisons ·
    <a href="negate.html"><code>negate</code></a> — flip a curried comparison predicate
  </div>
