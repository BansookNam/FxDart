---
slug: asyncVariants
title: async variants — FxDart 101
description: FxDart's *Async naming convention: every lazy and aggregate operator has a twin for FxAsyncIterable, with a live playground.
heading: The <code>*Async</code> naming convention
section: 11
crumb: async variants
next: streams.html
nextLabel: streams
---
  <p class="hero-sub">Every lazy and aggregate operator has a twin that works on FxAsyncIterable — same behavior, async-friendly callback.</p>

  {{signature}}

  <h2>Lecture</h2>
  <p>
    Because Dart has no untyped currying, FxDart can't overload one
    <code>map</code> to work on both <code>Iterable</code> and
    <code>FxAsyncIterable</code> in data-first position — the parameter types
    would collide. So every lazy and aggregate operator ships in two
    top-level forms: the plain one for <code>Iterable</code>, and an
    <code>*Async</code> twin for <code>FxAsyncIterable</code> whose callback
    returns <code>FutureOr&lt;R&gt;</code> instead of <code>R</code>. You've
    already met a few: <code>map</code>/<code>mapAsync</code>,
    <code>filter</code>/<code>filterAsync</code>,
    <code>toArray</code>/<code>toArrayAsync</code>,
    <code>reduce</code>/<code>reduceAsync</code>, <code>fold</code>/<code>foldAsync</code>,
    <code>each</code>/<code>eachAsync</code>, <code>find</code>/<code>findAsync</code> —
    the pattern holds for essentially every function in the library.
  </p>
  <p>
    The chain forms don't need this split. Once you call
    <code>.toAsync()</code> (or start from <code>fxAsync</code>/<code>fxStream</code>),
    every subsequent method on that <code>FxAsync</code> chain keeps its
    <strong>plain</strong> name — <code>.map(...)</code>, not
    <code>.mapAsync(...)</code> — because the receiver's type already tells
    Dart which overload to use. The suffix only exists at the top level,
    where data-first calls need it to disambiguate.
  </p>

  <h2>Demo 1 · A few twins, side by side</h2>
  <p>Data-first calls always need the <code>Async</code> suffix once you're
    working with an <code>FxAsyncIterable</code>:</p>
  {{playground:0}}

  <h2>Demo 2 · Data-first vs. chain form</h2>
  <p>
    The chain form reads the same as its sync counterpart — no suffixes —
    once <code>.toAsync()</code> has switched the receiver's type:
  </p>
  {{playground:1}}

  <h2>Try it yourself</h2>
  <p>Exercise: use the data-first <code>*Async</code> twin of <code>map</code>
    to uppercase every name in this async pipeline.</p>
  {{playground:2}}

  <div class="callout">
    <strong>Related:</strong>
    <a href="toAsync.html"><code>toAsync</code></a> — where async pipelines start ·
    <a href="streams.html">Stream bridges</a> — fromStream, fxStream, toStream ·
    <a href="concurrent.html"><code>concurrent</code></a> — parallel evaluation ·
    <a href="map.html"><code>map</code></a> — the sync original
  </div>
