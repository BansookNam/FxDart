---
slug: concurrent-enrichment
title: Enrich top merchants concurrently — Dart vs FxDart
description: Pick the top 3 merchants, then look each up over a rate-limited API, 2 at a time — a hand-rolled worker pool in plain Dart vs concurrent(2) in FxDart.
heading: Enrich top merchants concurrently
order: 30
tier: 3
functions: sortBy, take, toAsync, map, concurrent
domain: transactions
verdict: fxdart
async: true
---
  <h2>Requirement</h2>
  <p>
    From July's per-merchant spend totals, take the <strong>top three
    merchants</strong> and enrich each with its category from a
    (simulated) merchant-directory API — but the API rate-limits, so
    never more than <strong>two lookups in flight at once</strong>.
    Results print in spend order after all lookups finish, and the fake
    lookup counts overlapping requests so both versions can prove the
    limit held. The data is in the code below; both versions must print
    the lines shown under <em>Expected output</em>.
  </p>

  {{output}}

  <h2>Side by side</h2>
  {{comparison}}

  <h2>Why they differ</h2>
  <p>
    The task changes character halfway through — synchronous ranking, then
    rate-limited I/O — and only one version's code changes character with
    it. In FxDart the seam is a single chain step: <code>sortBy</code> +
    <code>take</code> pick the merchants, <code>toAsync</code> crosses
    into async, and <code>map</code> + <code>concurrent(2)</code> run the
    lookups two at a time, in order. Native Dart has no primitive for
    "at most two in flight": <code>Future.wait</code> fires everything at
    once, so the bounded half becomes a hand-rolled worker pool — shared
    cursor, pre-sized result slots, worker futures — that dwarfs the
    two-line ranking it serves. Changing the limit, or dropping it, is
    one number in the chain versus that whole scaffold.
  </p>
