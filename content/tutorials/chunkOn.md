---
slug: chunkOn
title: chunkOn — FxDart 101
description: FxDart chunkOn tutorial: batch events by count, by a trigger stream, or by a time window — turn a chatty stream into few network calls — with a live playground.
heading: <code>chunk</code>, <code>chunkOn</code> &amp; <code>chunkEvery</code>
section: 14
crumb: chunkOn
prev: stopOn.html
prevLabel: stopOn
next: windowOn.html
nextLabel: windowOn
---
  <p class="hero-sub">Collect events into lists — by count, by a trigger, or by a clock — so a chatty stream becomes a few batched calls.</p>

  {{signature}}

  <h2>Lecture</h2>
  <p>
    Batching is the cheapest performance win a chatty stream has. A
    hundred analytics events are a hundred round trips one at a time and
    two round trips in batches of fifty; the work is identical, the cost
    is not. The pull layer batches by count with
    <code><a href="chunk.html">chunk</a></code>, and that is all it can
    do — a pull pipeline has no clock, so "everything that happened in
    the last two seconds" is not a question it can ask.
  </p>
  <p>
    The push side can. <code>chunk(count)</code> is the same
    fixed-size batching, with a short final batch flushed when the source
    closes so nothing is stranded. <code>chunkEvery(window)</code> batches
    by <strong>time</strong> instead: whatever arrived in the last window
    is emitted as one list. And <code>chunkOn(trigger)</code> hands the
    decision to a second stream — batch when the user scrolls, when the
    frame ends, when the connection comes back.
  </p>
  <p>
    Both time-driven forms are <strong>silent on an empty window</strong>.
    A tick that finds nothing buffered emits nothing rather than an empty
    list, so downstream code never has to filter out batches that mean
    "nothing happened" — the same honesty rule
    <code><a href="sampleOn.html">sampleOn</a></code> follows. Whatever is
    still buffered when the source closes is flushed before the close.
  </p>
  <p>
    fxdart events layer, after Rx's <code>bufferCount</code>,
    <code>buffer</code> and <code>bufferTime</code>. The family keeps the
    pull layer's <code>chunk</code> as its root word — one name for one
    idea across both halves of the library — with the <code>…On</code>
    suffix for a trigger and <code>…Every</code> for a clock.
  </p>

  <h2>Demo 1 · Batching by the clock</h2>
  {{playground:0}}

  <h2>Demo 2 · By count, and by trigger</h2>
  {{playground:1}}

  <h2>Try it yourself</h2>
  <p>Exercise: a per-window summary instead of one report per click.</p>
  {{playground:2}}

  <div class="callout">
    <strong>Related:</strong>
    <a href="chunk.html"><code>chunk</code></a> — the pull-layer original, batching by count over an Iterable ·
    <a href="throttle.html"><code>throttle</code></a> — when you want one event per window rather than all of them ·
    <a href="spaceBy.html"><code>spaceBy</code></a> — the other way to slow a burst: stretch it instead of grouping it
  </div>
