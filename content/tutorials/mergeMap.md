---
slug: mergeMap
title: mergeMap — FxDart 101
description: FxDart mergeMap tutorial: map events to inner streams and run them all at once, in order with concatMap, or first-wins with exhaustMap — with a live playground.
heading: <code>mergeMap</code>, <code>concatMap</code> &amp; <code>exhaustMap</code>
section: 14
crumb: mergeMap
prev: switchMap.html
prevLabel: switchMap
next: race.html
nextLabel: race
---
  <p class="hero-sub">Three more answers to "an event arrived while the last one is still running": run them all, run them in order, or ignore the new one.</p>

  {{signature}}

  <h2>Lecture</h2>
  <p>
    Mapping an event to an <em>inner stream</em> — a request, an upload, a
    query — raises one question that a pull pipeline never has to answer:
    what happens when the next event arrives before the last inner stream
    has finished? There are exactly four sensible policies, and picking
    the wrong one is where most reactive bugs live.
    <code><a href="switchMap.html">switchMap</a></code> is the
    last-wins answer; these three are the other three.
  </p>
  <p>
    <code>mergeMap(f)</code> runs every inner stream <strong>at once</strong>
    and interleaves their output in arrival order. Use it when every
    result matters and none supersedes another — uploading three files,
    fanning out to three services. With <code>concurrent: n</code> at most
    <em>n</em> run at a time and the rest wait in a queue, which is how
    you keep a fan-out from opening two hundred sockets.
  </p>
  <p>
    <code>concatMap(f)</code> runs them <strong>strictly in order</strong>,
    each to completion before the next begins. Nothing overlaps and
    nothing is dropped, so a slow inner stream backs the whole chain up —
    that is the point when order is the correctness condition, as in
    "apply these edits in sequence".
  </p>
  <p>
    <code>exhaustMap(f)</code> keeps the <strong>first</strong> and ignores
    the rest: while an inner stream is running, incoming events are
    dropped outright — not queued, not cancelled. This is the
    double-submit guard. A second tap on a button whose request is still
    in flight does nothing at all, which is exactly what you want when the
    request is <code>POST /orders</code>.
  </p>
  <p>
    fxdart events layer, after Rx's <code>flatMap</code>,
    <code>flatMap(maxConcurrent: 1)</code> and <code>exhaustMap</code>.
    The first is called <code>mergeMap</code> here because
    <code><a href="flatMap.html">flatMap</a></code> already means
    iterable-flattening on the pull side.
  </p>

  <h2>Demo 1 · mergeMap — everything at once</h2>
  {{playground:0}}

  <h2>Demo 2 · exhaustMap — the double-submit guard</h2>
  {{playground:1}}

  <h2>Try it yourself</h2>
  <p>Exercise: <code>concatMap</code>'s ordering, and a bounded fan-out.</p>
  {{playground:2}}

  <div class="callout">
    <strong>Related:</strong>
    <a href="switchMap.html"><code>switchMap</code></a> — the fourth policy: newest wins, the rest are cancelled ·
    <a href="mapConcurrent.html"><code>mapConcurrent</code></a> — pull-side bounded fan-out, where results stay in order ·
    <a href="debounce.html"><code>debounce</code></a> — often the better fix: stop the extra events before they become inner streams
  </div>
