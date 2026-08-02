---
slug: sampled-gauge
title: Sample the gauge on each poll tick — RxDart vs FxDart
description: Read the latest gauge value at each poll tick — an explicit sample trigger stream in RxDart vs sampleOn in fxdart 0.8.0's events layer.
heading: Sample the gauge on each poll tick
order: 42
tier: 4
functions: fxEvents, sampleOn
domain: sensors
verdict: tie
async: true
---
  <h2>Requirement</h2>
  <p>
    A pressure gauge emits readings 1..8, one every 50&nbsp;ms. A
    dashboard polls three times — at 125, 275 and 425&nbsp;ms — and each
    poll should show the <strong>latest</strong> reading at that instant:
    2, 5, then 8. Print the three polled readings after the streams close.
    Both schedules are simulated in the code; both versions must print the
    lines shown under <em>Expected output</em>.
  </p>

  {{output}}

  <h2>Side by side</h2>
  {{comparison}}

  <h2>Why they differ</h2>
  <p>
    They no longer do. "The latest value at this instant" only exists in
    the push model — it presumes things arrive on their own — and both
    panels now express it as the same one-operator sentence: the gauge
    stream, sampled by the poll stream. RxDart writes
    <code>gauge().sample(polls())</code>; fxdart writes
    <code>fxEvents(gauge()).sampleOn(polls())</code>. In both, the "what
    is current?" state lives inside the operator, each trigger emits the
    newest reading since the last one, and unsampled readings are simply
    dropped.
  </p>
  <p>
    The pull pipelines still have no clock and no "current value" — that
    refusal stands. Instead, fxdart&nbsp;0.8.0 absorbed the Rx approach in
    a dedicated events layer: <code>fxEvents</code> is a thin wrapper
    chain over plain <code>Stream</code>s (never an extension, so it
    collides with nothing) that owns the push-native verbs the pull side
    would not. RxDart's operator catalog remains far larger; this verb,
    fxdart now speaks natively. And if each sampled reading were the start
    of real downstream work, <code>.pull()</code> hands the samples to the
    typed <code>FxAsync</code> pipeline, pulled on demand.
  </p>
