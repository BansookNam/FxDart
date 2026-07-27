---
slug: latency-percentiles
title: p50/p95 latency per endpoint — Dart vs FxDart
description: Percentile table from raw request logs — groupBy + sortBy + nth per endpoint vs a row-accumulating loop with in-place sorts.
heading: p50/p95 latency per endpoint
order: 39
tier: 4
functions: filter, groupBy, map, sortBy, nth, maxBy, join
domain: logs
verdict: fxdart
async: false
---
  <h2>Requirement</h2>
  <p>
    From raw request logs (data in the code), drop failed requests and
    compute <strong>p50 and p95 latency per endpoint</strong>: sort each
    endpoint's latencies and take the value at index
    <code>round((n-1) * q / 100)</code>. Print a table sorted by worst p95
    first, then call out the worst endpoint. Both versions must print the
    table under <em>Expected output</em>.
  </p>

  {{output}}

  <h2>Side by side</h2>
  {{comparison}}

  <h2>Why they differ</h2>
  <p>
    A percentile is "sort, then index" — in FxDart that is literally
    <code>sortBy</code> + <code>nth</code>, applied inside a
    <code>groupBy</code> → <code>map</code> pipeline that turns each
    endpoint group into a stats row; ranking the table and finding the worst
    endpoint reuse the same rows with <code>sortBy</code> and
    <code>maxBy</code>. The native version does the same math but through a
    mutable row list filled in a <code>for</code> loop, an in-place
    <code>..sort()</code>, raw index access, and a <code>reduce</code>
    comparator for the maximum. Both are correct; the fxdart side keeps
    "group → summarize → rank" as three visible strokes instead of one loop
    doing all three at once.
  </p>
