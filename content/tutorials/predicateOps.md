---
slug: predicateOps
title: predicate combinators — FxDart 101
description: FxDart predicate combinators tutorial: build conditions from named predicates with and, or, xor, negate and contramap, with a live playground.
heading: predicate combinators
section: 10
crumb: and · or · xor · contramap
prev: not.html
prevLabel: not
next: when.html
nextLabel: when
---
  <p class="hero-sub">Builds a condition out of named predicates — <code>and</code>, <code>or</code>, <code>xor</code>, <code>negate</code>, <code>contramap</code> — instead of nesting lambdas.</p>

  {{signature}}

  <h2>Lecture</h2>
  <p>
    Every filtering operator in the library takes a predicate:
    <a href="filter.html"><code>filter</code></a>,
    <a href="reject.html"><code>reject</code></a>,
    <a href="takeWhile.html"><code>takeWhile</code></a>,
    <a href="dropWhile.html"><code>skipWhile</code></a>,
    <a href="countWhere.html"><code>countWhere</code></a>,
    <a href="partition.html"><code>partition</code></a>. Once you have named
    the conditions — <code>isEven</code>, <code>isPositive</code>,
    <code>isBlank</code> — combining them should not cost you a fresh lambda
    with a re-typed parameter each time. These combinators are that.
  </p>
  <p>
    They are an extension on <code>bool Function(T)</code>, so any predicate
    you already have grows the methods: a top-level function, a tear-off, a
    stored closure, or the result of another combinator. Each one returns a
    new predicate and calls nothing until <em>that</em> predicate runs.
  </p>
  <p>
    <code>and</code> and <code>or</code> short-circuit exactly like
    <code>&amp;&amp;</code> and <code>||</code> — the right-hand predicate is
    skipped when the left one has already decided, which matters when it is
    the expensive half. <code>xor</code> has nothing to short-circuit and
    always calls both.
  </p>
  <p>
    <code>contramap</code> is the odd one and the useful one. It maps the
    <em>argument</em> rather than the result — that is what the
    <em>contra</em> means — so a predicate on <code>int</code> becomes a
    predicate on anything you can turn into an <code>int</code>:
    <code>isEven.contramap&lt;String&gt;((s) =&gt; s.length)</code> tests a
    string's length without a word about strings in <code>isEven</code>.
  </p>
  <p>
    <code>.negate</code> is the extension-getter form of the top-level
    <a href="negate.html"><code>negate</code></a> — the same function, reached
    from the other side. Use whichever reads better at the call site;
    <code>isBlank.or(isShort).negate</code> reads left to right, where
    <code>negate(...)</code> would push the whole expression inside a call.
  </p>

  <h2>Demo 1 · and, or, xor, negate</h2>
  {{playground:0}}

  <h2>Demo 2 · contramap, and short-circuiting</h2>
  {{playground:1}}

  <h2>Try it yourself</h2>
  <p>Exercise: keep the rows that are neither blank nor short.</p>
  {{playground:2}}

  <div class="callout">
    <strong>Related:</strong>
    <a href="negate.html"><code>negate</code></a> — the top-level form of <code>.negate</code> ·
    <a href="not.html"><code>not</code></a> — flips a single boolean value, not a predicate ·
    <a href="filter.html"><code>filter</code></a> / <a href="reject.html"><code>whereNot</code></a> — where a combined predicate usually lands ·
    <a href="predicates.html"><code>predicates</code></a> — the built-in type predicates to combine with
  </div>
