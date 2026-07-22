---
slug: some
title: any — FxDart 101
description: FxDart any tutorial: check that at least one element satisfies a predicate, short-circuiting on the first hit, sync and async.
heading: <code>any</code>
section: 8
crumb: any
prev: every.html
prevLabel: every
next: predicates.html
nextLabel: predicates
---
  <p class="hero-sub">True when at least one element satisfies a predicate — false for an empty iterable.</p>

  {{signature}}

  <h2>Lecture</h2>
  <p>
    <code>any</code> is the Dart-idiomatic name; fxdart also accepts the
    FxTS spelling <code>some</code> — they're the same operator. It's
    <code>every</code>'s mirror image: it scans left to
    right and short-circuits the moment it finds a match, returning
    <code>true</code> right away. If it never finds one — including on an
    empty iterable, which is the opposite vacuous case from
    <code>every</code> — it returns <code>false</code> only after checking
    everything.
  </p>
  <p>
    On a sync chain, <code>.any(f)</code> comes straight from Dart's
    <code>Iterable</code> — <code>Fx</code> inherits it — so it needs no
    special definition. The async chain and the data-first
    <code>any(f, iterable)</code> form are supplied by fxdart, and the FxTS
    spelling <code>some</code> still works in every position.
  </p>

  <h2>Demo 1 · Basics &amp; short-circuiting</h2>
  {{playground:0}}

  <h2>Demo 2 · Async</h2>
  {{playground:1}}

  <h2>Try it yourself</h2>
  <p>Exercise: use <code>any</code> to check if anything in the cart costs more than 10.</p>
  {{playground:2}}

  <div class="callout">
    <strong>Related:</strong>
    <a href="every.html"><code>every</code></a> — the "all of them" counterpart ·
    <a href="includes.html"><code>includes</code></a> — a specialization of <code>any</code> ·
    <a href="find.html"><code>find</code></a> — get the matching element, not just a bool ·
    <a href="predicates.html"><code>predicates</code></a> — ready-made predicates to pair with <code>any</code>
  </div>
