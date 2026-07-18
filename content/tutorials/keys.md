---
slug: keys
title: keys — FxDart 101
description: FxDart keys tutorial: a lazy Iterable of a Map's keys, ready to feed into a chain.
heading: <code>keys</code>
section: 2
crumb: keys
prev: entries.html
prevLabel: entries
next: values.html
nextLabel: values
---
  <p class="hero-sub">The keys of a Map, as a plain lazy Iterable — ready to wrap in fx() and chain.</p>

  {{signature}}

  <h2>Lecture</h2>
  <p>
    <code>keys(map)</code> is a thin, FxTS-flavored wrapper around Dart's
    own <code>map.keys</code> — it exists mainly so the object-function
    vocabulary (<code>entries</code>, <code>keys</code>, <code>values</code>)
    reads consistently and slots straight into <code>fx()</code>. Dart's
    <code>Map.keys</code> is already a lazy view, so <code>keys</code>
    doesn't add any extra buffering — it just hands you the same lazy
    <code>Iterable&lt;K&gt;</code>.
  </p>
  <p>
    Reach for it when you want to filter, transform, or collect a Map's key
    set using the rest of the chain vocabulary, rather than reaching for
    <code>.where()</code>/<code>.toList()</code> on <code>map.keys</code>
    directly — the two are equivalent, but <code>fx(keys(map))</code> reads
    naturally next to <code>fx(values(map))</code> and
    <code>fx(entries(map))</code>.
  </p>
  <p>
    If you need the keys <em>and</em> values together, use
    <code>entries</code> instead — pulling <code>keys</code> and
    <code>values</code> separately does not guarantee they line up if the
    underlying map were mutated between the two calls.
  </p>

  <h2>Demo 1 · Basics</h2>
  {{playground:0}}

  <h2>Demo 2 · Filtering a Map by its keys</h2>
  {{playground:1}}

  <h2>Try it yourself</h2>
  <p>Exercise: use <code>keys</code> and <code>sort</code> to get an
    alphabetically sorted list of item names.</p>
  {{playground:2}}

  <div class="callout">
    <strong>Related:</strong>
    <a href="entries.html"><code>entries</code></a> — keys and values paired together ·
    <a href="values.html"><code>values</code></a> — the values of a Map ·
    <a href="pick.html"><code>pick</code></a> — build a new Map from a subset of keys ·
    <a href="fx.html"><code>fx</code></a> — the chain keys results feed into
  </div>
