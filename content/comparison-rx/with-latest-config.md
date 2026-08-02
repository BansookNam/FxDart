---
slug: with-latest-config
title: Stamp each request with the latest config — RxDart vs FxDart
description: Each outgoing request carries the config version current at that instant — withLatestFrom vs a tagged merge folded with scan behind the bridge.
heading: Stamp each request with the latest config
order: 44
tier: 4
functions: fx, streams, scan, filter, map
domain: general
verdict: rxdart
async: true
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
    This is <code>combineLatest</code>'s asymmetric sibling: one stream
    drives, the other is only <em>consulted</em>. RxDart's
    <code>withLatestFrom</code> <em>is</em> this requirement, named — emit per request,
    pairing it with the freshest config seen so far, and stay silent when
    only the config changes. Which stream is primary is encoded in the
    operator itself.
  </p>
  <p>
    The FxDart side has to build that asymmetry by hand. It starts with
    the same tagged-merge scaffolding as the previous example
    (controller, close-tracking, bridge), then builds the asymmetry in
    the fold: a config event stores the version and clears the request
    slot, a request event fills it. A <code>filter</code> keeps only
    states with a pending request, and a <code>map</code> formats the
    stamp. Every step is typed and explicit, and that is the problem:
    four operators reimplement what <code>withLatestFrom</code> simply
    <em>names</em>. Verdict RxDart — the right tool whenever one live
    stream needs the latest value of another.
  </p>
