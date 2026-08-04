---
slug: with-latest-config
title: Stamp each request with the latest config — RxDart vs FxDart
description: Each outgoing request carries the config version current at that instant — the same withLatestFrom operator on both sides, rxdart and fxEvents.
heading: Stamp each request with the latest config
order: 41
tier: 4
functions: fxEvents, withLatestFrom
domain: general
verdict: tie
async: true
noBenchmark: timing
---
  <h2>Requirement</h2>
  <p>
    An app fires four API requests while, in the background, deploys bump
    the config version <code>v1 → v2 → v3</code> at fixed offsets. Each
    request must be stamped with the config version that was current
    <em>when the request fired</em> — and a config bump on its own must
    not emit anything. Print the four stamped requests. Both schedules are
    simulated in the code; both versions must print the lines shown under
    <em>Expected output</em>.
  </p>

  {{output}}

  <h2>Side by side</h2>
  {{comparison}}

  <h2>Why they differ</h2>
  <p>
    They don't. This is <code>combineLatest</code>'s asymmetric
    sibling — one stream drives, the other is only <em>consulted</em> —
    and both panels name it the same way:
    <code>withLatestFrom</code> emits per request, stamped with the
    freshest config seen so far, and stays silent when only the config
    changes. No tagged-merge scaffolding, no <code>scan</code> fold — the
    two chains are operator-for-operator identical.
  </p>
  <p>
    fxdart's events layer absorbs the Rx approach for the push
    side: <code>fxEvents</code> is a thin wrapper chain over plain
    <code>Stream</code>s — never an extension, so it collides with
    nothing, rxdart included. RxDart's operator catalog remains far
    larger; fxdart keeps the events core small and crosses into the typed
    pull pipeline with <code>.pull()</code> when per-value processing
    grows. For stamping one live stream with the latest value of another,
    the two sides are equivalent: a tie.
  </p>
