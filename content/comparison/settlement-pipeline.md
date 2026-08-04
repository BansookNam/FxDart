---
slug: settlement-pipeline
title: End-of-day settlement pipeline — Dart vs FxDart
description: Validate, group by merchant, post 2 at a time, then report — one chain crossing sync to async, vs groupListsBy plus a worker pool.
heading: End-of-day settlement pipeline
order: 52
tier: 4
functions: reject, groupBy, map, sumBy, sortBy, toAsync, concurrent, partition
domain: transactions
verdict: fxdart
async: true
---
  <h2>Requirement</h2>
  <p>
    Close out the day. From ten card transactions (in the code below):
    discard <code>failed</code> ones, group the rest by merchant, and net
    each merchant's total (refunds negative). Post each merchant's
    settlement to the bank gateway — at most <strong>two postings in
    flight</strong>, results in merchant order — then print the report: one
    line per merchant, a payout/collection split (one merchant's refunds
    exceed its captures), the grand total, and the max-in-flight proof.
  </p>
  <p>
    This is the whole library in one pipeline. Sync prep:
    <code>reject</code> → <code>groupBy</code> → <code>sumBy</code> per
    group → <code>sortBy</code>. Cross into async with <code>toAsync</code>,
    post under <code>concurrent(2)</code>. Report with
    <code>partition</code> and <code>sumBy</code> again.
  </p>

  {{output}}

  <h2>Side by side</h2>
  {{comparison}}

  <h2>Why they differ</h2>
  <p>
    Each half of this task has appeared in a smaller example; the point
    here is what happens when they meet. Native Dart does the prep well
    enough with <code>package:collection</code>
    (<code>groupListsBy</code>, <code>sortedBy</code>) — though netting
    each group is a <code>fold</code> with an explicit seed, and the
    payout split is two <code>where</code> passes. Then the async boundary
    hits, and the shape breaks: the bounded posting needs the worker pool,
    a separate named function with slots and a cursor, and the pipeline you
    were reading becomes plumbing you must trace. The FxDart version is one
    uninterrupted chain from raw transactions to posted settlements —
    fourteen lines where the policy (what is valid, how to group, how hard
    to hit the gateway) is the visible text, and the mechanics are the
    library's problem.
  </p>
