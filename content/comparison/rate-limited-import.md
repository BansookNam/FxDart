---
slug: rate-limited-import
title: Rate-limited batch import — Dart vs FxDart
description: Import 9 transactions in batches of 3, one batch at a time, with a running total — chunk + concurrent(1) + scan vs a sequential loop.
heading: Rate-limited batch import
order: 45
tier: 4
functions: chunk, toAsync, map, concurrent, delay, scan, drop, sumBy
domain: transactions
verdict: fxdart
async: true
---
  <h2>Requirement</h2>
  <p>
    Push nine ledger transactions (in the code below) to an import endpoint
    that accepts <strong>batches of three, one call at a time</strong> —
    strictly sequential, never overlapping. After each batch, record its
    size, its amount, and the running total imported so far; print the
    batch summaries in order, then prove the rate limit held via the
    max-in-flight counter (it must read 1).
  </p>
  <p>
    In FxDart the whole policy is the chain: <code>chunk(3)</code> sets the
    batch size, <code>concurrent(1)</code> sets the pace, and
    <code>scan</code> threads the running total through the acknowledgments
    (<code>drop(1)</code> discards the scan seed). The endpoint itself
    simulates latency with <code>delay</code> and sums its batch with
    <code>sumBy</code>.
  </p>

  {{output}}

  <h2>Side by side</h2>
  {{comparison}}

  <h2>Why they differ</h2>
  <p>
    To be fair: a strictly sequential import is the one concurrency policy a
    plain <code>for</code> loop handles gracefully, and the native version
    reads fine — <code>slices</code> from <code>package:collection</code>
    even covers the batching. The running total, though, is already mutable
    state threaded by hand (<code>running += amount</code> next to
    <code>n++</code>), where <code>scan</code> makes it a declared step.
    And the loop's simplicity is a dead end: the day the endpoint allows two
    concurrent batches, the FxDart version changes <code>1</code> to
    <code>2</code>, while the loop becomes the worker pool from the other
    async examples. The chain states the policy; the loop encodes it.
  </p>
