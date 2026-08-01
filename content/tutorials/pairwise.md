---
slug: pairwise
title: pairwise — FxDart 101
description: FxDart pairwise tutorial: each element paired with its successor — deltas, day-over-day changes, gap detection — with a live playground.
heading: <code>pairwise</code>
section: 5
crumb: pairwise
prev: windowed.html
prevLabel: windowed
next: split.html
nextLabel: split
---
  <p class="hero-sub">Each element paired with its successor: <code>[a, b, c]</code> becomes <code>((a, b), (b, c))</code>.</p>

  {{signature}}

  <h2>Lecture</h2>
  <p>
    "How much did it <em>change</em>?" needs two elements at once — the
    previous and the current — and a plain <code><a href="map.html">map</a></code>
    only ever sees one. The usual workarounds are an index loop
    (<code>list[i&nbsp;-&nbsp;1]</code>, off-by-one risk included) or
    zipping a list with itself shifted by one.
    <code>pairwise()</code> is that idea as an operator: it yields
    <code>(previous, current)</code> records, lazily, with
    <em>n&nbsp;−&nbsp;1</em> pairs for <em>n</em> elements. Fewer than two
    elements yield nothing — there is no pair to make.
  </p>
  <p>
    The record fields keep both sides in reach:
    <code>p.$2&nbsp;-&nbsp;p.$1</code> is the delta,
    <code>p.$2.compareTo(p.$1)</code> the direction. It is exactly
    <code><a href="windowed.html">windowed(2)</a></code> with typed
    records instead of two-element lists — reach for <code>windowed</code>
    when the neighborhood grows past two.
  </p>
  <p>
    fxdart extension (no FxTS counterpart), after RxDart's
    <code>pairwise</code>. The async form computes nothing until pulled
    and composes with <code><a href="concurrent.html">concurrent</a></code>.
  </p>

  <h2>Demo 1 · Deltas between readings</h2>
  {{playground:0}}

  <h2>Demo 2 · Direction of change</h2>
  {{playground:1}}

  <h2>Try it yourself</h2>
  <p>Exercise: find the gaps in a sequence of timestamps.</p>
  {{playground:2}}

  <div class="callout">
    <strong>Related:</strong>
    <a href="windowed.html"><code>windowed</code></a> — neighborhoods bigger than two ·
    <a href="zip.html"><code>zip</code></a> — pairing two <em>different</em> sequences ·
    <a href="scan.html"><code>scan</code></a> — carrying state instead of looking back one
  </div>
