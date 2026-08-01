---
slug: windowed
title: windowed — FxDart 101
description: FxDart windowed tutorial: sliding windows over a sequence — moving averages, batches with overlap, streak detection — with a live playground.
heading: <code>windowed</code>
section: 5
crumb: windowed
prev: chunk.html
prevLabel: chunk
next: pairwise.html
nextLabel: pairwise
---
  <p class="hero-sub">Sliding windows of <code>size</code> consecutive elements, each starting <code>step</code> elements after the last.</p>

  {{signature}}

  <h2>Lecture</h2>
  <p>
    <code><a href="chunk.html">chunk</a></code> cuts a sequence into
    <em>non-overlapping</em> pieces. The moment the pieces must overlap —
    a moving average, "three consecutive readings over the limit", any
    each-element-with-its-neighbors question — you end up hand-rolling an
    index loop with careful bounds. <code>windowed(size)</code> is that
    loop as a lazy operator: it yields a <code>List</code> of each
    <code>size</code> consecutive elements, sliding forward by
    <code>step</code> (default 1) between windows.
  </p>
  <p>
    Two knobs cover the whole family. <code>step</code> spaces the
    windows: <code>step&nbsp;&lt;&nbsp;size</code> overlaps them,
    <code>step&nbsp;==&nbsp;size</code> tiles them exactly like
    <code>chunk</code>, and <code>step&nbsp;&gt;&nbsp;size</code> samples
    with gaps. <code>partial:&nbsp;true</code> keeps the shorter windows
    at the tail instead of dropping them — in fact
    <code>chunk(n)</code> <em>is</em>
    <code>windowed(n, step:&nbsp;n, partial:&nbsp;true)</code>; they share
    one implementation.
  </p>
  <p>
    fxdart extension (no FxTS counterpart) — named after Kotlin's
    <code>windowed</code>; RxDart readers know it as
    <code>bufferCount(size, startEvery)</code>. It is lazy like every
    fxdart operator: windows materialize one pull at a time, so it
    composes with endless sources and with
    <code><a href="concurrent.html">concurrent</a></code>.
  </p>

  <h2>Demo 1 · Moving average</h2>
  {{playground:0}}

  <h2>Demo 2 · The step & partial knobs</h2>
  {{playground:1}}

  <h2>Try it yourself</h2>
  <p>Exercise: flag three consecutive days over the spending limit.</p>
  {{playground:2}}

  <div class="callout">
    <strong>Related:</strong>
    <a href="chunk.html"><code>chunk</code></a> — the non-overlapping special case ·
    <a href="pairwise.html"><code>pairwise</code></a> — windows of exactly two, as records ·
    <a href="scan.html"><code>scan</code></a> — running state without a fixed window
  </div>
