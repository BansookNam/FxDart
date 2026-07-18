---
slug: omit
title: omit — FxDart 101
description: FxDart omit tutorial: return a copy of a Map without the given keys, leaving the original untouched.
heading: <code>omit</code>
section: 9
crumb: omit
prev: fromEntries.html
prevLabel: fromEntries
next: pick.html
nextLabel: pick
---
  <p class="hero-sub">Returns a copy of a <code>Map</code> without the given keys.</p>

  {{signature}}

  <h2>Lecture</h2>
  <p>
    <code>omit</code> builds a brand-new <code>Map</code> containing every
    entry of the original <em>except</em> the keys you list — the source
    map is never mutated. Keys in <code>keysToOmit</code> that don't
    actually exist in the map are simply ignored; there's no error for
    "extra" keys to remove.
  </p>
  <p>
    It's a common redaction/serialization tool: strip a password hash before
    logging a user object, drop an internal field before sending a response,
    and so on. Pair it with <code>map()</code> to redact a whole list of
    maps at once.
  </p>

  <h2>Demo 1 · Basics</h2>
  {{playground:0}}

  <h2>Demo 2 · Redacting a whole list</h2>
  {{playground:1}}

  <h2>Try it yourself</h2>
  <p>Exercise: use <code>omit</code> to drop the <code>'debug'</code> key from <code>config</code>.</p>
  {{playground:2}}

  <div class="callout">
    <strong>Related:</strong>
    <a href="pick.html"><code>pick</code></a> — the inverse: keep only some keys ·
    <a href="omitBy.html"><code>omitBy</code></a> — drop by predicate instead of key list ·
    <a href="compactObject.html"><code>compactObject</code></a> — drop null-valued keys ·
    <a href="fromEntries.html"><code>fromEntries</code></a> — build a Map from scratch
  </div>
