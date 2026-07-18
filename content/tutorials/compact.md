---
slug: compact
title: compact — FxDart 101
description: FxDart compact tutorial: drop nulls and narrow the element type, with a live playground.
heading: <code>compact</code>
section: 4
crumb: compact
prev: reject.html
prevLabel: reject
next: uniq.html
nextLabel: uniq
---
  <p class="hero-sub">Filters out null and narrows the element type from <code>T?</code> to <code>T</code> at the same time.</p>

  {{signature}}

  <h2>Lecture</h2>
  <p>
    <code>compact</code> takes an <code>Iterable&lt;A?&gt;</code> and
    returns an <code>Iterable&lt;A&gt;</code> — every <code>null</code> is
    dropped, and the type checker knows it: nothing downstream needs a
    null check anymore. This is the FxDart equivalent of FxTS's
    <code>compact</code>, which drops all six JS falsy values
    (<code>undefined</code>, <code>null</code>, <code>0</code>,
    <code>''</code>, <code>NaN</code>, <code>false</code>). Dart has no
    single "falsy" concept, so the port only removes <code>null</code> —
    a deliberate, narrower behavior that's easy to reason about.
  </p>
  <p>
    It shows up constantly after <a href="pluck.html"><code>pluck</code></a>
    or any lookup that returns <code>T?</code>: <code>compact(pluck(key, records))</code>
    gives you a clean, non-nullable list in one step.
  </p>
  <p>
    There is <strong>no chain method</strong> for <code>compact</code> —
    only the data-first top-level function and its async counterpart exist.
    Call it directly, or wrap the result with <code>fx(...)</code> /
    <code>fxAsync(...)</code> to keep chaining.
  </p>

  <h2>Demo 1 · Basics &amp; type narrowing</h2>
  {{playground:0}}

  <h2>Demo 2 · Async, with concurrency</h2>
  {{playground:1}}

  <h2>Try it yourself</h2>
  <p>Exercise: use <code>compact</code> to drop the nulls from
    <code>answers</code>.</p>
  {{playground:2}}

  <div class="callout">
    <strong>Related:</strong>
    <a href="pluck.html"><code>pluck</code></a> — a common source of nullable values ·
    <a href="reject.html"><code>reject</code></a> — drop by arbitrary predicate ·
    <a href="../tutorials/compactObject.html"><code>compactObject</code></a> — the Map-keyed equivalent ·
    <a href="uniq.html"><code>uniq</code></a> — remove duplicates
  </div>
