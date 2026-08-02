---
slug: debounced-search
title: Debounce the search box — RxDart vs FxDart
description: Wait for the typing to go quiet before searching — one debounceTime operator on the event stream vs a hand-wired callback debouncer.
heading: Debounce the search box
order: 40
tier: 4
functions: fx, debounce, toAsync, map
domain: users
verdict: rxdart
async: true
---
  <h2>Requirement</h2>
  <p>
    A user types <code>f</code>, <code>fx</code>, <code>fxd</code> in a
    quick burst, pauses, then types <code>fxdart</code>. Search only when
    the typing has been quiet for 160&nbsp;ms — so exactly two searches
    run (<code>fxd</code> and <code>fxdart</code>) — and print each
    result. The keystroke schedule is simulated in the code; both versions
    must print the lines shown under <em>Expected output</em>.
  </p>

  {{output}}

  <h2>Side by side</h2>
  {{comparison}}

  <h2>Why they differ</h2>
  <p>
    This is a <em>push</em> problem in its purest form: the interesting
    thing is not the values but <strong>when they stop arriving</strong>.
    That is exactly what a stream models, and RxDart says it
    directly — <code>debounceTime(160ms)</code> on the
    event stream, then search, then collect. Subscription, windowing and
    the trailing edge at close are all handled by the operator.
  </p>
  <p>
    FxDart has no time-based pipeline operators on purpose — a pull
    pipeline has no "time between arrivals", only demand. Its
    <code>debounce</code> is the FxTS-style <em>callback wrapper</em>:
    correct, but you wire it to the stream yourself, collect the quiet
    queries by hand, wait out the trailing window at close, and only then
    hand the survivors to a typed pipeline for the actual searches. The
    honest verdict: on this side of the bridge, use RxDart — and if the
    downstream work grows (typed error handling, ordered concurrent
    fetches), pass the debounced stream through
    <code>fxStream</code> and continue in FxDart from there.
  </p>
