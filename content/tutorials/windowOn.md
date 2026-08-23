---
slug: windowOn
title: windowOn — FxDart 101
description: FxDart windowOn tutorial: nested live streams — window by count, by a trigger, or by a clock, and see values before the window closes — with a live playground.
heading: <code>windowOn</code>, <code>windowCount</code> &amp; <code>windowEvery</code>
section: 14
crumb: windowOn
prev: chunkOn.html
prevLabel: chunkOn
next: groupsBy.html
nextLabel: groupsBy
---
  <p class="hero-sub">Nested live streams: see the values of a window before it closes, rotate by count, by a trigger, or by a clock.</p>

  {{signature}}

  <h2>Lecture</h2>
  <p>
    <code><a href="chunkOn.html">chunk</a></code> waits for a window to
    close and then emits a <code>List</code>. The <code>window*</code>
    family emits the window <strong>while it is still open</strong>: each
    value of the outer stream is a nested
    <code>FxEvents</code>, so a subscriber can see events before the
    close — a live chart of the current minute, a running total of the
    current batch. That is the whole difference, and it is why the
    return type is <code>FxEvents&lt;FxEvents&lt;T&gt;&gt;</code>.
  </p>
  <p>
    <code>windowCount(size)</code> rotates every <code>size</code>
    events; <code>startEvery</code> smaller than <code>size</code>
    overlaps, larger gaps. <code>windowOn(boundaries)</code> opens a
    window immediately on listen and rotates on each trigger value —
    boundary completion is ignored, so the current window stays open
    until the source completes. <code>windowEvery(span)</code> is the
    clock form; <code>every</code> overlaps or gaps on that period, and
    <code>maxSize</code> closes a window early by count.
  </p>
  <p>
    Lifetime follows RxJS 9: <strong>cancelling the outer completes live
    inners silently</strong> rather than erroring them, so nested
    subscribers tear down cleanly. A source error still errors every
    live inner, then the outer. And because inners are streams, a
    trailing empty window can appear when a new one opens as the last
    value fills the previous — <code>chunk*</code> skips those;
    <code>window*</code> does not.
  </p>
  <p>
    <code>chunkToggle(openings, closeOf)</code> is the list-family
    counterpart of <code>windowToggle</code>: each opening starts a
    buffer, the first event from <code>closeOf</code> of that opening
    emits it, empty buffers are skipped like
    <code><a href="chunkOn.html">chunkOn</a></code>. fxdart events
    layer, after Rx's <code>window</code>, <code>windowCount</code>,
    <code>windowTime</code>, and <code>bufferToggle</code>.
  </p>

  <h2>Demo 1 · Windows of two</h2>
  {{playground:0}}

  <h2>Demo 2 · Rotate on a trigger</h2>
  {{playground:1}}

  <h2>Try it yourself</h2>
  <p>Exercise: live inners spanning a short Duration.</p>
  {{playground:2}}

  <div class="callout">
    <strong>Related:</strong>
    <a href="chunkOn.html"><code>chunk</code> / <code>chunkOn</code></a> — the same windows as lists, emitted when they close ·
    <a href="windowed.html"><code>windowed</code></a> — sliding lists on the pull layer ·
    <a href="groupsBy.html"><code>groupsBy</code></a> — live inners keyed by value, not by time
  </div>
