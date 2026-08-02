---
slug: sliding-average-rx
title: Three-reading moving average — RxDart vs FxDart
description: A moving average over sensor readings — bufferCount(3, 1) plus a length filter for the trailing partials vs windowed(3) saying exactly what it means.
heading: Three-reading moving average
order: 12
tier: 2
functions: fx, windowed, average, map
domain: sensors
verdict: fxdart
async: false
---
  <h2>Requirement</h2>
  <p>
    Smooth eight hourly temperature readings with a
    <strong>three-reading moving average</strong>: for every window of 3
    consecutive readings, print the window and its mean to one decimal
    place — six full windows, no partials. The data is in the code; both
    versions must print the lines shown under <em>Expected output</em>.
  </p>

  {{output}}

  <h2>Side by side</h2>
  {{comparison}}

  <h2>Why they differ</h2>
  <p>
    RxDart spells a sliding window as a parameterisation of batching:
    <code>bufferCount(3, 1)</code> — buffers of three, a new buffer
    starting every one event. It works, but the encoding leaks twice.
    You have to know that the second argument is
    <code>startBufferEvery</code> and that <code>1</code> means
    "sliding"; and at the end of the stream the operator flushes its
    still-open buffers, so a ramp-down partial like
    <code>[21.9, 21.4]</code> comes out too and a
    <code>where((w) =&gt; w.length == 3)</code> has to stand guard for a
    case the requirement never mentioned.
  </p>
  <p>
    FxDart has a word for the concept itself: <code>windowed(3)</code>
    yields exactly the full windows, and <code>partial: true</code> is
    the explicit opt-in for the ramp-down — the default matches what a
    moving average means. Add <code>average</code> as a library function
    (RxDart has no aggregate helpers, so the mean is a hand-rolled
    <code>reduce</code>-and-divide) and the pull side states the
    requirement while the push side encodes it. That gap is vocabulary,
    not model — but the vocabulary exists because windows over an
    iterable are a pull-native idea, and this one goes to FxDart.
  </p>
