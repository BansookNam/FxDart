---
slug: throwError
title: throwError — FxDart 101
description: FxDart throwError tutorial: turn an error-throwing action into a reusable unary function, with a live playground.
heading: <code>throwError</code>
section: 10
crumb: throwError
prev: unless.html
prevLabel: unless
next: throwIf.html
nextLabel: throwIf
---
  <p class="hero-sub">Returns a unary function that always throws — for slots that expect a function, not a statement.</p>

  {{signature}}

  <h2>Lecture</h2>
  <p>
    <code>throw</code> is a statement in Dart, so you can't drop it directly
    into a spot that expects a function value. <code>throwError(toError)</code>
    solves that: give it a function that builds an <code>Object</code> (an
    exception or error) from the offending value, and you get back a
    <code>Never Function(T)</code> you can pass anywhere a callback is
    expected — most commonly as the <code>orElse</code> of
    <a href="cases.html"><code>cases</code></a>, to turn "nothing matched"
    into a hard failure instead of a silent fallback.
  </p>
  <p>
    Because the return type is <code>Never</code>, calling it always throws;
    it never actually returns a value of type <code>T</code>. Wrap any call
    site in <code>try</code>/<code>catch</code> if you want to recover
    instead of letting the error propagate.
  </p>

  <h2>Demo 1 · Basics</h2>
  {{playground:0}}

  <h2>Demo 2 · As the fallback of cases</h2>
  <p>
    Instead of silently falling through, <code>throwError</code> makes an
    unmatched value a loud, catchable failure:
  </p>
  {{playground:1}}

  <h2>Try it yourself</h2>
  <p>Exercise: build a throwing function for "not implemented" and trigger it.</p>
  {{playground:2}}

  <div class="callout">
    <strong>Related:</strong>
    <a href="throwIf.html"><code>throwIf</code></a> — throw conditionally, without a separate builder function ·
    <a href="cases.html"><code>cases</code></a> — the usual home for throwError as orElse ·
    <a href="when.html"><code>when</code></a> / <a href="unless.html"><code>unless</code></a> — conditional transforms that don't throw ·
    <a href="find.html"><code>find</code></a> — returns null instead of throwing on no match
  </div>
