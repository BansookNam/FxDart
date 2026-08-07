---
slug: switchMap
title: switchMap — FxDart 101
description: FxDart switchMap tutorial: map each event to an inner stream and mirror only the newest — cancellation-by-newer for search boxes — with a live playground.
heading: <code>switchMap</code>
section: 14
crumb: switchMap
prev: withLatestFrom.html
prevLabel: withLatestFrom
next: mergeMap.html
nextLabel: mergeMap
---
  <p class="hero-sub">Maps each event to an inner stream and mirrors only the newest one — a fresh event <em>cancels</em> the previous inner stream mid-flight.</p>

  {{signature}}

  <h2>Lecture</h2>
  <p>
    The search-box bug every UI has shipped at least once: the user types
    <code>da</code>, then <code>dart</code>; the <code>da</code> request is
    slower; its stale results arrive last and overwrite the good ones.
    The fix is not to <em>ignore</em> the old response but to make it
    impossible: <code>switchMap(f)</code> maps each event to an inner
    stream and, the moment a newer event arrives, <strong>cancels</strong>
    the previous inner stream outright. Only the newest inner stream is
    ever mirrored downstream.
  </p>
  <p>
    Cancellation-by-newer is a policy, and it is the right one exactly when
    older work becomes <em>worthless</em> once newer input exists — search,
    autocomplete, navigation, "load details for the selected row". It is
    the wrong one when every inner stream's output matters (an upload per
    file, say) — that is a fan-out job for the pull side's
    <code><a href="mapConcurrent.html">mapConcurrent</a></code>, where
    nothing gets cancelled.
  </p>
  <p>
    Semantics at the edges: the chain closes when the source has closed
    <em>and</em> the last inner stream completes — the source ending never
    cuts short work already on screen. A mapper that throws becomes an
    error event and the source keeps going. fxdart events layer, after
    Rx's <code>switchMap</code>.
  </p>

  <h2>Demo 1 · The search box, fixed</h2>
  {{playground:0}}

  <h2>Demo 2 · The last inner stream finishes its say</h2>
  {{playground:1}}

  <h2>Try it yourself</h2>
  <p>Exercise: autocomplete that cannot show stale suggestions.</p>
  {{playground:2}}

  <div class="callout">
    <strong>Related:</strong>
    <a href="debounce.html"><code>debounce</code></a> — its natural upstream partner: fewer queries in, no stale results out ·
    <a href="race.html"><code>race</code></a> — cancellation between <em>sibling</em> streams instead of successive ones ·
    <a href="mapConcurrent.html"><code>mapConcurrent</code></a> — when every result matters, pull-side fan-out
  </div>
