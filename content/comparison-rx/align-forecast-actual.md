---
slug: align-forecast-actual
title: Align forecast with actuals — RxDart vs FxDart
description: Pair two fixed series position by position and print each day's difference — zipWith on streams vs zip on iterables, same alignment either way.
heading: Align forecast with actuals
order: 20
tier: 2
functions: fx, zip, map
domain: sensors
verdict: tie
async: false
---
  <h2>Requirement</h2>
  <p>
    A five-day temperature forecast sits next to what the sensor actually
    measured. Pair the two series <strong>position by position</strong>
    and print one line per day: forecast, actual, and the signed
    difference to one decimal place. The data is in the code; both
    versions must print the lines shown under <em>Expected output</em>.
  </p>

  {{output}}

  <h2>Side by side</h2>
  {{comparison}}

  <h2>Why they differ</h2>
  <p>
    Positional pairing is symmetric across the models and both libraries
    ship it: <code>zipWith</code> combines the n-th event of one stream
    with the n-th of another, <code>zip</code> pairs the n-th pulls of
    two iterables. Both stop at the shorter side, both keep order by
    construction. The formatting function is shared verbatim, so the
    panels differ only in how the two series are lifted into a pipeline.
  </p>
  <p>
    The models do hide different machinery under the shared name. Stream
    <code>zipWith</code> is a small coordination engine: two live
    subscriptions, a one-slot buffer for whichever side is ahead, and
    pause/resume to keep a fast producer from outrunning a slow one.
    Iterable <code>zip</code> is two iterators advanced in lockstep — the
    consumer's pull <em>is</em> the synchronisation, so there is nothing
    to buffer and no one to pause. For two fixed lists none of that
    machinery is ever exercised, which is exactly why this one is a tie:
    pick the version that matches where your series actually live.
  </p>
