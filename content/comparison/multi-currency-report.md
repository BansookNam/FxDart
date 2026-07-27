---
slug: multi-currency-report
title: Multi-currency expense report — Dart vs FxDart
description: Normalize a trip ledger to USD with fixed rates, then group, rank, and summarize — one pipeline per report line vs fold/reduce boilerplate.
heading: Multi-currency expense report
order: 36
tier: 4
functions: map, groupBy, sumBy, sortBy, uniq, maxBy, join
domain: transactions
verdict: fxdart
async: false
---
  <h2>Requirement</h2>
  <p>
    A trip ledger (data in the code) mixes EUR, GBP, JPY, and USD amounts.
    Convert everything to USD with the fixed rates in the code, then report:
    per-category totals sorted by spend, the currencies seen, the largest
    single expense (with its original amount), and the grand total. Both
    versions must print the report under <em>Expected output</em>.
  </p>

  {{output}}

  <h2>Side by side</h2>
  {{comparison}}

  <h2>Why they differ</h2>
  <p>
    Normalizing first — <code>map</code> each transaction to a
    <code>(tx, usd)</code> pair — lets every later question run over one
    list: <code>groupBy</code> + <code>sumBy</code> + <code>sortBy</code>
    for the breakdown, <code>uniq</code> for the currency list,
    <code>maxBy</code> and <code>sumBy</code> for the summary lines. Each
    report line is one short pipeline that names its aggregation. The native
    version makes the identical moves but without the vocabulary: every sum
    is a seeded <code>fold</code>, the maximum is a hand-written
    <code>reduce</code> comparator, and the currency list needs the
    <code>toSet().toList()..sort()</code> shuffle. Nothing is hard — there
    is just more of it, and less of it says what it means.
  </p>
