---
slug: retry-the-fetch
title: Retry the flaky fetch — RxDart vs FxDart
description: A fetch that fails twice then succeeds — Rx.retry re-subscribes a stream factory, fxdart retry re-runs a Future, both in one call.
heading: Retry the flaky fetch
order: 29
tier: 3
functions: fx, retry
domain: general
verdict: tie
async: true
---
  <h2>Requirement</h2>
  <p>
    The manifest endpoint resets the connection exactly twice before
    serving its payload. Retry until it succeeds, with a budget of three
    attempts in total, then print the payload and how many attempts it
    took. The failure injection is deterministic and in the code; both
    versions must print the lines shown under <em>Expected output</em>.
  </p>

  {{output}}

  <h2>Side by side</h2>
  {{comparison}}

  <h2>Why they differ</h2>
  <p>
    Scarcely at all — this is one call on each side, and that is the
    point of the pair. The difference is what "try again" <em>means</em>
    in each model. In RxDart a stream that has errored is dead, so
    <code>Rx.retry</code> takes a <strong>factory</strong> and
    re-subscribes it: retrying is re-listening, and the count argument is
    the number of <em>retries</em> after the first attempt (here
    <code>2</code>, for three attempts). In FxDart the flaky thing is a
    <code>Future</code>-returning function, so
    <code>retry</code> just calls it again — <code>attempts</code> is the
    total budget (<code>3</code>), and the last error rethrows with its
    original stack trace when the budget is spent.
  </p>
  <p>
    A genuine tie. The shapes only diverge when the retried thing grows:
    if it becomes a multi-value pipeline, RxDart keeps the same factory
    idiom, while FxDart wraps the terminal
    (<code>retry(3, () => fxAsync(…).toList())</code>) or moves to
    per-element retries — a pair of its own, two examples ahead.
  </p>
