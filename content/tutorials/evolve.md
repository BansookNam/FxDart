---
slug: evolve
title: evolve — FxDart 101
description: FxDart evolve tutorial: transform selected Map values by key, leaving the rest untouched.
heading: <code>evolve</code>
section: 9
crumb: evolve
prev: props.html
prevLabel: props
next: compactObject.html
nextLabel: compactObject
---
  <p class="hero-sub">Runs selected values through per-key transformation functions, leaving the rest of the <code>Map</code> as-is.</p>

  {{signature}}

  <h2>Lecture</h2>
  <p>
    <code>evolve</code> takes a "recipe" map — key to transformation
    function — and a data map, and produces a new map where every key that
    appears in the recipe has its value passed through the matching
    function; every other key is copied through unchanged.
  </p>
  <p>
    Notice the signature is deliberately loose: both maps are typed with
    <code>Object?</code> values, mirroring FxTS's dynamically-typed
    original. That means your transformation functions receive
    <code>Object?</code> and must cast (<code>v as String</code>,
    <code>v as int</code>, …) before doing anything type-specific — a
    small tax for the flexibility of applying different transformations to
    different value types within a single map. If you know the shape of
    your data ahead of time and don't need per-key heterogeneity, a plain
    <code>{...map, 'key': f(map['key'])}</code> spread is often more
    idiomatic Dart; reach for <code>evolve</code> when the recipe itself is
    data (e.g. built once and reused across many maps).
  </p>

  <h2>Demo 1 · Basics</h2>
  {{playground:0}}

  <h2>Demo 2 · Parsing raw string fields</h2>
  {{playground:1}}

  <h2>Try it yourself</h2>
  <p>Exercise: use <code>evolve</code> to double the <code>'price'</code> field and leave <code>'title'</code> untouched.</p>
  {{playground:2}}

  <div class="callout">
    <strong>Related:</strong>
    <a href="prop.html"><code>prop</code></a> — read a single value out ·
    <a href="omitBy.html"><code>omitBy</code></a> — drop entries instead of transforming them ·
    <a href="compactObject.html"><code>compactObject</code></a> — a specialized cleanup pass ·
    <a href="resolveProps.html"><code>resolveProps</code></a> — the async cousin, awaiting instead of transforming
  </div>
