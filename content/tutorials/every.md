---
slug: every
title: every — FxDart 101
description: FxDart every tutorial: check that every element satisfies a predicate, short-circuiting on the first failure, sync and async.
heading: <code>every</code>
section: 8
crumb: every
prev: isEmpty.html
prevLabel: isEmpty
next: some.html
nextLabel: some
---
  <p class="hero-sub">True when every element satisfies a predicate — vacuously true for an empty iterable.</p>

  {{signature}}

  <h2>Lecture</h2>
  <p>
    <code>every</code> scans left to right and bails out — short-circuits —
    the instant it finds an element that fails the predicate, returning
    <code>false</code> right there without touching the rest of the
    iterable. If nothing fails (including the case where there's nothing at
    all), it returns <code>true</code>: an empty iterable vacuously
    satisfies "every element is X."
  </p>
  <p>
    On the sync chain there's no dedicated <code>Fx.every</code> — it isn't
    needed, since <code>Fx</code> already inherits Dart's own
    <code>Iterable.every</code>, which has exactly this short-circuiting
    behavior. The async chain does define its own <code>.every()</code>,
    because it has to <code>await</code> each predicate call.
  </p>

  <h2>Demo 1 · Basics &amp; short-circuiting</h2>
  <p>The peek counter stops at 3, not 4 — evaluation halts right at the first failure:</p>
  {{playground:0}}

  <h2>Demo 2 · Async</h2>
  {{playground:1}}

  <h2>Try it yourself</h2>
  <p>Exercise: use <code>every</code> to check whether everyone passed (score &gt;= 60).</p>
  {{playground:2}}

  <div class="callout">
    <strong>Related:</strong>
    <a href="some.html"><code>some</code></a> — the "at least one" counterpart ·
    <a href="filter.html"><code>filter</code></a> — collect every match instead of a bool ·
    <a href="find.html"><code>find</code></a> — get the first failing/matching element ·
    <a href="predicates.html"><code>predicates</code></a> — ready-made predicates to pair with <code>every</code>
  </div>
