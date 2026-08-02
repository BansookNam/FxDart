---
slug: switch-to-newest-search
title: Only the newest search matters — RxDart vs FxDart
description: A newer query abandons the in-flight search — switchMap in one operator vs a hand-rolled epoch counter that drops stale results as they land.
heading: Only the newest search matters
order: 45
tier: 4
functions: fx, map
domain: users
verdict: rxdart
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
    "Newer cancels older" is a statement about <em>subscriptions</em>, and
    only the push model has them. <code>switchMap</code> is the whole
    requirement: each query starts an inner search stream, and the arrival
    of a newer query unsubscribes the old one, so a stale result has no
    listener left to reach. Three searches start, two results survive, and
    none of that logic appears in user code.
  </p>
  <p>
    A pull pipeline cannot express this — by the time a chain would pull
    the first result, the interesting fact (a newer query exists) lives
    outside the sequence. So the FxDart side hand-rolls the switch: an
    epoch counter increments per query, each search remembers its epoch,
    and a result is dropped on arrival if it is no longer the newest. Add
    the completion bookkeeping (a <code>Completer</code> for the stream,
    awaiting the last in-flight search) and only then a small
    <code>fx</code> chain to format the survivors. It prints the same
    lines, but it is a manual reimplementation of cancellation-by-newer.
    This is <code>switchMap</code>'s defining use case, and the verdict
    follows: use RxDart here.
  </p>
