---
slug: props
title: props — FxDart 101
description: FxDart props tutorial: read several Map keys at once as a List, missing keys become null.
heading: <code>props</code>
section: 9
crumb: props
prev: prop.html
prevLabel: prop
next: evolve.html
nextLabel: evolve
---
  <p class="hero-sub">Returns the values of several keys in a <code>Map</code>, as a <code>List</code>.</p>

  {{signature}}

  <h2>Lecture</h2>
  <p>
    <code>props</code> is <code>prop</code> applied to several keys at once,
    in order: give it a list of keys and a map, and get back a
    <code>List&lt;V?&gt;</code> with one slot per requested key. Unlike
    <a href="pick.html"><code>pick</code></a>, a missing key does not get
    dropped from the result — it becomes <code>null</code> in that
    position, so the output <code>List</code> always has the same length as
    <code>propKeys</code>. That positional guarantee is what makes it pair
    so well with Dart's list-destructuring pattern.
  </p>

  <h2>Demo 1 · Basics</h2>
  {{playground:0}}

  <h2>Demo 2 · Destructuring the result</h2>
  {{playground:1}}

  <h2>Try it yourself</h2>
  <p>Exercise: use <code>props</code> to pull <code>['first', 'last']</code> out of <code>row</code> as a <code>List</code>.</p>
  {{playground:2}}

  <div class="callout">
    <strong>Related:</strong>
    <a href="prop.html"><code>prop</code></a> — a single key at a time ·
    <a href="pick.html"><code>pick</code></a> — the Map-shaped equivalent ·
    <a href="fromEntries.html"><code>fromEntries</code></a> — build a Map back up ·
    <a href="evolve.html"><code>evolve</code></a> — transform selected values in place
  </div>
