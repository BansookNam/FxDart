---
slug: multi-currency-report
title: Multi-currency expense report — Dart vs FxDart
description: Normalize a trip ledger to USD with fixed rates, then group, rank, and summarize — one pipeline per report line vs fold/reduce boilerplate.
heading: Multi-currency expense report
order: 31
tier: 4
functions: map, foldBy, sumBy, sortBy, uniq, maxBy, join
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
    list: <code>foldBy</code> + <code>sortBy</code> for the breakdown,
    <code>uniq</code> for the currency list, <code>maxBy</code> and
    <code>sumBy</code> for the summary lines. Each report line is one short
    pipeline that names its aggregation. The native version makes the
    identical moves but without the vocabulary: the per-category totals are a
    hand-rolled map accumulator, the sort needs a comparator spelled out, the
    maximum is a <code>reduce</code> comparator, and the currency list needs
    the <code>toSet().toList()..sort()</code> shuffle. Nothing is hard — there
    is just more of it, and less of it says what it means.
  </p>
  <p>
    The aggregation is <code>foldBy</code> rather than
    <code>groupBy</code> + <code>sumBy</code> on purpose, and it is worth a
    moment. The answer here is <em>one number per category</em>, so grouping
    first would build a <code>List</code> of every transaction under each
    category and then immediately fold it away — allocation proportional to the
    input, for an answer proportional to the number of categories.
    <code>foldBy</code> accumulates straight into the result map, which is
    exactly what the native loop beside it does. On a million-row ledger that
    single choice is worth roughly 2.5× on <em>both</em> sides; see
    <a href="../tutorials/performance.html">Writing fast pipelines</a>. Reach
    for <code>groupBy</code> when you actually want the members.
  </p>
