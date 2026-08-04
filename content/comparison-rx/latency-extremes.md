---
slug: latency-extremes
title: Fastest and slowest request — RxDart vs FxDart
description: Probe eight endpoints asynchronously and print the min and max latency — Future-returning reductions on both sides, one fresh pass each.
heading: Fastest and slowest request
order: 24
tier: 2
functions: fx, toAsync, min, max
domain: logs
verdict: tie
async: true
---
  <h2>Requirement</h2>
  <p>
    A health check probes eight endpoints through an async
    <code>measure</code> call and reports the fastest and the slowest
    latency in milliseconds. The fixed samples are in the code; both
    versions must print the two lines shown under
    <em>Expected output</em>.
  </p>

  {{output}}

  <h2>Side by side</h2>
  {{comparison}}

  <h2>Why they differ</h2>
  <p>
    Reductions are where push and pull converge: to know the extreme you
    must see the whole sequence, so both <code>min</code> and
    <code>max</code> are terminal and both return a <code>Future</code>.
    RxDart's versions also accept an optional comparator for elements
    that aren't <code>Comparable</code>; FxDart keeps <code>min</code>
    and <code>max</code> as numeric terminals and covers keyed cases with
    <code>minBy</code>/<code>maxBy</code>. On plain integers the two
    calls are word-for-word identical — the FxDart side just lifts the
    pulls into an async chain with <code>toAsync</code> first.
  </p>
  <p>
    The mirrored wrinkle is that <em>each</em> reduction consumes the
    source. A Dart stream is single-subscription, so asking for min and
    then max means two subscriptions — hence the <code>latencies()</code>
    factory on the RxDart side. The FxDart side has the same shape for
    the same reason: a terminal call drains the chain, so the second
    reduction pulls a fresh one. Both therefore measure twice (collecting
    into a list first is the shared alternative), and neither model has
    an edge worth claiming: a tie, decided by which way the surrounding
    code already flows.
  </p>
