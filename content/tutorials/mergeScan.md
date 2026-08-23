---
slug: mergeScan
title: mergeScan — FxDart 101
description: FxDart mergeScan tutorial: fold each event into shared state through an inner stream — switchScan cancels, expandEach walks a tree — with a live playground.
heading: <code>mergeScan</code>, <code>switchScan</code> &amp; <code>expandEach</code>
section: 14
crumb: mergeScan
prev: switchLatest.html
prevLabel: switchLatest
next: race.html
nextLabel: race
---
  <p class="hero-sub">Fold each event into shared state through an inner stream — merge them, switch them, or walk a tree. The seed is <em>not</em> emitted.</p>

  {{signature}}

  <h2>Lecture</h2>
  <p>
    <code>FxEvents.scan</code> emits the seed first, then each running
    accumulation — the pull-layer convention, same as
    <code><a href="scan.html">scan</a></code>.
    <code>mergeScan</code> and <code>switchScan</code> do
    <strong>not</strong>. The seed is only the starting accumulator,
    never an event. That matches Rx, and it is the thing that surprises
    people coming from <code>FxEvents.scan</code>: an empty source
    closes empty.
  </p>
  <p>
    <code>mergeScan(seed, acc)</code> folds each event by opening
    <code>accumulator(state, value)</code> as an inner stream. Every
    inner emission becomes the new state and is forwarded. With
    <code>concurrent: n</code> at most <em>n</em> inners run at a time
    and the rest wait in a queue; they share one state variable — the
    latest inner emission wins. Null <code>concurrent</code> is
    unlimited. The result closes when the source has closed and every
    inner has finished.
  </p>
  <p>
    <code>switchScan</code> is the cancelling sibling: a new source
    value <strong>cancels</strong> the previous inner mid-flight, and
    the latest inner emission (if any) is the state handed to the next
    accumulator call. After the source closes, the current inner is
    allowed to finish.
  </p>
  <p>
    <code>expandEach</code> is Rx's <code>expand</code>, renamed
    because the pull layer already uses that word for iterable
    <code><a href="flatMap.html">flatMap</a></code>. It emits every
    source value, then recursively flattens <code>project</code> of
    that value — and of every value <code>project</code> itself emits —
    breadth-first. A <code>project</code> that never returns an empty
    stream will not terminate. fxdart events layer, after Rx's
    <code>mergeScan</code>, <code>switchScan</code> and
    <code>expand</code>.
  </p>

  <h2>Demo 1 · mergeScan — the seed stays silent</h2>
  {{playground:0}}

  <h2>Demo 2 · switchScan — newer cancels</h2>
  {{playground:1}}

  <h2>Try it yourself</h2>
  <p>Exercise: <code>expandEach</code>, a finite tree <code>0 → 1 → 2</code>.</p>
  {{playground:2}}

  <div class="callout">
    <strong>Related:</strong>
    <a href="scan.html"><code>scan</code></a> — the seed <em>is</em> emitted ·
    <a href="switchMap.html"><code>switchMap</code></a> / <a href="mergeMap.html"><code>mergeMap</code></a> — flattening without shared state ·
    <a href="flatMap.html"><code>expand</code></a> — pull-side one-level flatten, the name this one could not take
  </div>
