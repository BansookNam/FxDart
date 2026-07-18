---
slug: values
title: values — FxDart 101
description: FxDart values tutorial: a lazy Iterable of a Map's values, ready to feed into a chain.
heading: <code>values</code>
section: 2
crumb: values
prev: keys.html
prevLabel: keys
next: map.html
nextLabel: map
---
  <p class="hero-sub">The values of a Map, as a plain lazy Iterable — ready to wrap in fx() and chain.</p>

  {{signature}}

  <h2>Lecture</h2>
  <p>
    <code>values(map)</code> is <code>keys</code>'s twin: a thin wrapper
    around Dart's <code>map.values</code>, given a name consistent with the
    rest of the object-function vocabulary so it reads naturally as
    <code>fx(values(map))</code> next to <code>fx(keys(map))</code> and
    <code>fx(entries(map))</code>. Like <code>map.values</code> itself,
    it's already a lazy view — no extra buffering happens.
  </p>
  <p>
    Because it hands back a plain <code>Iterable&lt;V&gt;</code>, every
    chain operator you've learned so far applies directly — including the
    numeric terminals (<code>sum()</code>, <code>average()</code>,
    <code>min()</code>, <code>max()</code>) when <code>V</code> is a
    <code>num</code>. This makes <code>values</code> the natural entry
    point for aggregating a Map's data: total up prices, average scores,
    find the newest timestamp, and so on.
  </p>
  <p>
    This is also the last stop before <code>map</code> itself — the next
    lesson, and the operator you'll reach for constantly from here on to
    reshape whatever <code>values</code>, <code>entries</code>, or any
    other source hands you.
  </p>

  <h2>Demo 1 · Basics</h2>
  {{playground:0}}

  <h2>Demo 2 · Aggregating a Map's values</h2>
  {{playground:1}}

  <h2>Try it yourself</h2>
  <p>Exercise: use <code>values</code> to compute the average score.</p>
  {{playground:2}}

  <div class="callout">
    <strong>Related:</strong>
    <a href="keys.html"><code>keys</code></a> — the keys of a Map ·
    <a href="entries.html"><code>entries</code></a> — keys and values paired together ·
    <a href="map.html"><code>map</code></a> — reshape every value in a chain ·
    <a href="sum.html"><code>sum · average · min · max</code></a> — the numeric terminals used above
  </div>
