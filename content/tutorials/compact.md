---
slug: compact
title: nonNulls — FxDart 101
description: FxDart nonNulls tutorial: drop nulls and narrow the element type, with a live playground.
heading: <code>nonNulls</code>
section: 4
crumb: nonNulls
prev: reject.html
prevLabel: reject
next: uniq.html
nextLabel: uniq
---
  <p class="hero-sub">Filters out null and narrows the element type from <code>T?</code> to <code>T</code> at the same time.</p>

  {{signature}}

  <h2>Lecture</h2>
  <p>
    <code>nonNulls</code> takes an <code>Iterable&lt;A?&gt;</code> and
    returns an <code>Iterable&lt;A&gt;</code> — every <code>null</code> is
    dropped, and the type checker knows it: nothing downstream needs a
    null check anymore. <code>nonNulls</code> is the Dart-idiomatic name;
    fxdart also accepts the FxTS spelling <code>compact</code> — they're the
    same operator. FxTS's <code>compact</code> drops all six JS falsy values
    (<code>undefined</code>, <code>null</code>, <code>0</code>,
    <code>''</code>, <code>NaN</code>, <code>false</code>); Dart has no
    single "falsy" concept, so the port only removes <code>null</code> —
    a deliberate, narrower behavior that's easy to reason about.
  </p>
  <p>
    It shows up constantly after <a href="pluck.html"><code>pluck</code></a>
    or any lookup that returns <code>T?</code>: <code>nonNulls(pluck(key, records))</code>
    gives you a clean, non-nullable list in one step.
  </p>
  <p>
    On the sync chain, <code>.nonNulls</code> is an <strong>inherited
    <code>Iterable</code> getter</strong> — write it with no parens
    (<code>fx(xs).nonNulls</code>), and because it returns a plain
    <code>Iterable&lt;A&gt;</code>, wrap it in <code>fx(...)</code> to keep
    chaining. There is no async getter, so on an async pipeline use the
    top-level <code>nonNullsAsync(...)</code> (or its FxTS alias
    <code>compactAsync</code>) and wrap with <code>fxAsync(...)</code>.
  </p>

  <h2>Demo 1 · Basics &amp; type narrowing</h2>
  {{playground:0}}

  <h2>Demo 2 · Async, with concurrency</h2>
  {{playground:1}}

  <h2>Try it yourself</h2>
  <p>Exercise: use <code>nonNulls</code> to drop the nulls from
    <code>answers</code>.</p>
  {{playground:2}}

  <div class="callout">
    <strong>Related:</strong>
    <a href="pluck.html"><code>pluck</code></a> — a common source of nullable values ·
    <a href="reject.html"><code>reject</code></a> — drop by arbitrary predicate ·
    <a href="../tutorials/compactObject.html"><code>compactObject</code></a> — the Map-keyed equivalent ·
    <a href="uniq.html"><code>uniq</code></a> — remove duplicates
  </div>
