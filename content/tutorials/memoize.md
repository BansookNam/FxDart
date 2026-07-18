---
slug: memoize
title: memoize — FxDart 101
description: FxDart memoize tutorial: cache a unary function's results by argument, sync and async, with a live playground.
heading: <code>memoize</code>
section: 10
crumb: memoize
prev: juxt.html
prevLabel: juxt
next: negate.html
nextLabel: negate
---
  <p class="hero-sub">Caches a unary function's results, keyed by its argument.</p>

  {{signature}}

  <h2>Lecture</h2>
  <p>
    <code>memoize(f)</code> wraps <code>f</code> in a cache: the first time
    it's called with a given argument, it runs <code>f</code> and remembers
    the result; every later call with an <code>==</code>-equal argument
    returns the cached result instantly, without calling <code>f</code>
    again. Reach for it when <code>f</code> is expensive (heavy computation,
    a network call) and is likely to be called repeatedly with the same
    inputs.
  </p>
  <p>
    FxDart's <code>memoize</code> is <strong>unary only</strong> and keys the
    cache by the argument's <code>==</code>/<code>hashCode</code>. FxTS's
    version is variadic and keys on the full argument list via a
    <code>WeakMap</code>-backed cache — Dart has no direct equivalent (no
    variadic generics, and <code>WeakMap</code>-style weak keys aren't
    available for arbitrary objects), so multi-argument functions need to be
    memoized on a single composite key (a record works well) instead.
  </p>
  <p>
    Because <code>R</code> is unconstrained, <code>f</code> can return a
    <code>Future</code> — memoizing an async operation caches the
    <em>Future itself</em>, so a second call returns an already-completed
    future immediately rather than re-running the work.
  </p>

  <h2>Demo 1 · Basics</h2>
  {{playground:0}}

  <h2>Demo 2 · Memoizing an async lookup</h2>
  <p>
    The second call to <code>fetchUser(1)</code> returns the cached,
    already-completed <code>Future</code> — no 150ms wait:
  </p>
  {{playground:1}}

  <h2>Try it yourself</h2>
  <p>Exercise: wrap this "slow" cubing function with <code>memoize</code> so
    that calling it twice with <code>3</code> only runs the real computation once.</p>
  {{playground:2}}

  <div class="callout">
    <strong>Related:</strong>
    <a href="delay.html"><code>delay</code> &amp; <code>sleep</code></a> — used above to simulate a slow async call ·
    <a href="debounce.html"><code>debounce</code></a> — rate-limit calls instead of caching them ·
    <a href="identity.html"><code>identity</code></a> — the simplest possible function to wrap ·
    <a href="always.html"><code>always</code></a> — a constant value, no caching needed
  </div>
