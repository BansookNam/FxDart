---
slug: throwIf
title: throwIf — FxDart 101
description: FxDart throwIf tutorial: throw conditionally, otherwise pass the value through, with a live playground.
heading: <code>throwIf</code>
section: 10
crumb: throwIf
prev: throwError.html
prevLabel: throwError
next: cases.html
nextLabel: cases
---
  <p class="hero-sub">Throws when a predicate holds; otherwise returns the value unchanged.</p>

  {{signature}}

  <h2>Lecture</h2>
  <p>
    <code>throwIf(predicate, toError, value)</code> is a guard clause you can
    drop mid-expression: if <code>predicate(value)</code> is true, it throws
    <code>toError(value)</code>; otherwise it hands <code>value</code> back
    unchanged. That makes it convenient inside a <code>map</code> callback,
    where you want to validate every element as it streams through the
    pipeline and fail loudly the moment one is invalid.
  </p>
  <p>
    It's essentially <a href="when.html"><code>when</code></a> where the
    "then" branch always throws instead of returning a value — so wrap any
    call site in <code>try</code>/<code>catch</code> to observe or recover
    from the failure.
  </p>

  <h2>Demo 1 · Basics</h2>
  {{playground:0}}

  <h2>Demo 2 · Validating a pipeline</h2>
  <p>
    Each age is validated as it's mapped; the first violation aborts the
    whole <code>toList()</code> call:
  </p>
  {{playground:1}}

  <h2>Try it yourself</h2>
  <p>Exercise: use <code>throwIf</code> to guard against zero stock while
    summing this inventory.</p>
  {{playground:2}}

  <div class="callout">
    <strong>Related:</strong>
    <a href="throwError.html"><code>throwError</code></a> — a standalone throwing function, no condition ·
    <a href="when.html"><code>when</code></a> — substitute a value instead of throwing ·
    <a href="cases.html"><code>cases</code></a> — dispatch across multiple predicates ·
    <a href="add.html"><code>add</code></a> — used above as the reducer
  </div>
