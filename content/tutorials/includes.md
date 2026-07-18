---
slug: includes
title: includes — FxDart 101
description: FxDart includes tutorial: check membership in an iterable with ==, short-circuiting, sync and async.
heading: <code>includes</code>
section: 8
crumb: includes
prev: findIndex.html
prevLabel: findIndex
next: isEmpty.html
nextLabel: isEmpty
---
  <p class="hero-sub">Returns true when an iterable contains a value, compared with <code>==</code>.</p>

  {{signature}}

  <h2>Lecture</h2>
  <p>
    <code>includes</code> is a thin, FxTS-shaped wrapper: on the sync side
    it's literally <code>iterable.contains(a)</code>, so there's no separate
    chain method — <code>Fx</code> already inherits <code>.contains()</code>
    from <code>Iterable</code>, and it behaves identically. The async
    version, <code>includesAsync</code>, is built on top of
    <a href="some.html"><code>someAsync</code></a> (<code>b == a</code> as
    the predicate), which means it inherits the same short-circuiting: it
    stops pulling from the source the moment it finds a match.
  </p>
  <p>
    Equality is checked with Dart's <code>==</code>, so it respects any
    <code>operator ==</code> override on your own classes — it isn't limited
    to primitives.
  </p>

  <h2>Demo 1 · Basics</h2>
  {{playground:0}}

  <h2>Demo 2 · Async, and proof it short-circuits</h2>
  <p>Only 2 of 5 elements are pulled before <code>includesAsync</code> stops:</p>
  {{playground:1}}

  <h2>Try it yourself</h2>
  <p>Exercise: use <code>includes</code> to check whether <code>requestId</code> is allowed.</p>
  {{playground:2}}

  <div class="callout">
    <strong>Related:</strong>
    <a href="some.html"><code>some</code></a> — what <code>includesAsync</code> is built from ·
    <a href="find.html"><code>find</code></a> — get the matching value, not just a bool ·
    <a href="findIndex.html"><code>findIndex</code></a> — get the position instead ·
    <a href="isEmpty.html"><code>isEmpty</code></a> — the other value-based check nearby
  </div>
