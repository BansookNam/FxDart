---
slug: bounded-concurrency
title: Fetch profiles, two at a time — Dart vs FxDart
description: Bounded, in-order concurrency — a hand-rolled worker pool in plain Dart vs toAsync + map + concurrent in FxDart.
heading: Fetch profiles, two at a time
order: 20
tier: 2
functions: toAsync, map, concurrent
domain: users
verdict: fxdart
async: true
---
  <h2>Requirement</h2>
  <p>
    Fetch six user profiles from a (simulated) API, but never more than
    <strong>two requests in flight at once</strong> — the API rate-limits.
    Results must come back <strong>in the original order</strong>. To prove
    the limit held, the fake fetch counts how many requests overlap and both
    versions print the maximum observed.
  </p>
  <p>
    This is the task plain Dart has no primitive for.
    <code>Future.wait</code> runs <em>everything</em> at once;
    batching into pairs wastes time waiting for the slower of each pair;
    doing it right means writing a worker pool by hand — index bookkeeping,
    a shared cursor, pre-sized result slots. FxDart's
    <code>.concurrent(2)</code> is that worker pool, as one word: as each
    request finishes the next one starts, and order is preserved.
  </p>

  {{output}}

  <h2>Side by side</h2>
  {{comparison}}

  <h2>Why they differ</h2>
  <p>
    The two versions print the same thing — the difference is what you had
    to write and what you now have to maintain. The native worker pool is
    real production boilerplate (and easy to get subtly wrong: off-by-one on
    the shared cursor, forgetting to pre-size the results list, losing
    ordering). In the FxDart version the concurrency policy is a single
    chain step, so changing the limit — or removing it — touches one number
    instead of the function's whole shape.
  </p>
