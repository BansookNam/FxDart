---
slug: dropWhile
title: dropWhile — FxDart 101
description: FxDart dropWhile tutorial: skip values while a predicate holds, then yield the rest, with a live playground.
heading: <code>dropWhile</code>
section: 5
crumb: dropWhile
prev: dropRight.html
prevLabel: dropRight
next: dropUntil.html
nextLabel: dropUntil
---
  <p class="hero-sub">Skips values while a predicate returns true, then yields everything after — matches or not.</p>

  {{signature}}

  <h2>Lecture</h2>
  <p>
    <code>dropWhile</code> is <code>takeWhile</code>'s mirror: it skips
    elements as long as the predicate holds, then — the moment it hits one
    that fails — switches into "yield everything" mode for good. That
    switch-over is permanent: once <code>dropWhile</code> starts passing
    values through, it never goes back to dropping, even if a later element
    would also have matched.
  </p>
  <p>
    Reach for it to strip a variable-length prefix you can't count in
    advance — leading whitespace-like tokens, header rows, a warm-up period
    in a metrics stream. On the <code>Fx</code> chain it's also available as
    <code>skipWhile</code>, matching <code>Iterable.skipWhile</code>.
  </p>

  <h2>Demo 1 · Basics</h2>
  <p>Once dropping stops at <code>3</code>, later matching values
    (<code>2</code> at the end) are kept, not dropped again:</p>
  {{playground:0}}

  <h2>Demo 2 · Async</h2>
  {{playground:1}}

  <h2>Try it yourself</h2>
  <p>Exercise: drop temperatures while they stay below 25, then keep the
    rest.</p>
  {{playground:2}}

  <div class="callout">
    <strong>Related:</strong>
    <a href="takeWhile.html"><code>takeWhile</code></a> — the inverse ·
    <a href="dropUntil.html"><code>dropUntil</code></a> — also drops the matching element ·
    <a href="drop.html"><code>drop</code></a> — drop by fixed count ·
    <a href="filter.html"><code>filter</code></a> — drop matches everywhere, not just a prefix
  </div>
