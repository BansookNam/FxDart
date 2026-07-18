---
slug: pick
title: pick — FxDart 101
description: FxDart pick tutorial: return a copy of a Map with only the given keys, missing keys simply absent.
heading: <code>pick</code>
section: 9
crumb: pick
prev: omit.html
prevLabel: omit
next: omitBy.html
nextLabel: omitBy
---
  <p class="hero-sub">Returns a copy of a <code>Map</code> with only the given keys.</p>

  {{signature}}

  <h2>Lecture</h2>
  <p>
    <code>pick</code> is <code>omit</code>'s mirror: instead of listing what
    to remove, you list what to keep. Requested keys that aren't present in
    the source map are simply absent from the result — <code>pick</code>
    does not insert them with a <code>null</code> placeholder, so the
    result's key set can be smaller than <code>keysToPick</code>.
  </p>
  <p>
    Reach for it whenever you want a narrow "view" of a larger map: a public
    API response derived from an internal record, a summary row derived
    from a full one, and so on.
  </p>

  <h2>Demo 1 · Basics</h2>
  {{playground:0}}

  <h2>Demo 2 · Slimming a whole list</h2>
  {{playground:1}}

  <h2>Try it yourself</h2>
  <p>Exercise: use <code>pick</code> to keep only <code>'id'</code> and <code>'email'</code> from <code>profile</code>.</p>
  {{playground:2}}

  <div class="callout">
    <strong>Related:</strong>
    <a href="omit.html"><code>omit</code></a> — the inverse: drop only some keys ·
    <a href="pickBy.html"><code>pickBy</code></a> — keep by predicate instead of key list ·
    <a href="props.html"><code>props</code></a> — pull several values out as a List ·
    <a href="prop.html"><code>prop</code></a> — pull a single value out
  </div>
