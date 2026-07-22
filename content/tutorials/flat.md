---
slug: flat
title: flattened — FxDart 101
description: FxDart flattened tutorial: flatten nested iterables by a given depth, with a live playground.
heading: <code>flattened</code>
section: 3
crumb: flattened
prev: flatMap.html
prevLabel: flatMap
next: scan.html
nextLabel: scan
---
  <p class="hero-sub">Flattens nested iterables by a given depth — strings are left alone.</p>

  {{signature}}

  <h2>Lecture</h2>
  <p>
    <code>flattened</code> walks a nested structure of iterables and splices
    inner elements into the outer sequence, up to <code>depth</code> levels
    deep (default <code>1</code>). Anything that is an <code>Iterable</code>
    counts as "flattenable" <em>except</em> <code>String</code> — so
    <code>flattened(['ab', ['cd']])</code> keeps <code>'ab'</code> intact instead
    of exploding it into characters. <code>flattened</code> is the
    Dart-idiomatic name; fxdart also accepts the FxTS spelling <code>flat</code>
    — they're the same operator.
  </p>
  <p>
    <strong>Why <code>Iterable&lt;dynamic&gt;</code>, and why that's okay:</strong>
    TypeScript's <code>flat</code> has a <code>DeepFlat</code> conditional
    type that can describe "the element type after flattening N levels."
    Dart's type system has no equivalent mechanism — the input's nesting
    shape isn't known until runtime, so there is no sound way to compute a
    static element type. Rather than lie with a generic that doesn't hold,
    the Dart port is honest about it and returns <code>Iterable&lt;dynamic&gt;</code>.
    If you know the shape of what you're flattening and want a typed
    result, reach for <a href="flatMap.html"><code>flatMap</code></a>
    instead: <code>flatMap((row) =&gt; row, matrix)</code> gives you a typed
    flatten for exactly-one-level-deep, uniformly-shaped data.
  </p>
  <p>
    Like <code>flat</code> in FxTS, <code>flattenedAsync</code> only recurses
    into nesting that is already a <em>synchronous</em> <code>Iterable</code>
    by the time it arrives — it does not await a <code>Future</code> buried
    inside a nested collection. Combine it with an upstream
    <code>.map(...).concurrent(n)</code> stage to fetch nested lists in
    parallel, then let <code>.flattened()</code> splice the already-resolved
    results together.
  </p>

  <h2>Demo 1 · Basics &amp; depth</h2>
  {{playground:0}}

  <h2>Demo 2 · Async, with concurrency</h2>
  <p>
    Fetch the (already nested) results concurrently, then flatten the
    resolved lists:
  </p>
  {{playground:1}}

  <h2>Try it yourself</h2>
  <p>Exercise: use <code>flattened()</code> to flatten <code>scoreGroups</code>
    by one level.</p>
  {{playground:2}}

  <div class="callout">
    <strong>Related:</strong>
    <a href="flatMap.html"><code>flatMap</code></a> — typed map + flatten in one step ·
    <a href="map.html"><code>map</code></a> — transform without flattening ·
    <a href="scan.html"><code>scan</code></a> — running accumulation ·
    <a href="concurrent.html"><code>concurrent</code></a> — parallel evaluation
  </div>
