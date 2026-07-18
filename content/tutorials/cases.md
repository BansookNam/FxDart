---
slug: cases
title: cases — FxDart 101
description: FxDart cases tutorial: build a predicate/mapper dispatch table with an optional default, with a live playground.
heading: <code>cases</code>
section: 10
crumb: cases
prev: throwIf.html
prevLabel: throwIf
next: add.html
nextLabel: add
---
  <p class="hero-sub">Builds a predicate/mapper dispatch table, with an optional default.</p>

  {{signature}}

  <h2>Lecture</h2>
  <p>
    <code>cases</code> builds a matcher out of a list of
    <code>(predicate, mapper)</code> pairs: it tries each pair in order, and
    the first one whose predicate returns true has its mapper applied to
    produce the result. It's a functional stand-in for a chain of
    <code>if</code>/<code>else if</code>, and it composes nicely with
    <code>map</code> — the returned function is a plain unary
    <code>T -&gt; R</code> you can pass straight in.
  </p>
  <p>
    <strong>This shape differs from FxTS on purpose.</strong> FxTS's
    <code>cases</code> is variadic: each <code>[predicate, mapper]</code> pair
    is its own trailing argument, with an optional final bare function acting
    as the default, and TypeScript's overloaded generics type each arity by
    hand. Dart has neither variadic generics nor per-arity overloads, so
    there's no way to accept "any number of pair arguments" and still get
    real type checking. FxDart's version instead takes one
    <code>List</code> of <code>(predicate, mapper)</code> <strong>records</strong>
    — Dart's tuple type — plus a separate named <code>orElse</code> parameter
    so the default is never confused with just another pair.
  </p>
  <p>
    If nothing matches and no <code>orElse</code> is given, <code>cases</code>
    falls back to returning <code>value</code> itself — which only compiles
    at the call site if <code>T</code> happens to also satisfy <code>R</code>
    — otherwise it throws a <code>StateError</code> at runtime. In practice,
    always pass <code>orElse</code> unless you're certain your predicates are
    exhaustive.
  </p>

  <h2>Demo 1 · Basics</h2>
  {{playground:0}}

  <h2>Demo 2 · A grading pipeline</h2>
  {{playground:1}}

  <h2>Try it yourself</h2>
  <p>Exercise: classify each size as <code>'small'</code> (&lt;10),
    <code>'medium'</code> (&lt;30), or <code>'large'</code>.</p>
  {{playground:2}}

  <div class="callout">
    <strong>Related:</strong>
    <a href="when.html"><code>when</code></a> / <a href="unless.html"><code>unless</code></a> — a single predicate, same result type ·
    <a href="throwError.html"><code>throwError</code></a> — a common orElse when no match should be fatal ·
    <a href="always.html"><code>always</code></a> — a constant orElse ·
    <a href="matches.html"><code>matches</code></a> — a predicate you can plug into a case
  </div>
