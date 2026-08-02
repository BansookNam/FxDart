---
slug: sampled-gauge
title: Sample the gauge on each poll tick — RxDart vs FxDart
description: Read the latest gauge value at each poll tick — an explicit sample trigger stream vs a hand-tracked latest variable read through the bridge.
heading: Sample the gauge on each poll tick
order: 42
tier: 4
functions: fx, streams, map
domain: sensors
verdict: rxdart
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
    "The latest value at this instant" is a concept that only exists in
    the push model — it means <em>whatever arrived most recently</em>,
    which presumes things arrive on their own. RxDart's <code>sample</code>
    takes the gauge stream and a trigger stream and does exactly this
    job: on each trigger, emit the newest source value since the
    last trigger. One operator, and the state ("what is current?") lives
    inside it.
  </p>
  <p>
    A pull pipeline has no "current value" — nothing arrives until you
    ask. So the FxDart side splits the job in two: a plain subscription
    tracks the gauge's latest reading in a mutable variable, and the poll
    stream comes through <code>fxStream</code> so each pulled tick can
    <code>map</code> to a snapshot of that variable. It prints the same
    three readings, but the sampling logic is hand-rolled push code
    sitting <em>next to</em> the chain, not expressed by it. Verdict
    RxDart: sampling live state is push-native — this is push's home
    game.
  </p>
