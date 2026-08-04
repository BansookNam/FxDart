---
slug: food-spending
title: Food spending this month — Dart vs FxDart
description: Total one category of a ledger — a where/fold chain in plain Dart vs filter + sumBy in FxDart.
heading: Food spending this month
order: 8
tier: 1
functions: filter, sumBy
domain: transactions
verdict: fxdart
async: false
---
  <h2>Requirement</h2>
  <p>
    Given a month of ledger transactions — each with a date, category,
    merchant, and amount — total what was spent in the
    <strong>Food</strong> category, and print it as a currency amount.
    The data is in the code below; both versions must print the line shown
    under <em>Expected output</em>.
  </p>

  {{output}}

  <h2>Side by side</h2>
  {{comparison}}

  <h2>Why they differ</h2>
  <p>
    Native Dart has no "sum of a field" — you either mutate an accumulator in
    a <code>for</code> loop or reach for <code>fold</code> with an explicit
    seed and combine step. FxDart's <code>sumBy</code> says the intent in one
    word, and the <code>filter → sumBy</code> chain reads in the order the
    data flows. The gap is small on a two-step task — it widens as steps
    are added.
  </p>
