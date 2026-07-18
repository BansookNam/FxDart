---
slug: takeUntilInclusive
title: takeUntilInclusive — FxDart 101
description: FxDart takeUntilInclusive tutorial: take values up to and including the first match, with a live playground.
heading: <code>takeUntilInclusive</code>
section: 5
crumb: takeUntilInclusive
prev: takeWhile.html
prevLabel: takeWhile
next: drop.html
nextLabel: drop
---
  <p class="hero-sub">Yields values until the predicate matches — the matching element is included.</p>

  {{signature}}

  <h2>Lecture</h2>
  <p>
    <code>takeUntilInclusive</code> is <code>takeWhile</code>'s close cousin,
    with one deliberate difference: it yields the element that made the
    predicate true, then stops. <code>takeWhile</code> stops
    <em>before</em> the failing element; <code>takeUntilInclusive</code>
    stops <em>after</em> the matching one. Reach for it whenever the
    matching element itself is part of the answer — "read the log up to and
    including the first error", "collect steps up to and including the
    terminator".
  </p>
  <p>
    FxTS originally named this <code>takeUntil</code>; FxDart keeps
    <code>takeUntil</code> (and <code>takeUntilAsync</code>) around as a
    <code>@Deprecated</code> alias for source parity, but new code should
    call <code>takeUntilInclusive</code> directly.
  </p>

  <h2>Demo 1 · Basics</h2>
  {{playground:0}}

  <h2>Demo 2 · Async</h2>
  {{playground:1}}

  <h2>Try it yourself</h2>
  <p>Exercise: take the log lines up to and including the first
    <code>'ERROR'</code>.</p>
  {{playground:2}}

  <div class="callout">
    <strong>Related:</strong>
    <a href="takeWhile.html"><code>takeWhile</code></a> — stops before the match, excludes it ·
    <a href="dropUntil.html"><code>dropUntil</code></a> — the drop-side counterpart ·
    <a href="take.html"><code>take</code></a> — take by count
  </div>
