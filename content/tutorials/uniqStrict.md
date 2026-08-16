---
slug: uniqStrict
title: uniqStrict — FxDart 101
description: FxDart uniqStrict tutorial: dedupe eagerly into a List instead of lazily, and when that trade is worth making, with a live playground.
heading: <code>uniqStrict</code>
section: 4
crumb: uniqStrict
prev: uniqBy.html
prevLabel: distinctBy
next: uniqAdjacent.html
nextLabel: uniqAdjacent
---
  <p class="hero-sub">Dedupes the whole iterable immediately and returns a <code>List</code> — the eager counterpart of <code>distinct</code>.</p>

  {{signature}}

  <h2>Lecture</h2>
  <p>
    <code>uniqStrict</code> produces exactly the same elements, in the same
    order, as <a href="uniq.html"><code>distinct</code></a> followed by
    <code>toList()</code>. What differs is <em>when</em> the work happens and
    who can stop it. <code>uniqByStrict</code> is the same deal for
    <a href="uniqBy.html"><code>distinctBy</code></a>: dedupe on a computed
    key, eagerly.
  </p>
  <p>
    A lazy chain re-runs its upstream on every iteration. Iterate
    <code>distinct(...)</code> twice and the source is walked twice. The strict
    form walks it once, at the call, and hands you a <code>List</code> — so a
    result you are going to index, measure, or scan more than once costs you
    one pass instead of <em>n</em>. Demo 2 counts the callbacks to make this
    concrete.
  </p>
  <p>
    The price is that nothing downstream can cut the work short.
    <code>distinct(xs).take(3)</code> stops pulling <code>xs</code> as soon as
    3 distinct values have appeared; <code>uniqStrict(xs).take(3)</code> dedupes
    all of <code>xs</code> first and then takes 3. Never put the strict form
    ahead of a short-circuiting consumer, and never point it at an unbounded
    iterable — it will not terminate.
  </p>
  <div class="callout">
    <strong>Default to lazy.</strong> <code>distinct(...).toList()</code>
    already runs the dedupe and the accumulation as a single pass, so it is not
    paying for laziness. Reach for <code>uniqStrict</code> only when the deduped
    <code>List</code> is itself the thing you want, or when it is iterated more
    than once.
  </div>

  <h2>Demo 1 · Basics</h2>
  {{playground:0}}

  <h2>Demo 2 · When it pays, and what it costs</h2>
  {{playground:1}}

  <h2>Try it yourself</h2>
  <p>Exercise: use <code>uniqByStrict</code> to keep each visitor's first
    visit, as a <code>List</code> you can index without iterating again.</p>
  {{playground:2}}

  <div class="callout">
    <strong>Related:</strong>
    <a href="uniq.html"><code>distinct</code></a> — the lazy default ·
    <a href="uniqBy.html"><code>distinctBy</code></a> — dedupe by a computed key ·
    <a href="uniqAdjacent.html"><code>uniqAdjacent</code></a> — drop only adjacent duplicates ·
    <a href="toList.html"><code>toList</code></a> — materialize any chain
  </div>
