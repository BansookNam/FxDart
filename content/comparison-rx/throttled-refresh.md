---
slug: throttled-refresh
title: Throttle the refresh button — RxDart vs FxDart
description: Let one tap through per 300 ms window — throttleTime on the tap stream vs the equivalent throttle chain in fxdart 0.7.3's events layer.
heading: Throttle the refresh button
order: 44
tier: 4
functions: fxEvents, throttle
domain: users
verdict: tie
async: true
noBenchmark: timing
---
  <h2>Requirement</h2>
  <p>
    A user hammers the refresh button: taps at
    0/50/100/400/450/800&nbsp;ms. Let at most one refresh through per
    300&nbsp;ms window, taking the <em>first</em> tap in each window — so
    exactly three refreshes fire (taps 0, 3 and 5). Print which taps got
    through after the stream closes. The tap schedule is simulated in the
    code; both versions must print the lines shown under
    <em>Expected output</em>.
  </p>

  {{output}}

  <h2>Side by side</h2>
  {{comparison}}

  <h2>Why they differ</h2>
  <p>
    They no longer do. Throttling is rate-limiting <em>arrivals in
    time</em> — a property of when events happen, not of the values — and
    both panels now collapse the requirement into one operator on the tap
    stream. RxDart's <code>throttleTime(300ms)</code> and fxdart's
    <code>fxEvents(...).throttle(300ms)</code> implement the same
    leading-edge window (first tap emits and opens the window, the rest of
    the burst is swallowed; a trailing edge is a flag away on either
    side), with subscription, window bookkeeping and completion all inside
    the operator.
  </p>
  <p>
    fxdart&nbsp;0.7.3 got here by deliberately absorbing the Rx approach
    for the push side: <code>fxEvents</code> is a wrapper chain over plain
    <code>Stream</code>s — not an extension, so it coexists with any
    stream library without a single member conflict. RxDart's operator
    catalog remains far larger than fxdart's events layer; for the
    everyday time verbs like this one, the two are now interchangeable.
    If each surviving tap then had to trigger real, typed async work,
    <code>.pull()</code> would carry the stream into the demand-driven
    <code>FxAsync</code> pipeline.
  </p>
