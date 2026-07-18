---
slug: not
title: not — FxDart 101
description: FxDart not tutorial: boolean negation as a function value you can pass around, with a live playground.
heading: <code>not</code>
section: 10
crumb: not
prev: negate.html
prevLabel: negate
next: when.html
nextLabel: when
---
  <p class="hero-sub">Boolean negation as a function you can pass around.</p>

  {{signature}}

  <h2>Lecture</h2>
  <p>
    <code>not</code> does exactly what <code>!a</code> does — it just does it
    as a first-class function, so it can be passed where a
    <code>bool Function(bool)</code> is expected instead of you writing
    <code>(b) =&gt; !b</code> yourself. FxTS's <code>not</code> works on
    JavaScript "truthy" values of any type; Dart has no implicit truthiness,
    so the Dart port only accepts an actual <code>bool</code>.
  </p>
  <p>
    Because its signature is <code>bool -&gt; bool</code>, <code>not</code>
    doubles as a predicate itself wherever the element type is already
    <code>bool</code> — see <code>some</code>/<code>every</code> in Demo 2.
    For negating an arbitrary predicate over some other type, use
    <a href="negate.html"><code>negate</code></a> instead.
  </p>

  <h2>Demo 1 · Basics</h2>
  {{playground:0}}

  <h2>Demo 2 · As a predicate over booleans</h2>
  <p>
    <code>not</code> is itself a <code>bool Function(bool)</code>, so it
    plugs straight into <code>some</code>/<code>every</code> without wrapping:
  </p>
  {{playground:1}}

  <h2>Try it yourself</h2>
  <p>Exercise: use <code>not</code> to build the list of "still pending"
    flags from a list of "done" flags.</p>
  {{playground:2}}

  <div class="callout">
    <strong>Related:</strong>
    <a href="negate.html"><code>negate</code></a> — negate a whole predicate function, not just a bool ·
    <a href="some.html"><code>some</code></a> / <a href="every.html"><code>every</code></a> — used with not above ·
    <a href="when.html"><code>when</code></a> — conditional transform ·
    <a href="unless.html"><code>unless</code></a> — the inverse-condition sibling of when
  </div>
