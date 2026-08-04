---
slug: switch-to-newest-search
title: Only the newest search matters — RxDart vs FxDart
description: A newer query abandons the in-flight search — the same switchMap operator on both sides, rxdart and fxdart's fxEvents chain.
heading: Only the newest search matters
order: 40
tier: 4
functions: fxEvents, switchMap
domain: users
verdict: tie
async: true
---
  <h2>Requirement</h2>
  <p>
    A user types three queries — <code>fx</code>, then
    <code>fxdar</code> 40&nbsp;ms later, then <code>fxdart</code> after a
    pause. Each search takes 150&nbsp;ms, so the second query arrives
    while the first search is still in flight: the first result must be
    discarded, never shown. Print only the surviving results, then how
    many searches started vs were delivered. The schedule is simulated in
    the code; both versions must print the lines shown under
    <em>Expected output</em>.
  </p>

  {{output}}

  <h2>Side by side</h2>
  {{comparison}}

  <h2>Why they differ</h2>
  <p>
    They no longer do. "Newer cancels older" is a statement about
    <em>subscriptions</em>, and since fxdart 0.7.3 the
    <code>fxEvents</code> layer has them: its <code>switchMap</code> maps
    each query to an inner search stream and unsubscribes the previous
    one the moment a newer query arrives, so a stale result has no
    listener left to reach. Three searches start, two results survive,
    and none of that logic appears in user code — in either panel. The
    hand-rolled epoch counter and completion bookkeeping the old FxDart
    panel needed are gone.
  </p>
  <p>
    fxdart 0.7.3 absorbed the Rx approach for exactly this kind of
    requirement: <code>fxEvents</code> is a thin wrapper chain over plain
    <code>Stream</code>s — never an extension, so it coexists with any
    other stream library, rxdart included. RxDart's operator catalog
    remains far larger; when the surviving results need real per-value
    processing, cross into the typed pull chain with <code>.pull()</code>.
    For <code>switchMap</code>'s defining use case the panels are now
    operator-for-operator equivalent: a tie.
  </p>
