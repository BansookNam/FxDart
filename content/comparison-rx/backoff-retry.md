---
slug: backoff-retry
title: Retry with growing backoff — RxDart vs FxDart
description: Grow the wait between attempts — retryWhen maps each error to a timer stream by hand vs a delay hook that returns a Duration.
heading: Retry with growing backoff
order: 28
tier: 3
functions: fx, retry
domain: general
verdict: fxdart
async: true
---
  <h2>Requirement</h2>
  <p>
    The rate service is unavailable exactly twice, then serves. Retry
    with <strong>growing backoff</strong> — wait 40&nbsp;ms after the
    first failure, 80&nbsp;ms after the second — with a budget of three
    attempts. Print the payload, the attempt count, and the recorded
    backoff sequence (recorded when each wait is chosen, so the output is
    deterministic). Both versions must print the lines shown under
    <em>Expected output</em>.
  </p>

  {{output}}

  <h2>Side by side</h2>
  {{comparison}}

  <h2>Why they differ</h2>
  <p>
    Backoff is where the one-call symmetry of plain retry breaks.
    RxDart's <code>retryWhen</code> is a meta-stream protocol: for every
    error, your factory must return a <em>notifier stream</em> — emit a
    value to trigger the retry, emit an error to give up. So "wait 40 ms,
    then 80 ms" becomes mapping each failure to an
    <code>Rx.timer</code> stream, and because the factory only sees one
    error at a time, both the failure count and the attempt budget live
    in mutable variables <em>outside</em> the operator. It works, and it
    is maximally general — but you are hand-assembling a retry loop out
    of streams.
  </p>
  <p>
    FxDart treats backoff as what it is: a number that depends on how
    many times you have failed. The <code>delay</code> hook on
    <code>retry</code> receives the failure count (<code>1, 2, …</code>)
    and returns a <code>Duration</code> — the whole policy is one
    expression, and the budget is the same <code>attempts</code>
    argument as before. Nothing about waiting between attempts requires
    a stream, and the pull side never pretends it does.
  </p>
  <p>
    Verdict FxDart, on concept count: one hook versus a notifier-stream
    factory, an external counter, and a timer stream per failure.
  </p>
