---
slug: whenComplete
title: whenComplete — FxDart 101
description: FxDart whenComplete tutorial: peek a side effect, handleError without switching, finalize on done or cancel — and stay on the FxEvents chain — with a live playground.
heading: <code>peek</code>, <code>whenComplete</code> &amp; <code>handleError</code>
section: 14
crumb: whenComplete
prev: fxEventsCreate.html
prevLabel: fxEventsCreate
next: sampleOn.html
nextLabel: sampleOn
---
  <p class="hero-sub">Side effects, per-error continue, and a finalize hook — without dropping off the chain to <code>.stream</code>.</p>

  {{signature}}

  <h2>Lecture</h2>
  <p>
    The pull layer's <code><a href="peek.html">peek</a></code> observes
    values as they are pulled. The events-layer
    <code>peek</code> is the same word for the same idea on a push
    stream: run a side effect, pass the event through unchanged.
    Optional <code>onError</code> / <code>onDone</code> hooks cover the
    other two notifications. A throwing callback becomes an error
    event and the chain continues — the event whose peek failed is
    not re-emitted. fxdart events layer, after Rx's <code>tap</code> /
    <code>doOn*</code>.
  </p>
  <p>
    <code>handleError</code> is the per-error-and-continue form:
    matching errors (every error when <code>test</code> is omitted)
    run <code>onError</code> and the stream keeps going. That is not
    <code><a href="onErrorResume.html">onErrorResume</a></code>, which
    cancels the source and switches. Reach for handleError to log or
    swallow a glitch; reach for onErrorResume to abandon the
    connection. <code>whenComplete</code> is Rx's
    <code>finalize</code>: the callback runs
    <strong>exactly once</strong>, on done, on error, or on cancel.
    Even if it throws, the chain still tears down.
  </p>
  <p>
    The chain no longer drops to <code>.stream</code> for
    <code>endWith</code>, <code>ifEmpty</code>, <code>uniq</code>,
    <code>takeRight</code>, <code>takeWhile</code> either — they are
    <code>FxEvents</code> methods now. <code>uniq</code> is global
    (not adjacent): the seen-set grows without bound, so a long-lived
    feed plus unbounded <code>uniq</code> is a memory leak; prefer
    <code>uniqAdjacent</code> when only consecutive repeats should
    go.
  </p>
  <p>
    fxdart events layer, after Rx's <code>tap</code>,
    <code>catchError</code> in its non-switching shape, and
    <code>finalize</code>. Pull-layer names win where they already
    mean the same thing: <code>peek</code> not <code>tap</code>,
    <code>takeRight</code> not <code>takeLast</code>,
    <code>uniq</code> not <code>distinct</code>.
  </p>

  <h2>Demo 1 · peek as a side effect</h2>
  {{playground:0}}

  <h2>Demo 2 · endWith, and ifEmpty</h2>
  {{playground:1}}

  <h2>Try it yourself</h2>
  <p>Exercise: <code>whenComplete</code> on done, and on cancel.</p>
  {{playground:2}}

  <div class="callout">
    <strong>Related:</strong>
    <a href="peek.html"><code>peek</code></a> — the pull-layer original, observing values as they are pulled ·
    <a href="onErrorResume.html"><code>onErrorResume</code></a> — abandon-and-switch; <code>handleError</code> is the continue form ·
    <a href="tap.html"><code>tap</code></a> — data-first side effect on a single value, not a stream
  </div>
