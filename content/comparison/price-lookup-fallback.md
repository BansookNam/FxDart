---
slug: price-lookup-fallback
title: Concurrent price lookup with fallback — Dart vs FxDart
description: Look up live prices 3 at a time, fall back to catalog prices for missing SKUs — concurrent + a null-coalescing map vs a worker pool.
heading: Concurrent price lookup with fallback
order: 43
tier: 4
functions: toAsync, map, concurrent, filter, size, sumBy
domain: orders
verdict: fxdart
async: true
---
  <h2>Requirement</h2>
  <p>
    Price a six-line order. Each SKU is looked up in the live pricing
    service — at most <strong>three lookups in flight</strong> — but the
    service is missing some SKUs and returns <code>null</code> for them;
    those lines fall back to the catalog list price carried on the item.
    Print each priced line in order (flagging fallbacks), the fallback
    count, the order total, and the maximum observed concurrency. All data
    is in the code below.
  </p>
  <p>
    The FxDart chain does the lookup under <code>concurrent(3)</code>, then
    a second <code>map</code> applies the fallback with plain
    <code>??</code> — the recovery policy is just another pipeline step
    downstream of the bounded fetch.
  </p>

  {{output}}

  <h2>Side by side</h2>
  {{comparison}}

  <h2>Why they differ</h2>
  <p>
    The fallback itself is easy in both versions — <code>??</code> is Dart.
    What plain Dart lacks is the step before it: three-at-a-time lookups
    with results in input order force the worker-pool idiom (shared cursor,
    pre-sized slots, <code>Future.wait</code>), and the fallback logic ends
    up buried inside the worker body where it is hardest to see and test.
    In the FxDart version fetch and recovery are two separate, visible
    stages of one chain — <code>concurrent(3)</code> owns the limit,
    the next <code>map</code> owns the policy — and the summary lines
    (<code>filter</code> + <code>size</code> for fallbacks,
    <code>sumBy</code> for the total) reuse the same vocabulary the rest of
    the site teaches.
  </p>
