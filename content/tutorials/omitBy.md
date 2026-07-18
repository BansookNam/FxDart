---
slug: omitBy
title: omitBy — FxDart 101
description: FxDart omitBy tutorial: drop Map entries matching a (key, value) predicate.
heading: <code>omitBy</code>
section: 9
crumb: omitBy
prev: pick.html
prevLabel: pick
next: pickBy.html
nextLabel: pickBy
---
  <p class="hero-sub">Returns a copy of a <code>Map</code> without the entries matching a predicate.</p>

  {{signature}}

  <h2>Lecture</h2>
  <p>
    Where <code>omit</code> takes a fixed list of keys, <code>omitBy</code>
    takes a predicate and decides entry by entry. The predicate receives the
    whole entry as a <code>(K, V)</code> record, so you get both the key and
    the value to work with — read them as <code>e.$1</code> (key) and
    <code>e.$2</code> (value). This mirrors how <code>entries(map)</code>
    represents a <code>Map</code> throughout the rest of the library.
  </p>
  <p>
    Use it whenever the thing you want to drop is defined by a condition —
    "remove failing scores," "remove out-of-stock items" — rather than by a
    fixed set of key names.
  </p>

  <h2>Demo 1 · Basics</h2>
  {{playground:0}}

  <h2>Demo 2 · Dropping by value condition</h2>
  {{playground:1}}

  <h2>Try it yourself</h2>
  <p>Exercise: use <code>omitBy</code> to drop entries whose value is <code>false</code>.</p>
  {{playground:2}}

  <div class="callout">
    <strong>Related:</strong>
    <a href="pickBy.html"><code>pickBy</code></a> — the inverse: keep by predicate ·
    <a href="omit.html"><code>omit</code></a> — drop by a fixed key list ·
    <a href="isMatch.html"><code>isMatch</code></a> — a ready-made deep predicate for entries ·
    <a href="evolve.html"><code>evolve</code></a> — transform values instead of dropping them
  </div>
