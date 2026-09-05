---
slug: job-search
title: Debounced search — FxDart 101
description: A job tutorial: wait for the typing to go quiet, keep only the latest query, parse with a typed error — fxEvents, debounce, switchMap, mapEither.
heading: Debounced search
section: 15
crumb: debounced search
prev: materialize.html
prevLabel: materialize
next: job-fetch.html
nextLabel: bounded concurrent fetch
---
  <p class="hero-sub">Time first, then latest-wins, then a typed parse. One chain. This is a tie with RxDart on purpose — the point is you do not need a second package.</p>

  {{signature}}

  <h2>Lecture</h2>
  <p>
    A search box is not a list. Keystrokes arrive when they arrive, a
    burst should collapse to the last query, and a request that is still
    in flight when the next query lands should be cancelled — otherwise
    a slow "da" can overwrite a fast "dart". That is a
    <em>push</em> job:
    <code><a href="fxEvents.html">fxEvents</a></code> +
    <code><a href="debounce.html">debounce</a></code> +
    <code><a href="switchMap.html">switchMap</a></code>.
  </p>
  <p>
    The
    <a href="../RxDartComparison/debounced-search.html">RxDart comparison</a>
    of the same job is a <strong>tie</strong>. rxdart's
    <code>debounceTime</code> is the same idea. FxDart's claim here is not
    speed — you cannot beat waiting — it is that the events layer lives
    in the same import as the pull pipelines and the typed-error system,
    so the next step (parse the hit, keep a <code>Left</code> instead of
    throwing) does not start a new library.
  </p>
  <p>
    <code><a href="mapEither.html">mapEither</a></code> runs each
    delivered result in a raise scope. A bad payload becomes a
    <code>Left</code>; later queries still arrive. Put
    <code><a href="attempt.html">attempt</a></code> on the source only
    when a <em>throw</em> should become a value — and if the chain also
    retries, <code>attempt</code> goes
    <strong>after</strong> <code>retryOn</code>, never before.
  </p>

  <h2>Demo 1 · wait for the typing to go quiet</h2>
  <p>
    The keystroke schedule is simulated: a burst, a pause, one more
    query. <code>debounce(160ms)</code> emits twice —
    <code>fxd</code> and <code>fxdart</code> — the same contract as the
    comparison page.
  </p>
  {{playground:0}}

  <h2>Demo 2 · latest query wins, then a typed parse</h2>
  <p>
    <code>switchMap</code> starts a search per query and cancels the
    previous inner stream. <code>mapEither</code> then names a missing
    hit as a <code>Left</code> instead of throwing. Both searches start;
    only the latest result is delivered.
  </p>
  {{playground:1}}

  <div class="callout">
    <strong>Related:</strong>
    <a href="whichSurface.html">which surface</a> — why this is push ·
    <a href="fxEvents.html"><code>fxEvents</code></a> ·
    <a href="debounce.html"><code>debounce</code></a> ·
    <a href="switchMap.html"><code>switchMap</code></a> ·
    <a href="mapEither.html"><code>mapEither</code></a> ·
    <a href="job-fetch.html">bounded concurrent fetch</a> — the I/O job ·
    <a href="../RxDartComparison/debounced-search.html">RxDart vs FxDart: debounce</a>
  </div>
