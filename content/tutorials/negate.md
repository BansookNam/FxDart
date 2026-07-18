---
slug: negate
title: negate — FxDart 101
description: FxDart negate tutorial: turn any predicate into its logical opposite, with a live playground.
heading: <code>negate</code>
section: 10
crumb: negate
prev: memoize.html
prevLabel: memoize
next: not.html
nextLabel: not
---
  <p class="hero-sub">Returns a predicate that's the logical negation of the one you pass in.</p>

  {{signature}}

  <h2>Lecture</h2>
  <p>
    <code>negate(f)</code> gives you back a new predicate that returns
    <code>!f(x)</code> for any <code>x</code>. It's most useful when you
    already have a named predicate (<code>isEven</code>, <code>isEmpty</code>,
    a <code>matches(pattern)</code> result) and want its opposite as a
    function value — for <code>filter</code>, <code>reject</code>, or
    anywhere else a predicate is expected — without redefining the logic.
  </p>
  <p>
    Don't confuse it with <a href="not.html"><code>not</code></a>: <code>not</code>
    flips a single <code>bool</code> value, <code>negate</code> flips a whole
    <em>predicate function</em>. <code>negate(f)</code> is roughly
    <code>(x) =&gt; not(f(x))</code>.
  </p>

  <h2>Demo 1 · Basics</h2>
  {{playground:0}}

  <h2>Demo 2 · Negating a library predicate</h2>
  <p>
    <code>negate</code> composes with any predicate already in the library,
    like the value-based <a href="isEmpty.html"><code>isEmpty</code></a>:
  </p>
  {{playground:1}}

  <h2>Try it yourself</h2>
  <p>Exercise: use <code>negate(isVowel)</code> to keep only the consonants.</p>
  {{playground:2}}

  <div class="callout">
    <strong>Related:</strong>
    <a href="not.html"><code>not</code></a> — negate a single boolean value ·
    <a href="filter.html"><code>filter</code></a> / <a href="reject.html"><code>reject</code></a> — the usual home for a negated predicate ·
    <a href="isEmpty.html"><code>isEmpty</code></a> — a value-based predicate to combine with negate ·
    <a href="when.html"><code>when</code></a> — apply a callback only when a predicate holds
  </div>
