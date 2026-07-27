---
slug: budget-alerts
title: Categories over their monthly budget — Dart vs FxDart
description: Total spend per category, keep the ones over budget, rank by overage — mutable-map bookkeeping in plain Dart vs groupBy + filter + sortBy in FxDart.
heading: Categories over their monthly budget
order: 25
tier: 3
functions: groupBy, map, filter, sortBy, join
domain: transactions
verdict: fxdart
async: false
---
  <h2>Requirement</h2>
  <p>
    Each spending category has a monthly budget. From July's transactions,
    total each category, keep only the categories that <strong>went over
    their budget</strong>, and print them worst offender first — spent,
    budget, and the overage on each line. The data is in the code below;
    both versions must print the lines shown under
    <em>Expected output</em>.
  </p>

  {{output}}

  <h2>Side by side</h2>
  {{comparison}}

  <h2>Why they differ</h2>
  <p>
    The formatting line is identical in both versions — the difference is
    everything before it. Native Dart does the grouping by hand in a
    mutable map, then switches idiom twice: a <code>for</code> loop to
    total, a <code>where</code> to filter, a cascade-<code>sort</code>
    with a hand-built comparator to rank. The FxDart version is one
    vocabulary end to end: <code>groupBy</code>, <code>map</code> to
    totals, <code>filter</code> against the budget, <code>sortBy</code>
    the overage, <code>join</code>. Each business rule — over budget,
    worst first — is one named step you can point at in a code review.
  </p>
