---
slug: throttled-refresh
title: Throttle the refresh button — RxDart vs FxDart
description: Let one tap through per 300 ms window — throttleTime on the tap stream vs fxdart's throttle callback wrapper wired to the stream by hand.
heading: Throttle the refresh button
order: 41
tier: 4
functions: fx, throttle, map
domain: users
verdict: rxdart
async: true
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
    Throttling is rate-limiting <em>arrivals in time</em> — a property of
    when events happen, not of the values themselves. That is stream
    territory, and RxDart collapses the whole requirement into one operator:
    <code>throttleTime(300ms)</code> opens a window at the first tap,
    swallows the rest of the burst, and reopens on the next tap after the
    window — subscription, window bookkeeping and completion all handled.
  </p>
  <p>
    FxDart's pipelines have no clock by design — a pull chain sees
    demand, not arrival times — so its <code>throttle</code> is the
    FxTS-style <em>callback wrapper</em>. It implements exactly the same
    leading-edge window, but you wire it to the stream yourself: subscribe,
    feed each tap into the throttled function, collect the survivors,
    track completion with a <code>Completer</code>, and only then hand the
    list to a typed chain for formatting. Same three taps, visibly more
    plumbing. This one is RxDart's, cleanly: throttling is a push
    problem, and the tap stream is where it should be solved.
  </p>
