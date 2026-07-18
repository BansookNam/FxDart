---
slug: fromEntries
title: fromEntries — FxDart 101
description: FxDart fromEntries tutorial: build a Map from (key, value) record entries, the inverse of entries().
heading: <code>fromEntries</code>
section: 9
crumb: fromEntries
prev: predicates.html
prevLabel: predicates
next: omit.html
nextLabel: omit
---
  <p class="hero-sub">Builds a <code>Map</code> from an iterable of <code>(key, value)</code> records.</p>

  {{signature}}

  <h2>Lecture</h2>
  <p>
    This section ports FxTS's object utilities, and the first thing to
    understand is the mapping: TypeScript's plain objects become Dart
    <code>Map</code>s throughout, and TS's <code>[key, value]</code> entry
    tuples become Dart <code>(K, V)</code> records. <code>fromEntries</code>
    is the constructor side of that: give it any iterable of records and it
    folds them into a <code>Map</code>, last-write-wins on duplicate keys —
    exactly like building the map by hand with a loop.
  </p>
  <p>
    It's the natural partner of <a href="entries.html"><code>entries</code></a>
    (which does the reverse: <code>Map</code> → records) and pairs nicely
    with <a href="zip.html"><code>zip</code></a>, which turns two parallel
    lists into exactly the record shape <code>fromEntries</code> wants.
  </p>

  <h2>Demo 1 · Basics</h2>
  {{playground:0}}

  <h2>Demo 2 · Duplicate keys, and round-tripping with <code>entries</code></h2>
  {{playground:1}}

  <h2>Try it yourself</h2>
  <p>Exercise: use <code>fromEntries</code> to turn <code>pairs</code> into a <code>Map</code>.</p>
  {{playground:2}}

  <div class="callout">
    <strong>Related:</strong>
    <a href="entries.html"><code>entries</code></a> — the reverse direction ·
    <a href="zip.html"><code>zip</code></a> — build entries from two parallel lists ·
    <a href="omit.html"><code>omit</code></a> — drop keys from the resulting Map ·
    <a href="pick.html"><code>pick</code></a> — keep only some keys
  </div>
