---
slug: matches
title: matches — FxDart 101
description: FxDart matches tutorial: the curried, filter-ready predicate form of isMatch.
heading: <code>matches</code>
section: 9
crumb: matches
prev: isMatch.html
prevLabel: isMatch
next: identity.html
nextLabel: identity
---
  <p class="hero-sub">Curried <code>isMatch</code>: bind a pattern once, get back a reusable predicate.</p>

  {{signature}}

  <h2>Lecture</h2>
  <p>
    <code>isMatch(target, pattern)</code> needs both arguments up front,
    which makes it awkward to hand to <code>filter</code>, <code>find</code>,
    <code>every</code>, or anywhere else that wants a single-argument
    <code>bool Function(A)</code>. <code>matches(pattern)</code> closes over
    the pattern and returns exactly that shape:
    <code>matches(pattern)(target) == isMatch(target, pattern)</code>. Build
    the predicate once, reuse it across a whole pipeline.
  </p>
  <p>
    This is FxDart's version of currying for a two-argument function where
    Dart can't infer a general curry — see the deprecated top-level
    <code>curry</code> if you're curious why a generic version doesn't
    exist — but a purpose-built curried form like this one works great.
  </p>

  <h2>Demo 1 · Basics</h2>
  {{playground:0}}

  <h2>Demo 2 · Dropping straight into filter/find</h2>
  {{playground:1}}

  <h2>Try it yourself</h2>
  <p>Exercise: use <code>matches</code> to build a predicate for <code>{'active': true}</code> and filter <code>users</code> with it.</p>
  {{playground:2}}

  <div class="callout">
    <strong>Related:</strong>
    <a href="isMatch.html"><code>isMatch</code></a> — the two-argument function this curries ·
    <a href="filter.html"><code>filter</code></a> — the most common place to plug this in ·
    <a href="find.html"><code>find</code></a> — grab just the first match ·
    <a href="predicates.html"><code>predicates</code></a> — more ready-made, filter-friendly checks
  </div>
