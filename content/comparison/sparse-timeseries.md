---
slug: sparse-timeseries
title: Fill gaps in a sparse time series — Dart vs FxDart
description: Days with no transactions become 0.00, then weekly rows with totals — range + groupBy + chunk as one flow vs a counting loop and slices.
heading: Fill gaps in a sparse time series
order: 35
tier: 4
functions: groupBy, range, map, sumBy, chunk, zipWithIndex, join
domain: transactions
verdict: fxdart
async: false
---
  <h2>Requirement</h2>
  <p>
    Transactions for July 1–14 (data in the code) exist only on some days.
    Build the <strong>dense</strong> daily series — days with no
    transactions count as <code>0.00</code> — then print it as two weekly
    rows, each with its 7 daily values and a week total. Both versions must
    print the block under <em>Expected output</em>.
  </p>

  {{output}}

  <h2>Side by side</h2>
  {{comparison}}

  <h2>Why they differ</h2>
  <p>
    Gap-filling means driving the pipeline from the <em>calendar</em>, not
    from the data: <code>range(1, 15)</code> generates every day,
    <code>groupBy</code> answers "what happened that day", and
    <code>sumBy</code> over a possibly-empty group yields the 0.00 for quiet
    days for free. The weekly rollup is then <code>chunk(7)</code> +
    <code>zipWithIndex</code> — reshaping the dense series without a single
    index calculation beyond the row label. Native Dart gets the dense
    series with a counting <code>for</code> and the rollup with
    <code>slices</code>/<code>indexed</code> from
    <code>package:collection</code> — workable, but the sum-of-a-group step
    is a seeded <code>fold</code> both times, and the two phases don't
    compose into one visible flow.
  </p>
