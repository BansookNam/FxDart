---
slug: concurrent-profile-fetch
title: Fetch 10 profiles, 3 at a time — Dart vs FxDart
description: Sync prep flowing straight into bounded concurrency — filter and sort, then toAsync + map + concurrent(3), vs a hand-rolled worker pool.
heading: Fetch 10 profiles, 3 at a time
order: 49
tier: 4
functions: filter, sortBy, toAsync, map, concurrent, join
domain: users
verdict: fxdart
async: true
---
  <h2>Requirement</h2>
  <p>
    From a directory of twelve accounts, take the <strong>active</strong>
    ones, order them by id, and fetch each profile from a (simulated) API —
    never more than <strong>three requests in flight</strong>, results in the
    original order. The fake fetch counts overlapping requests and both
    versions print the maximum observed, proving the limit held. The data is
    in the code below.
  </p>
  <p>
    This is the flagship shape of the whole async section: a sync pipeline
    (<code>filter</code> → <code>sortBy</code>) that crosses into async with
    <code>toAsync</code> and keeps going — <code>map</code> the fetch,
    <code>concurrent(3)</code> to bound it, one more <code>map</code> to
    format, <code>join</code> to finish. One chain from list to report.
  </p>

  {{output}}

  <h2>Side by side</h2>
  {{comparison}}

  <h2>Why they differ</h2>
  <p>
    Plain Dart handles the sync half fine (<code>where</code> +
    <code>sortedBy</code>), but at the async boundary the vocabulary runs
    out: bounding concurrency while preserving order means a hand-rolled
    worker pool — shared cursor, pre-sized result slots, a
    <code>Future.wait</code> over the workers. That pool is real production
    boilerplate, and it splits the task into two dialects: a fluent chain
    for prep, then imperative plumbing for the fetch. In the FxDart version
    the policy stays declarative end to end — <code>concurrent(3)</code> is
    the entire worker pool, and changing the limit (or dropping it) touches
    one number instead of the function's shape.
  </p>
