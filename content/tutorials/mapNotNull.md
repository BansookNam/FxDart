---
slug: mapNotNull
title: mapNotNull — FxDart 101
description: FxDart mapNotNull and firstNotNullOf tutorial: transform and filter in one lazy stage, where a null from the callback means skip — with a live playground.
heading: <code>mapNotNull</code> · <code>firstNotNullOf</code>
section: 3
crumb: mapNotNull
prev: attach.html
prevLabel: attach
next: filter.html
nextLabel: where
---
  <p class="hero-sub">Transform and filter in one step — the callback returns the new value, or <code>null</code> to skip.</p>

  {{signature}}

  <h2>Lecture</h2>
  <p>
    A lot of mapping is <em>partial</em>: parse a string that may not be a
    number, look up a key that may be missing. The long-hand is a
    <code>where</code> that runs the work to test it and a
    <code>map</code> that runs it again to keep it, or
    <code>fxCompact(fxMap(f, xs))</code>, which stacks two lazy stages.
    <code>mapNotNull(f, xs)</code> does both in one stage: <code>f</code>
    returns the new value, and a <code>null</code> result means
    <em>skip this element</em>. <code>f</code> runs once per element, and
    only when the element is pulled.
  </p>
  <p>
    The result type <code>B</code> is bound to <code>Object</code>, so
    <code>mapNotNull(int.tryParse, xs)</code> is an
    <code>Iterable&lt;int&gt;</code>, not <code>int?</code> — a
    <code>null</code> can never mean <em>yield null</em>.
    <code>firstNotNullOf(f, xs)</code> is the same idea as a terminal: it
    returns the first non-null result of <code>f</code> and stops
    there, or <code>null</code> when every result is <code>null</code> (or
    the input is empty). Where <code><a href="find.html">find</a></code>
    returns the <em>element</em> that matched,
    <code>firstNotNullOf</code> returns the projection — no second call to
    get at it.
  </p>
  <p>
    The async twins are <code>mapNotNullAsync</code> and
    <code>firstNotNullOfAsync</code>; <code>f</code> may return a
    <code>Future</code>. <code>mapNotNullAsync</code> is built on the
    parallel-safe <code>fxMapAsync</code>, so
    <code><a href="concurrent.html">concurrent(n)</a></code> runs
    <em>n</em> callbacks at once; <code>firstNotNullOfAsync</code> pulls one
    element at a time and cancels the source at the first hit. On the chain
    they are <code>fx(xs).mapNotNull(f)</code> and
    <code>fx(xs).firstNotNullOf(f)</code>. Dart-native addition (not part of
    FxTS) — Kotlin's <code>mapNotNull</code> and
    <code>firstNotNullOfOrNull</code>, Rust's <code>filter_map</code>.
  </p>

  <h2>Demo 1 · Parse what parses</h2>
  {{playground:0}}

  <h2>Demo 2 · Async lookups that may miss</h2>
  {{playground:1}}

  <h2>Try it yourself</h2>
  <p>Exercise: stop parsing every answer twice.</p>
  {{playground:2}}

  <div class="callout">
    <strong>Related:</strong>
    <a href="map.html"><code>map</code></a> — when every element has a result ·
    <a href="filter.html"><code>where</code></a> — keep elements, unchanged ·
    <a href="compact.html"><code>nonNulls</code></a> — drop the nulls already there ·
    <a href="find.html"><code>find</code></a> — the first matching element, not its projection
  </div>
