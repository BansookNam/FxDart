---
slug: memoizeLast
title: memoizeLast — FxDart 101
description: FxDart memoizeLast tutorial: a one-slot cache keyed by identity, for pure functions of immutable state, with a live playground.
heading: <code>fxMemoizeLast</code>
section: 10
crumb: memoizeLast
prev: memoize.html
prevLabel: memoize
next: negate.html
nextLabel: negate
---
  <p class="hero-sub">Remembers only the last call — and recognises a repeat by identity, in O(1).</p>

  {{signature}}

  <h2>Lecture</h2>
  <p>
    <code><a href="memoize.html">fxMemoize</a></code> keeps every argument
    it has ever seen, keyed by <code>==</code>/<code>hashCode</code>. That is
    wrong for the most common thing an app wants to cache: a value derived
    from <strong>immutable state</strong>. Every change makes a new state
    object, so a memo over state grows by one entry per change, forever —
    and hashing a large state on every call can cost more than the work it
    saves.
  </p>
  <p>
    <code>fxMemoizeLast(f)</code> keeps one slot. A call whose argument is
    <code>identical</code> to the previous call's returns the previous
    result; anything else runs <code>f</code> and replaces the slot. With
    immutable state that is exactly right: the same instance means nothing
    changed, a new instance means something might have, and the test is a
    pointer compare. A widget that rebuilds sixty times a second over the
    same state pays for <code>f</code> once.
  </p>
  <p>
    Pass <code>equals</code> to compare by value instead, or to key on a
    record — <code>(state, id)</code> compared field by field — when the
    function takes more than one argument. Only memoize a function whose
    result depends on its argument alone: one that also reads the clock or
    a mutable field will serve a stale answer from the slot. fxdart
    extension (not part of FxTS), after reselect's selector memo.
  </p>

  <h2>Demo 1 · Same state, one run</h2>
  {{playground:0}}

  <h2>Demo 2 · Two arguments, and versus fxMemoize</h2>
  {{playground:1}}

  <h2>Try it yourself</h2>
  <p>Exercise: make three calls on the same list run the function once.</p>
  {{playground:2}}

  <div class="callout">
    <strong>Related:</strong>
    <a href="memoize.html"><code>fxMemoize</code></a> — a cache of every argument ·
    <a href="onChange.html"><code>fxOnChange</code></a> — skip a callback whose value did not change ·
    <a href="identity.html"><code>fxIdentity</code></a>
  </div>
