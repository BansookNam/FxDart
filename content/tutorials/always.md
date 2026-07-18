---
slug: always
title: always — FxDart 101
description: FxDart always tutorial: build a function that ignores its argument and always returns a fixed value, with a live playground.
heading: <code>always</code>
section: 10
crumb: always
prev: identity.html
prevLabel: identity
next: tap.html
nextLabel: tap
---
  <p class="hero-sub">Returns a function that always returns the same fixed value, ignoring its argument.</p>

  {{signature}}

  <h2>Lecture</h2>
  <p>
    <code>always(a)</code> closes over <code>a</code> and hands back a
    function that discards whatever it's called with and returns <code>a</code>
    every time. The optional parameter is the trick that makes it fit
    anywhere a <em>unary</em> callback is expected — a mapper, an
    <code>orElse</code> handler, a fallback branch — without you writing
    <code>(_) => a</code> by hand each time.
  </p>
  <p>
    It's the constant counterpart to <a href="identity.html"><code>identity</code></a>:
    <code>identity</code> passes the input through, <code>always</code>
    throws it away. Both are plain synchronous functions with no async
    variant or chain form.
  </p>

  <h2>Demo 1 · Basics</h2>
  <p>Note the optional argument — <code>greet(123)</code> still returns
    <code>'hi'</code>, which is what lets it act as a <code>map</code> callback:</p>
  {{playground:0}}

  <h2>Demo 2 · Constant fallback in a dispatch table</h2>
  <p>
    <code>always</code> is a natural fit for <code>orElse</code> in
    <a href="cases.html"><code>cases</code></a> — a fixed default that
    doesn't need to look at the unmatched value:
  </p>
  {{playground:1}}

  <h2>Try it yourself</h2>
  <p>Exercise: use <code>always</code> to replace every score in this list
    with the string <code>'graded'</code>.</p>
  {{playground:2}}

  <div class="callout">
    <strong>Related:</strong>
    <a href="identity.html"><code>identity</code></a> — pass the argument through instead ·
    <a href="cases.html"><code>cases</code></a> — dispatch table that often pairs with always as orElse ·
    <a href="when.html"><code>when</code></a> — conditional transform, value-in value-out ·
    <a href="memoize.html"><code>memoize</code></a> — cache a computed value instead of a constant one
  </div>
