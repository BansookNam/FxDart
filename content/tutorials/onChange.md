---
slug: onChange
title: onChange — FxDart 101
description: FxDart onChange tutorial: wrap a callback so it runs only when its argument changes — uniqAdjacent for a callback — with a live playground.
heading: <code>fxOnChange</code>
section: 12
crumb: onChange
prev: throttle.html
prevLabel: throttle
next: conflate.html
nextLabel: conflate
---
  <p class="hero-sub">Runs a callback only when its argument differs from the last one — <code>uniqAdjacent</code>, for a function.</p>

  {{signature}}

  <h2>Lecture</h2>
  <p>
    A value polled on a timer or recomputed every frame — an elapsed second
    read four times a second, a coin count, a progress fraction — arrives
    far more often than it changes. The guard is always the same three
    lines: remember the last value, compare, return early.
    <code>fxOnChange(f)</code> is those lines once. The first call always
    runs; after that a call runs <code>f</code> only when its argument is
    not equal to the argument of the last call that did.
  </p>
  <p>
    Equality is <code>==</code> by default; pass <code>equals</code> to
    decide what "changed" means — a rounding bucket, a field of a record, a
    case-insensitive string. <code>.reset()</code> forgets the last value,
    so the next call runs whatever it carries. Like
    <a href="debounce.html"><code>fxDebounce</code></a> it has a method
    spelling on the callback: <code>setCoins.fxOnChange()</code>.
  </p>
  <p>
    It is the callback twin of
    <code><a href="uniqAdjacent.html">uniqAdjacent</a></code>: the same
    rule, for a value pushed into a function rather than pulled from a
    sequence. Unlike a debounce it adds no delay and drops nothing that
    changed. fxdart extension (not part of FxTS).
  </p>

  <h2>Demo 1 · A polled value</h2>
  {{playground:0}}

  <h2>Demo 2 · equals and reset()</h2>
  {{playground:1}}

  <h2>Try it yourself</h2>
  <p>Exercise: stop writing a coin count that did not change.</p>
  {{playground:2}}

  <div class="callout">
    <strong>Related:</strong>
    <a href="uniqAdjacent.html"><code>uniqAdjacent</code></a> — the same rule on a sequence ·
    <a href="debounce.html"><code>fxDebounce</code></a> — wait for quiet ·
    <a href="throttle.html"><code>fxThrottle</code></a> — at most once per window ·
    <a href="memoizeLast.html"><code>fxMemoizeLast</code></a> — skip recomputing for the same input
  </div>
