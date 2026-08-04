---
slug: per-row-retry
title: Retry each flaky row independently — RxDart vs FxDart
description: Six flaky import rows, two attempts each, three in flight — flatMap emits in completion order, mapRetry under concurrent keeps source order.
heading: Retry each flaky row independently
order: 31
tier: 3
functions: fx, toAsync, retry, concurrent
domain: orders
verdict: fxdart
async: true
---
  <h2>Requirement</h2>
  <p>
    Import six rows through a flaky endpoint: the even rows fail exactly
    once before succeeding. Give <strong>each row its own retry
    budget</strong> of two attempts, run up to three rows at a time, and
    print the results <strong>in source order</strong> with the attempt
    count that succeeded. The failure injection and per-row delays are
    deterministic and in the code; both versions must print the lines
    shown under <em>Expected output</em>.
  </p>

  {{output}}

  <h2>Side by side</h2>
  {{comparison}}

  <h2>Why they differ</h2>
  <p>
    Both sides express the resilience half the same way: a retry wrapper
    per row, so one flaky row re-runs while its neighbors sail through.
    RxDart spells it <code>flatMap</code> into a retrying inner stream
    per row with <code>maxConcurrent:&nbsp;3</code>; FxDart spells it
    <code>mapRetry(2,&nbsp;…)</code> under <code>concurrent(3)</code>,
    where each in-flight element carries its own independent budget.
  </p>
  <p>
    The difference is what comes out the other end.
    <code>flatMap</code> merges inner streams in <em>completion</em>
    order — that is its contract — so with three rows in flight and
    unequal delays, the results arrive shuffled. Getting source order
    back means tagging every result with its row id and sorting after
    <code>toList</code>. The RxDart operator that would preserve order,
    <code>concatMap</code>, does it by giving up the concurrency —
    one row at a time. In the pull model, ordered concurrency is the
    native mode: <code>concurrent(3)</code> evaluates three pulls at
    once but yields them in source order by construction, so there is
    nothing to tag and nothing to sort.
  </p>
  <p>
    Verdict FxDart — the ordering is the story. "N at a time, retried
    independently, in order" is one chain in the pull model and a
    merge-then-reorder workaround in the push model.
  </p>
