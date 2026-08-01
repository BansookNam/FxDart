---
slug: timeout
title: timeout — FxDart 101
description: FxDart timeout tutorial: fail a pull that takes too long — per-item time bounds in the pull model — with a live playground.
heading: <code>timeout</code>
section: 11
crumb: timeout
prev: retry.html
prevLabel: retry
next: using.html
nextLabel: using
---
  <p class="hero-sub">Fails any single pull that takes longer than <code>limit</code> with a <code>TimeoutException</code>.</p>

  {{signature}}

  <h2>Lecture</h2>
  <p>
    A pipeline is only as responsive as its slowest await.
    <code>timeout(limit)</code> puts a bound on that: each pull — the
    work of producing <em>one</em> item, however many upstream operators
    it passes through — must finish within <code>limit</code>, or the
    pull fails with a <code>TimeoutException</code>. Fast items are
    untouched; the operator adds no delay of its own.
  </p>
  <p>
    Pull-model semantics, worth being precise about: the limit measures
    <strong>demand-to-item time</strong> — from the moment downstream
    asks to the moment the item arrives. It does not measure gaps between
    items (there are none without demand) and it does not bound the whole
    pipeline (that is <code>Future.timeout</code> on the terminal:
    <code>fxAsync(…).toList().timeout(…)</code>). RxDart's
    <code>timeout</code> watches inter-event gaps on a push stream — same
    name, measured from the other side.
  </p>
  <p>
    fxdart extension (no FxTS counterpart). Parallel-safe: under
    <code><a href="concurrent.html">concurrent(n)</a></code> each
    overlapping pull carries its own timer, so <em>n</em> slow-ish items
    that overlap still pass individually. Pair with
    <code><a href="retry.html">retry</a></code> — timeout turns "hanging"
    into "failing", and retry turns "failing" into "try again".
  </p>

  <h2>Demo 1 · Catching the stall</h2>
  {{playground:0}}

  <h2>Demo 2 · Per pull, not per pipeline</h2>
  {{playground:1}}

  <h2>Try it yourself</h2>
  <p>Exercise: bound the slow feed, then recover.</p>
  {{playground:2}}

  <div class="callout">
    <strong>Related:</strong>
    <a href="retry.html"><code>retry</code></a> — what to do after the timeout fires ·
    <a href="concurrent.html"><code>concurrent</code></a> — overlapping pulls time out independently ·
    <a href="eitherPipelines.html">typed errors</a> — catching the <code>TimeoutException</code> as a value
  </div>
