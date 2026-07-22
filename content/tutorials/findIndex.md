---
slug: findIndex
title: indexWhere — FxDart 101
description: FxDart indexWhere tutorial: get the position of the first match, -1 when nothing matches, lazy and short-circuiting.
heading: <code>indexWhere</code>
section: 8
crumb: indexWhere
prev: find.html
prevLabel: find
next: includes.html
nextLabel: includes
---
  <p class="hero-sub">Returns the index of the first element for which a predicate is true, or <code>-1</code>.</p>

  {{signature}}

  <h2>Lecture</h2>
  <p>
    <code>indexWhere</code> is the Dart-idiomatic name (cf.
    <code>List.indexWhere</code>); fxdart also accepts the FxTS spelling
    <code>findIndex</code> — they're the same operator. It's
    <code>find</code>'s sibling: same lazy,
    short-circuiting scan, but it reports <em>where</em> the match was
    instead of the match itself. Note the different "nothing found"
    sentinel — this one is <code>-1</code>, an <code>int</code>, matching
    JavaScript's <code>Array.prototype.findIndex</code>. That's a deliberate
    contrast with <code>head</code>/<code>find</code>/<code>nth</code>,
    which all use <code>null</code>: an index has a natural "impossible"
    value, so FxDart keeps the FxTS convention here instead of inventing an
    <code>int?</code> return type.
  </p>
  <p>
    Internally it pairs each element with its index (via <code>zipWithIndex</code>)
    and stops at the first one that passes <code>f</code>.
  </p>

  <h2>Demo 1 · Basics</h2>
  {{playground:0}}

  <h2>Demo 2 · Short-circuiting &amp; async</h2>
  {{playground:1}}

  <h2>Try it yourself</h2>
  <p>Exercise: use <code>indexWhere</code> to find bob's position in the queue, or <code>-1</code>.</p>
  {{playground:2}}

  <div class="callout">
    <strong>Related:</strong>
    <a href="find.html"><code>find</code></a> — same search, returns the value ·
    <a href="includes.html"><code>includes</code></a> — just "is it there?" ·
    <a href="nth.html"><code>nth</code></a> — the inverse: index in, value out ·
    <a href="zipWithIndex.html"><code>zipWithIndex</code></a> — what powers this under the hood
  </div>
