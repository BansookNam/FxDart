---
slug: spaced-out-calls
title: One call every 100 ms — RxDart vs FxDart
description: Five pings at least 100 ms apart, proved by a monotonic Stopwatch — rx interval vs a plain delay in the mapper of a sequential pull chain.
heading: One call every 100 ms
order: 42
tier: 4
functions: fx, toAsync, map
alsoLink: streams
domain: general
verdict: tie
async: true
---
  <h2>Requirement</h2>
  <p>
    Send five pings to a rate-limited endpoint, each starting at least
    <strong>100&nbsp;ms</strong> after the previous one. Record every call's
    start on a monotonic <code>Stopwatch</code>, print the five responses,
    and print <code>spaced: true</code> only if all gaps respected the
    limit. Both versions must print the lines shown under
    <em>Expected output</em>.
  </p>

  {{output}}

  <h2>Side by side</h2>
  {{comparison}}

  <h2>Why they differ</h2>
  <p>
    Pacing is about time, so you might expect the stream to win — and
    RxDart does have the word for it: <code>interval</code> holds each
    event back 100&nbsp;ms before it reaches the ping, and backpressure
    keeps the whole thing sequential. One operator, requirement met.
  </p>
  <p>
    But a pull pipeline is sequential by default, and that turns pacing
    into something almost embarrassingly simple: put the delay
    <em>inside the mapper</em>. Each pull waits 100&nbsp;ms, then calls —
    the next pull cannot begin until this one finishes, so the spacing is
    structural, no operator needed. The Stopwatch check prints
    <code>spaced: true</code> on both sides. Call it a tie with a caveat
    each way: RxDart names the concept explicitly, which reads better in
    a pipeline full of other time operators; FxDart gets it as a
    one-line consequence of demand, but only because this task wants
    strictly serial calls — for spacing events that arrive on their own
    schedule (a real event stream), reach for the stream side of the
    bridge (<code>fxStream</code>) and RxDart's time vocabulary.
  </p>
