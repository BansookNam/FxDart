---
slug: entries
title: entries — FxDart 101
description: FxDart entries tutorial: turn a Map's (key, value) pairs into a lazy iterable of records, ready to chain.
heading: <code>entries</code>
section: 2
crumb: entries
prev: cycle.html
prevLabel: cycle
next: keys.html
nextLabel: keys
---
  <p class="hero-sub">Yields a Map's (key, value) pairs as records — the entry point for chaining over a Map.</p>

  {{signature}}

  <h2>Lecture</h2>
  <p>
    A Dart <code>Map</code> isn't an <code>Iterable</code> the way a
    <code>List</code> is, so there's no <code>fx(someMap)</code> directly.
    <code>entries</code> is the bridge: it yields each key/value pair of the
    map as a <code>(K, V)</code> record, giving you a plain lazy
    <code>Iterable</code> you <em>can</em> wrap with <code>fx()</code> and
    chain like anything else. This mirrors FxTS's <code>entries</code>,
    which does the same for a JS object.
  </p>
  <p>
    Because the pairs are Dart records, you can destructure them directly
    in a <code>for</code> loop — <code>for (final (key, value) in
    entries(map))</code> — or access the positional fields
    <code>.$1</code> (key) and <code>.$2</code> (value) inside a
    <code>map</code>/<code>filter</code> callback when destructuring isn't
    convenient.
  </p>
  <p>
    <code>entries</code> is lazy like everything else here, but a
    <code>Map</code>'s entries aren't infinite, so there's rarely a reason
    to bound it with <code>take</code> — it's more about turning a Map into
    something chainable than about controlling how much gets pulled.
  </p>

  <h2>Demo 1 · Basics</h2>
  {{playground:0}}

  <h2>Demo 2 · Chaining over a Map</h2>
  <p>Wrap <code>entries(map)</code> with <code>fx()</code> to filter and
    reshape a Map's contents:</p>
  {{playground:1}}

  <h2>Try it yourself</h2>
  <p>Exercise: turn a Map of scores into "name: PASS/FAIL" strings.</p>
  {{playground:2}}

  <div class="callout">
    <strong>Related:</strong>
    <a href="keys.html"><code>keys</code></a> — just the keys of a Map ·
    <a href="values.html"><code>values</code></a> — just the values of a Map ·
    <a href="fromEntries.html"><code>fromEntries</code></a> — the inverse: build a Map back from pairs ·
    <a href="fx.html"><code>fx</code></a> — the chain entries results feed into
  </div>
