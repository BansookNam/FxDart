---
slug: prop
title: prop — FxDart 101
description: FxDart prop tutorial: read a single Map key as a tear-off-friendly function, null on a miss.
heading: <code>prop</code>
section: 9
crumb: prop
prev: pickBy.html
prevLabel: pickBy
next: props.html
nextLabel: props
---
  <p class="hero-sub">Returns the value of a key in a <code>Map</code>, or <code>null</code> when it's missing.</p>

  {{signature}}

  <h2>Lecture</h2>
  <p>
    On its own, <code>prop('name', user)</code> does exactly what
    <code>user['name']</code> already does in Dart — a missing key yields
    <code>null</code> either way. The reason it exists as a function at all
    is composability: <code>map[key]</code> is an operator, not a value you
    can pass around, but <code>(m) => prop('name', m)</code> is a plain
    unary function you can hand to <code>map</code>, <code>juxt</code>,
    <code>evolve</code>'s callbacks, or anywhere else a
    <code>Function(Map)</code> is expected.
  </p>
  <p>
    If what you actually want is one field pulled out of a whole <em>list</em>
    of maps, reach for <a href="pluck.html"><code>pluck</code></a> instead —
    it's <code>prop</code> already bound to a key and mapped over a
    collection in one call.
  </p>

  <h2>Demo 1 · Basics</h2>
  {{playground:0}}

  <h2>Demo 2 · As a tear-off, vs. <code>pluck</code></h2>
  {{playground:1}}

  <h2>Try it yourself</h2>
  <p>Exercise: use <code>prop</code> to read <code>'theme'</code>, or <code>'light'</code> if it's missing.</p>
  {{playground:2}}

  <div class="callout">
    <strong>Related:</strong>
    <a href="props.html"><code>props</code></a> — read several keys at once ·
    <a href="pluck.html"><code>pluck</code></a> — <code>prop</code> mapped over a whole list ·
    <a href="pick.html"><code>pick</code></a> — keep several keys as a Map ·
    <a href="evolve.html"><code>evolve</code></a> — transform a value in place
  </div>
