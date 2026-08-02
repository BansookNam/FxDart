---
slug: tee-the-pipeline
title: One source, two independent readers — RxDart vs FxDart
description: Total and max from one side-effecting source without running it twice — a connectable stream vs fork sharing one buffered pass.
heading: One source, two independent readers
order: 48
tier: 4
functions: fx, fork, sum, max
domain: sensors
verdict: tie
async: false
---
  <h2>Requirement</h2>
  <p>
    One reading source must feed <strong>two</strong> independent
    computations — the total and the peak — while running exactly once.
    The source increments a counter each time it runs; print the total,
    the peak, and the counter to prove the single pass. The data is in the
    code; both versions must print the lines shown under
    <em>Expected output</em>.
  </p>

  {{output}}

  <h2>Side by side</h2>
  {{comparison}}

  <h2>Why they differ</h2>
  <p>
    Both models hit the same wall here: their sources restart per
    consumer. Listening to a plain single-subscription stream twice is an
    error; iterating a <code>sync*</code> generator twice quietly runs it
    twice. And both libraries answer with the same idea — share one pass.
    RxDart makes the stream <em>connectable</em>: <code>publish()</code>
    defers the source, both reductions subscribe, and <code>connect()</code>
    starts the single subscription that feeds them. FxDart's
    <code>fork</code> branches one buffered iteration: every fork of the
    same iterable object is an independent cursor over a shared buffer, so
    the generator body runs once no matter how many readers pull from it.
  </p>
  <p>
    The differences are texture, not capability. The rx version is
    ordering-sensitive — readers must attach <em>before</em>
    <code>connect()</code>, and a latecomer misses events; that is push:
    delivery happens whether you are ready or not. The fx version is
    identity-sensitive — you must fork the <em>same object</em>, and a
    fork that lags simply replays the buffer at its own pace; that is
    pull: values wait for demand. The cost is memory: the shared buffer
    holds every value until the slowest fork has consumed it, so a badly
    lagging reader keeps the whole pass alive, where rx's latecomer
    would simply have missed it. Either is a fine answer to "tee the
    pipeline", which makes this a tie — pick the one matching the model
    the rest of your code already lives in.
  </p>
