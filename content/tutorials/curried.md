---
slug: curried
title: curried &amp; uncurried — FxDart 101
description: FxDart curried tutorial: fully typed currying via extension getters — the Dart-native replacement for FxTS curry, with a live playground.
heading: <code>.curried</code> &amp; <code>.uncurried</code>
section: 10
crumb: curried &amp; uncurried
prev: unicodeToArray.html
prevLabel: unicodeToArray
next: toAsync.html
nextLabel: toAsync
---
  <p class="hero-sub">Fully typed currying as extension getters — the Dart-native replacement for FxTS <code>curry</code>.</p>

  {{signature}}

  <h2>Lecture</h2>
  <p>
    Currying turns a function of several arguments into a chain of unary
    functions: <code>add(1, 2)</code> becomes <code>add.curried(1)(2)</code>.
    The payoff is <strong>partial application</strong> — fixing the first
    argument yields a new function, which is exactly the shape callbacks like
    <code>map</code> and <code>filter</code> want.
  </p>
  <p>
    FxTS ships this as a function, <code>curry(f)</code>, built on two things
    Dart doesn't have: runtime arity reflection (<code>fn.length</code>) and
    recursive conditional types. FxDart instead declares one extension per
    arity (2–5), all exposing the same <code>curried</code> getter, and lets
    the compiler pick the right one from the function's <em>static</em> type.
    The arity dispatch FxTS does at runtime happens at compile time — and the
    result is fully typed, with zero casts: <code>add.curried(1)</code>
    <em>is</em> an <code>int Function(int)</code>.
  </p>
  <p>
    <code>.uncurried</code> is the inverse: it flattens a chain of unary
    functions back into one multi-argument function. When a chain is nested
    deeper than two levels, the deepest matching arity wins; apply an
    extension explicitly (<code>Uncurry2(f).uncurried</code>) to flatten
    fewer levels. The full design story — including why the getter is named
    <code>curried</code> and not <code>curry</code> — is in
    <a href="https://github.com/BansookNam/FxDart/blob/main/WHY_CURRIED.md">WHY_CURRIED.md</a>.
  </p>

  <h2>Demo 1 · Basics</h2>
  {{playground:0}}

  <h2>Demo 2 · Partial application in a pipeline</h2>
  <p>
    A curried binary function slots straight into <code>map</code> — no
    wrapper closure needed:
  </p>
  {{playground:1}}

  <h2>Demo 3 · Round trip with <code>uncurried</code></h2>
  <p>
    Hand-written curried closures flatten back to the data-first shape, and
    <code>curried</code> / <code>uncurried</code> are exact inverses:
  </p>
  {{playground:2}}

  <h2>Try it yourself</h2>
  <p>Exercise: use <code>.curried</code> to build a <code>clampTo100</code>
    function from <code>clamp</code> below, then map it over the list.</p>
  {{playground:3}}

  <div class="callout">
    <strong>Note:</strong> the chain is strictly unary — FxTS's mixed
    application <code>add(1, 2)(3)</code> has no equivalent. Named/optional
    parameters and values typed as bare <code>Function</code> don't match the
    extensions; write a closure there. The deprecated top-level
    <code>curry</code> stub remains only to steer FxTS migrations here.
  </div>

  <div class="callout">
    <strong>Related:</strong>
    <a href="pipe.html"><code>pipe</code></a> — composition, the main consumer of partially applied functions ·
    <a href="identity.html"><code>identity</code></a> &amp; <a href="always.html"><code>always</code></a> — other function-shape helpers ·
    <a href="apply.html"><code>apply</code></a> — spread a list into positional arguments
  </div>
