---
slug: completion-order-pool
title: Fastest result first — RxDart vs FxDart
description: Print each result the moment it lands — completion order is flatMap's native behavior, and fxdart matches it with a dedicated concurrentPool operator.
heading: Fastest result first
order: 36
tier: 4
functions: fx, toAsync, map, concurrentPool
domain: users
verdict: tie
async: true
---
  <h2>Requirement</h2>
  <p>
    Run six user lookups with distinct response times, at most
    <strong>3</strong> at once, and report the results in
    <strong>completion order</strong> — the fastest lookup prints first,
    regardless of where it sat in the input. The delays are chosen so the
    order is stable (user 2, then 1, 4, 3, 5, 6). The data is in the code;
    both versions must print the lines shown under <em>Expected output</em>.
  </p>

  {{output}}

  <h2>Side by side</h2>
  {{comparison}}

  <h2>Why they differ</h2>
  <p>
    This is the mirror image of the previous example, and the verdict
    flips to even. Completion order is what a merge <em>is</em>: RxDart's
    <code>flatMap(maxConcurrent: 3)</code> subscribes to three inner
    streams and forwards whichever fires first, so "fastest first, three
    at a time" is the operator's literal behavior — nothing to add,
    nothing to undo.
  </p>
  <p>
    A pull pipeline's default is the opposite — results come back in the
    order they were demanded — so FxDart offers completion order as a
    named variant: <code>concurrentPool(3)</code> keeps three pulls open
    and yields whichever resolves first, exactly like the merge. Each
    library reaches this requirement in one operator; the only real
    difference is which behavior each model gets for free and which one
    it had to name. Pick by the order you need — <code>mapConcurrent</code>
    when results must line up with inputs, <code>flatMap</code> /
    <code>concurrentPool</code> when latency to first result matters more.
  </p>
