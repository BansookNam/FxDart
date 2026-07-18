---
slug: take
title: take — FxDart 101
description: FxDart take tutorial: pull the first n values off any lazy pipeline — even an infinite one — with a live playground.
heading: <code>take</code>
section: 5
crumb: take
prev: compress.html
prevLabel: compress
next: takeRight.html
nextLabel: takeRight
---
  <p class="hero-sub">Returns a lazy iterable of the first <code>length</code> values from a source.</p>

  {{signature}}

  <h2>Lecture</h2>
  <p>
    <code>take</code> is how a lazy pipeline stays finite. It stops pulling
    from its source the moment it has yielded <code>length</code> values —
    the upstream never sees more requests than that. Because FxDart sources
    like <code>range</code>, <code>repeat</code>, and <code>cycle</code> can
    be infinite, <code>take</code> is often the only thing that makes a
    pipeline safe to run at all.
  </p>
  <p>
    It comes as a data-first function (<code>take(n, iterable)</code>) and as
    a chain method (<code>fx(iterable).take(n)</code>). On the async side,
    <code>takeAsync</code>/<code>.take()</code> is a pass-through: it doesn't
    serialize the upstream, so a <code>concurrent(n)</code> further up the
    chain keeps overlapping its pulls right up until <code>take</code> has
    what it needs.
  </p>

  <h2>Demo 1 · Basics, and taking from an infinite source</h2>
  <p><code>cycle</code> repeats its input forever — without
    <code>take</code>, iterating it would never finish:</p>
  {{playground:0}}

  <h2>Demo 2 · Async, still overlapping under concurrent</h2>
  <p>
    Only 4 values are ever pulled here, but <code>concurrent(3)</code>
    upstream still evaluates them 3-at-a-time — <code>take</code> doesn't
    force everything sequential:
  </p>
  {{playground:1}}

  <h2>Try it yourself</h2>
  <p>Exercise: take only the first 3 names from the queue.</p>
  {{playground:2}}

  <div class="callout">
    <strong>Related:</strong>
    <a href="takeRight.html"><code>takeRight</code></a> — last n instead of first n ·
    <a href="takeWhile.html"><code>takeWhile</code></a> — take by predicate ·
    <a href="range.html"><code>range</code></a> · <a href="cycle.html"><code>cycle</code></a> — infinite sources ·
    <a href="concurrent.html"><code>concurrent</code></a> — parallel evaluation
  </div>
